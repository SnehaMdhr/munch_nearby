import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:munch_nearby/core/error/failure.dart';
import 'package:munch_nearby/features/profile/domain/repositories/upload_image_repository.dart';
import 'package:munch_nearby/features/profile/domain/usecases/upload_image_usecase.dart';

class MockUploadImageRepository extends Mock
    implements IUploadImageRepository {}

class MockFile extends Mock implements File {}

void main() {
  late UploadImageUsecase usecase;
  late MockUploadImageRepository mockRepository;
  late MockFile mockFile;

  setUp(() {
    mockRepository = MockUploadImageRepository();
    usecase = UploadImageUsecase(repository: mockRepository);
    mockFile = MockFile();
  });

  setUpAll(() {
    registerFallbackValue(MockFile());
  });

  group('UploadImageUsecase', () {
    test('should return file name on successful upload', () async {
      when(
        () => mockRepository.uploadImage(any()),
      ).thenAnswer((_) async => const Right('uploaded_image.jpg'));

      final result = await usecase(mockFile);

      expect(result, const Right('uploaded_image.jpg'));
      verify(() => mockRepository.uploadImage(mockFile)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ApiFailure on upload failure', () async {
      const tFailure = ApiFailure(message: 'Upload failed');
      when(
        () => mockRepository.uploadImage(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase(mockFile);

      expect(result, const Left(tFailure));
    });

    test('should return NetworkFailure when no internet', () async {
      const tFailure = NetworkFailure();
      when(
        () => mockRepository.uploadImage(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await usecase(mockFile);

      expect(result, const Left(tFailure));
    });
  });
}
