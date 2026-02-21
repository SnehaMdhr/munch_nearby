import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/core/services/connectivity/network_info.dart';
import 'package:munch_nearby/features/restaurant/data/datasources/local/restaurant_local_datasource.dart';
import 'package:munch_nearby/features/restaurant/data/datasources/remote/restaurant_remote_datasouce.dart';
import 'package:munch_nearby/features/restaurant/data/datasources/restaurant_datasource.dart';
import 'package:munch_nearby/features/restaurant/data/models/restaurant_api_model.dart';
import 'package:munch_nearby/features/restaurant/data/models/restaurant_hive_model.dart';
import 'package:munch_nearby/features/restaurant/domain/entities/restaurant_entity.dart';
import 'package:munch_nearby/features/restaurant/domain/repositories/restaurant_repository.dart';

final restaurantRepositoryProvider =
    Provider<IRestaurantRepository>((ref) {
  final localDatasource = ref.read(restaurantLocalDatasourceProvider);
  final remoteDatasource = ref.read(restaurantRemoteDatasourceProvider);
  final networkInfo = ref.read(NetworkInfoProvider);

  return RestaurantRepositoryImpl(
    localDataSource: localDatasource,
    remoteDataSource: remoteDatasource,
    networkInfo: networkInfo,
  );
});

class RestaurantRepositoryImpl implements IRestaurantRepository {
  final RestaurantLocalDataSource _localDataSource;
  final RestaurantRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  RestaurantRepositoryImpl({
    required RestaurantLocalDataSource localDataSource,
    required RestaurantRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  // =====================================================
  // GET ALL RESTAURANTS (REMOTE FIRST WITH LOCAL FALLBACK)
  // =====================================================
  @override
  Future<Either<Failure, List<RestaurantEntity>>>
      getAllRestaurants() async {
    if (await _networkInfo.isConnected) {
      try {
        final remoteData =
            await _remoteDataSource.fetchRestaurants();

        // Cache to local
        final hiveModels = remoteData
            .map((RestaurantApiModel apiModel) =>
                apiModel.toHiveModel())
            .toList();

        await _localDataSource.cacheRestaurants(hiveModels);

        // Convert to entities
        final entities = remoteData
            .map((RestaurantApiModel apiModel) =>
                apiModel.toEntity())
            .toList();

        return Right(entities);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data["message"] ??
                    "Failed to fetch restaurants",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      // Offline fallback
      try {
        final localData =
            await _localDataSource.getRestaurants();

        if (localData.isEmpty) {
          return Left(
            LocalDatabaseFailure(
              message: "No cached restaurants found",
            ),
          );
        }

        final entities = localData
            .map((RestaurantHiveModel model) =>
                model.toEntity())
            .toList();

        return Right(entities);
      } catch (e) {
        return Left(
          LocalDatabaseFailure(message: e.toString()),
        );
      }
    }
  }

  // =====================================================
  // FORCE REFRESH (REMOTE ONLY)
  // =====================================================
  @override
  Future<Either<Failure, List<RestaurantEntity>>>
      refreshRestaurants() async {
    try {
      final remoteData =
          await _remoteDataSource.fetchRestaurants();

      final hiveModels = remoteData
          .map((RestaurantApiModel apiModel) =>
              apiModel.toHiveModel())
          .toList();

      await _localDataSource.cacheRestaurants(hiveModels);

      final entities = remoteData
          .map((RestaurantApiModel apiModel) =>
              apiModel.toEntity())
          .toList();

      return Right(entities);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message:
              e.response?.data["message"] ??
                  "Failed to refresh restaurants",
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}