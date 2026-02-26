import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/core/services/connectivity/network_info.dart';
import 'package:munch_nearby/core/services/storage/user_session_service.dart';
import 'package:munch_nearby/features/favourite/data/datasources/favourite_datasource.dart';

import '../../domain/entities/favourite_entity.dart';
import '../../domain/repositories/favourite_repository.dart';
import '../datasources/local/favourite_local_datasource.dart';
import '../datasources/remote/favourite_remote_datasource.dart';
import '../models/favourite_api_model.dart';
import '../models/favourite_hive_model.dart';

final favouriteRepositoryProvider =
    Provider<IFavouriteRepository>((ref) {
  final localDatasource = ref.read(favouriteLocalDatasourceProvider);
  final remoteDatasource = ref.read(favouriteRemoteDatasourceProvider);
  final networkInfo = ref.read(NetworkInfoProvider);
  final sessionService = ref.read(userSessionServiceProvider);

  return FavouriteRepository(
    localDatasource: localDatasource,
    remoteDatasource: remoteDatasource,
    networkInfo: networkInfo,
    sessionService: sessionService,
  );
});

class FavouriteRepository implements IFavouriteRepository {
  final IFavouriteLocalDatasource _localDatasource;
  final IFavouriteRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;
  final UserSessionService _sessionService;

  FavouriteRepository({
    required IFavouriteLocalDatasource localDatasource,
    required IFavouriteRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
    required UserSessionService sessionService,
  })  : _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource,
        _networkInfo = networkInfo,
        _sessionService = sessionService;

  @override
  Future<Either<Failure, bool>> addToFavourite(
      FavouriteEntity entity) async {

    final customerId = _sessionService.getCurrentUserId();
    if (customerId == null) {
      return Left(LocalDatabaseFailure(message: "User not logged in"));
    }

    if (await _networkInfo.isConnected) {
      try {
        final apiModel = FavouriteApiModel.fromEntity(entity);
        await _remoteDatasource.addToFavourite(apiModel);

        final hiveModel = FavouriteHiveModel.fromEntity(entity);
        await _localDatasource.addToFavourite(hiveModel);

        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data?["message"] ??
                "Failed to add favourite",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final hiveModel = FavouriteHiveModel.fromEntity(entity);
        await _localDatasource.addToFavourite(hiveModel);
        return const Right(true);
      } catch (e) {
        return Left(
          LocalDatabaseFailure(message: e.toString()),
        );
      }
    }
  }

  @override
  Future<Either<Failure, bool>> removeFromFavourite(
      String restaurantId) async {

    final customerId = _sessionService.getCurrentUserId();
    if (customerId == null) {
      return Left(LocalDatabaseFailure(message: "User not logged in"));
    }

    if (await _networkInfo.isConnected) {
      try {
        await _remoteDatasource.removeFromFavourite(restaurantId);
        await _localDatasource.removeFromFavourite(restaurantId);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data?["message"] ??
                "Failed to remove favourite",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        await _localDatasource.removeFromFavourite(restaurantId);
        return const Right(true);
      } catch (e) {
        return Left(
          LocalDatabaseFailure(message: e.toString()),
        );
      }
    }
  }

  @override
Future<Either<Failure, List<FavouriteEntity>>> getFavourites() async {
  final customerId = _sessionService.getCurrentUserId();
    if (customerId == null) {
      return Left(LocalDatabaseFailure(message: "User not logged in"));
    }
    if (await _networkInfo.isConnected) {
      try {
        final apiModels = await _remoteDatasource.getFavourites();

        final entities = apiModels.map((model) => model.toEntity()).toList();

        await _localDatasource.clearFavourites(); 

        for (var entity in entities) {
          final hiveModel = FavouriteHiveModel.fromEntity(entity);
          await _localDatasource.addToFavourite(hiveModel);
        }

        return Right(entities);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data?["message"] ?? "Failed to fetch favourites",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {

      try {
        final hiveModels = await _localDatasource.getFavouritesByUser(customerId);
        
        final entities = hiveModels.map((model) => model.toEntity()).toList();
        
        return Right(entities);
      } catch (e) {
        return Left(
          LocalDatabaseFailure(message: "Offline: Could not retrieve cached data"),
        );
      }
    }

  }

  @override
  Future<Either<Failure, bool>> isFavourite(
      String restaurantId) async {

    final customerId = _sessionService.getCurrentUserId();
    if (customerId == null) {
      return Left(LocalDatabaseFailure(message: "User not logged in"));
    }

    try {
      final result =
          await _localDatasource.isFavourite(customerId, restaurantId);

      return Right(result);
    } catch (e) {
      return Left(
        LocalDatabaseFailure(message: e.toString()),
      );
    }
  }
}