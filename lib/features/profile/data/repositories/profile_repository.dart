import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/features/profile/data/datasources/local/profile_local_datasource.dart';
import 'package:munch_nearby/features/profile/data/datasources/remote/profile_remote_datasource.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/services/connectivity/network_info.dart';

import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';

import '../datasources/profile_datasource.dart';

import '../models/profile_hive_model.dart';

/// PROVIDER
final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  final localDatasource = ref.read(profileLocalDatasourceProvider);
  final remoteDatasource = ref.read(profileRemoteDatasourceProvider);
  final networkInfo = ref.read(NetworkInfoProvider);

  return ProfileRepository(
    profileLocalDatasource: localDatasource,
    profileRemoteDatasource: remoteDatasource,
    networkInfo: networkInfo,
  );
});

/// IMPLEMENTATION
class ProfileRepository implements IProfileRepository {
  final IProfileLocalDatasource _profileLocalDatasource;
  final IProfileRemoteDatasource _profileRemoteDatasource;
  final NetworkInfo _networkInfo;

  ProfileRepository({
    required IProfileLocalDatasource profileLocalDatasource,
    required IProfileRemoteDatasource profileRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _profileLocalDatasource = profileLocalDatasource,
       _profileRemoteDatasource = profileRemoteDatasource,
       _networkInfo = networkInfo;

  String _extractApiMessage(DioException e, String fallback) {
    final responseData = e.response?.data;

    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    if (responseData is String && responseData.trim().isNotEmpty) {
      return responseData;
    }

    final dioMessage = e.message;
    if (dioMessage != null && dioMessage.trim().isNotEmpty) {
      return dioMessage;
    }

    return fallback;
  }

  @override
  Future<Either<Failure, ProfileEntity>> getUserById(String userId) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _profileRemoteDatasource.getUserById(userId);

        if (apiModel != null) {
          return Right(apiModel.toEntity());
        }

        return Left(ApiFailure(message: "Profile not found"));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: _extractApiMessage(e, "Failed to fetch profile"),
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final localModel = await _profileLocalDatasource.getUserById(userId);

        if (localModel != null) {
          return Right(localModel.toEntity());
        }

        return Left(LocalDatabaseFailure(message: "Profile not found locally"));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile(
    ProfileEntity entity,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        String? profilePicture = entity.profilePicture;
        var shouldSendProfilePicture = false;
        if (profilePicture != null && profilePicture.trim().isNotEmpty) {
          final trimmed = profilePicture.trim();
          final isRemoteImage =
              trimmed.startsWith('http://') ||
              trimmed.startsWith('https://') ||
              trimmed.startsWith('/uploads/') ||
              trimmed.startsWith('uploads/');

          if (!isRemoteImage) {
            final uploaded = await _profileRemoteDatasource.uploadProfileImage(
              entity.userId,
              trimmed,
            );
            if (uploaded != null && uploaded.isNotEmpty) {
              profilePicture = uploaded;
              shouldSendProfilePicture = false;
            }
          } else {
            shouldSendProfilePicture = true;
          }
        }

        final updateData = <String, dynamic>{
          "name": entity.name,
          "email": entity.email,
        };

        if (shouldSendProfilePicture &&
            profilePicture != null &&
            profilePicture.trim().isNotEmpty) {
          updateData["profilePicture"] = profilePicture;
        }

        final apiModel = await _profileRemoteDatasource.updateProfile(
          entity.userId,
          updateData,
        );

        if (apiModel != null) {
          return Right(apiModel.toEntity());
        }

        return Left(ApiFailure(message: "Failed to update profile"));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: _extractApiMessage(e, "Profile update failed"),
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final hiveModel = ProfileHiveModel.fromEntity(entity);

        final updated = await _profileLocalDatasource.updateProfile(hiveModel);

        if (updated != null) {
          return Right(updated.toEntity());
        }

        return Left(
          LocalDatabaseFailure(message: "Failed to update profile locally"),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage(
    String userId,
    String imagePath,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final imageUrl = await _profileRemoteDatasource.uploadProfileImage(
          userId,
          imagePath,
        );

        if (imageUrl != null) {
          return Right(imageUrl);
        }

        return Left(ApiFailure(message: "Failed to upload image"));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: _extractApiMessage(e, "Image upload failed"),
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final localResult = await _profileLocalDatasource.uploadProfileImage(
          userId,
          imagePath,
        );

        if (localResult != null) {
          return Right(localResult);
        }

        return Left(
          LocalDatabaseFailure(message: "Failed to update image locally"),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }
}
