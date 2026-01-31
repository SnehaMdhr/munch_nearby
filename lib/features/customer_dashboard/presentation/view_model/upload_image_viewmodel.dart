import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/features/customer_dashboard/domain/usecases/upload_image_usecase.dart';
import 'package:munch_nearby/features/customer_dashboard/presentation/state/upload_image_state.dart';

final uploadImageViewModelProvider = NotifierProvider<UploadImageViewmodel, UploadImageState>(
  UploadImageViewmodel.new,
);

class UploadImageViewmodel extends Notifier<UploadImageState> {
  
  late final UploadImageUsecase _uploadImageUsecase;

  @override
  UploadImageState build() {
    _uploadImageUsecase = ref.read(uploadImageUsecaseProvider);
    return const UploadImageState();
  }

  
  Future<void> uploadPhoto(File photo) async{
    state = state.copyWith(status: UploadImageStatus.loading);

    final result = await _uploadImageUsecase(photo);
    result.fold(
      (Failure){
        state = state.copyWith(
          status: UploadImageStatus.error,
          errorMessage: Failure.message,
        );
      },
      (imageName){
        state = state.copyWith(
          status: UploadImageStatus.loaded,
          uploadPhotoName: imageName,
        );
      },);
  }
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  
}


