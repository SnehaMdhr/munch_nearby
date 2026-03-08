import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/core/services/connectivity/network_info.dart';
import 'package:munch_nearby/core/services/storage/user_session_service.dart';
import 'package:munch_nearby/features/review/data/datasources/review_datasource.dart';

import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/local/review_local_datasource.dart';
import '../datasources/remote/review_remote_datasource.dart';
import '../models/review_api_model.dart';
import '../models/review_hive_model.dart';

final reviewRepositoryProvider = Provider<IReviewRepository>((ref) {
  return ReviewRepository(
    localDatasource: ref.read(reviewLocalDatasourceProvider),
    remoteDatasource: ref.read(reviewRemoteDatasourceProvider),
    networkInfo: ref.read(NetworkInfoProvider),
    sessionService: ref.read(userSessionServiceProvider),
  );
});

class ReviewRepository implements IReviewRepository {
  final IReviewLocalDatasource _localDatasource;
  final IReviewRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;
  final UserSessionService _sessionService;

  ReviewRepository({
    required IReviewLocalDatasource localDatasource,
    required IReviewRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
    required UserSessionService sessionService,
  })  : _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource,
        _networkInfo = networkInfo,
        _sessionService = sessionService;

  String _extractDioErrorMessage(DioException e, String fallback) {
    final dynamic data = e.response?.data;

    if (data is Map<String, dynamic>) {
      final message = data["message"];
      if (message != null) return message.toString();
    }

    if (data is String && data.trim().isNotEmpty) {
      return data;
    }

    if (e.message != null && e.message!.trim().isNotEmpty) {
      return e.message!;
    }

    return fallback;
  }

  @override
  Future<Either<Failure, bool>> createReview(ReviewEntity entity) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = ReviewApiModel.fromEntity(entity);
        await _remoteDatasource.createReview(apiModel);

        final hiveModel = ReviewHiveModel.fromEntity(entity);
        await _localDatasource.saveReview(hiveModel);

        return const Right(true);
      } on DioException catch (e) {
        return Left(ApiFailure(
          message: _extractDioErrorMessage(e, "Failed to create review"),
          statusCode: e.response?.statusCode,
        ));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: "No internet connection to post review"));
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getRestaurantReviews(String restaurantId) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModels = await _remoteDatasource.getRestaurantReviews(restaurantId);
        final entities = apiModels.map((model) => model.toEntity()).toList();

        final hiveModels = apiModels.map((m) => ReviewHiveModel.fromEntity(m.toEntity())).toList();
        await _localDatasource.cacheReviews(hiveModels);

        return Right(entities);
      } on DioException catch (e) {
        return Left(ApiFailure(message: _extractDioErrorMessage(e, "Failed to fetch reviews")));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final hiveModels = await _localDatasource.getReviewsByRestaurant(restaurantId);
        return Right(hiveModels.map((m) => m.toEntity()).toList());
      } catch (e) {
        return Left(LocalDatabaseFailure(message: "Offline: Could not retrieve cached reviews"));
      }
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getMyReviews() async {
    final customerId = _sessionService.getCurrentUserId();
    if (customerId == null) return Left(LocalDatabaseFailure(message: "User not logged in"));

    if (await _networkInfo.isConnected) {
      try {
        final apiModels = await _remoteDatasource.getMyReviews();
        return Right(apiModels.map((m) => m.toEntity()).toList());
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      final hiveModels = await _localDatasource.getReviewsByCustomer(customerId);
      return Right(hiveModels.map((m) => m.toEntity()).toList());
    }
  }

  @override
  Future<Either<Failure, bool>> updateReview(String reviewId, ReviewEntity entity) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = ReviewApiModel.fromEntity(entity);
        await _remoteDatasource.updateReview(reviewId, apiModel);
        
        final hiveModel = ReviewHiveModel.fromEntity(entity);
        await _localDatasource.saveReview(hiveModel);
        
        return const Right(true);
      } on DioException catch (e) {
        return Left(ApiFailure(message: _extractDioErrorMessage(e, "Update failed")));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }
    return Left(NetworkFailure(message: "Internet required to update review"));
  }

  @override
  Future<Either<Failure, bool>> deleteReview(String reviewId) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDatasource.deleteReview(reviewId);
        await _localDatasource.deleteReview(reviewId);
        return const Right(true);
      } on DioException catch (e) {
        return Left(ApiFailure(message: _extractDioErrorMessage(e, "Delete failed")));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }
    return Left(NetworkFailure(message: "Internet required to delete review"));
  }
}