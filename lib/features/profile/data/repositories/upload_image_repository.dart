import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/core/services/connectivity/network_info.dart';
import 'package:munch_nearby/features/profile/data/datasources/remote/upload_image_remote_datasource.dart';
import 'package:munch_nearby/features/profile/data/datasources/upload_image_datasource.dart';
import 'package:munch_nearby/features/profile/domain/repositories/upload_image_repository.dart';

final uploadImageRepositoryProvider = Provider<IUploadImageRepository>((ref) {
  final networkInfo = ref.read(NetworkInfoProvider);
  final uploadImageRemoteDatasource = ref.read(
    uploadImageRemoteDatasourceProvider,
  );
  return UploadImageRepository(
    networkInfo: networkInfo,
    uplaodImageRemoteDataSource: uploadImageRemoteDatasource,
  );
});

class UploadImageRepository implements IUploadImageRepository {
  final IUploadImageRemoteDatasource _uplaodImageRemoteDataSource;
  final NetworkInfo _networkInfo;
  UploadImageRepository({
    required NetworkInfo networkInfo,
    required IUploadImageRemoteDatasource uplaodImageRemoteDataSource,
  }) : _networkInfo = networkInfo,
       _uplaodImageRemoteDataSource = uplaodImageRemoteDataSource;

  @override
  Future<Either<Failure, String>> uploadImage(File image) async {
    if (await _networkInfo.isConnected) {
      try {
        final fileName = await _uplaodImageRemoteDataSource.uploadImage(image);
        return Right(fileName);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(ApiFailure(message: "No internet connection"));
    }
  }
}
