import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/core/usecases/app_usecase.dart';
import 'package:munch_nearby/features/profile/data/repositories/upload_image_repository.dart';
import 'package:munch_nearby/features/profile/domain/repositories/upload_image_repository.dart';

final uploadImageUsecaseProvider = Provider<UploadImageUsecase>((ref) {
  final repository = ref.read(uploadImageRepositoryProvider);
  return UploadImageUsecase(repository: repository);
});

class UploadImageUsecase implements UseCaseWithParams<String, File> {
  final IUploadImageRepository _repository;

  UploadImageUsecase({required IUploadImageRepository repository})
    : _repository = repository;
  @override
  Future<Either<Failure, String>> call(File params) {
    return _repository.uploadImage(params);
  }
}
