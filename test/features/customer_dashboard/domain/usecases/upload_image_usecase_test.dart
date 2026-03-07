import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/profile/domain/repositories/upload_image_repository.dart';
import 'package:munch_nearby/features/profile/domain/usecases/upload_image_usecase.dart';

class MockImageRepository extends Mock implements IUploadImageRepository {}

void main() {
  late UploadImageUsecase usecase;
  late MockImageRepository mockRepository;

  setUp(() {
    mockRepository = MockImageRepository();
    usecase = UploadImageUsecase(repository: mockRepository);
  });

  final tFile = File('test/assets/test_image.png');
  const tFileName = 'uploaded_image.png';

  group("Image Upload Unit testing", () {
    test('should return file name when upload is successful', () async {
      // Arrange
      when(
        () => mockRepository.uploadImage(tFile),
      ).thenAnswer((_) async => const Right(tFileName));

      // Act
      final result = await usecase(tFile);

      // Assert
      expect(result, const Right(tFileName));
      verify(() => mockRepository.uploadImage(tFile)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when upload fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Upload failed');
      when(
        () => mockRepository.uploadImage(tFile),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(tFile);

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.uploadImage(tFile)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when there is no internet', () async {
      // Arrange
      const failure = NetworkFailure();
      when(
        () => mockRepository.uploadImage(tFile),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(tFile);

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.uploadImage(tFile)).called(1);
    });
  });
}
