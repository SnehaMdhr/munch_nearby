import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:munch_nearby/core/error/failure.dart';

abstract interface class IUploadImageRepository {
  Future<Either<Failure, String>> uploadImage(File image);
}
