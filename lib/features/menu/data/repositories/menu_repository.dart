import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/core/services/connectivity/network_info.dart';
import 'package:munch_nearby/features/menu/data/datasources/local/menu_local_datasource.dart';
import 'package:munch_nearby/features/menu/data/datasources/menu_datasource.dart';
import 'package:munch_nearby/features/menu/data/datasources/remote/menu_remote_datasource.dart';
import 'package:munch_nearby/features/menu/data/models/menu_hive_model.dart';
import 'package:munch_nearby/features/menu/domain/entities/menu_entity.dart';
import 'package:munch_nearby/features/menu/domain/repositories/menu_repository.dart';

final menuRepositoryProvider = Provider<IMenuRepository>((ref) {
  final remoteDatasource = ref.read(menuRemoteDatasourceProvider);
  final localDatasource = ref.read(menuLocalDatasourceProvider);
  final networkInfo = ref.read(NetworkInfoProvider);

  return MenuRepository(
    remoteDatasource: remoteDatasource,
    localDatasource: localDatasource,
    networkInfo: networkInfo,
  );
});

class MenuRepository implements IMenuRepository {
  final IMenuRemoteDatasource _remoteDatasource;
  final IMenuLocalDatasource _localDatasource;
  final NetworkInfo _networkInfo;

  MenuRepository({
    required IMenuRemoteDatasource remoteDatasource,
    required IMenuLocalDatasource localDatasource,
    required NetworkInfo networkInfo,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<MenuEntity>>> 
      getMenusByRestaurant(String restaurantId) async {

    if (await _networkInfo.isConnected) {
      try {
        final remoteMenus =
            await _remoteDatasource.getMenusByRestaurant(restaurantId);

        final entities =
            remoteMenus.map((e) => e.toEntity()).toList();

        final hiveModels =
            entities.map((e) => MenuHiveModel.fromEntity(e)).toList();

        await _localDatasource.cacheMenus(hiveModels);

        return Right(entities);

      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data?["message"] ?? "Failed to load menu",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final localMenus =
            await _localDatasource.getMenusByRestaurant(restaurantId);

        if (localMenus.isEmpty) {
          return Left(
            LocalDatabaseFailure(message: "No cached menu found"),
          );
        }

        final entities =
            localMenus.map((e) => e.toEntity()).toList();

        return Right(entities);

      } catch (e) {
        return Left(
          LocalDatabaseFailure(message: e.toString()),
        );
      }
    }
  }
}