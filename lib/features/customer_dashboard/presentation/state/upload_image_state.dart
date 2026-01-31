import 'package:equatable/equatable.dart';

enum UploadImageStatus { initial, loading, loaded, error, created, updated, deleted }

class UploadImageState extends Equatable {
  final UploadImageStatus status;
  final String? errorMessage;
  final String? uploadPhotoName;

  const UploadImageState({
    this.status = UploadImageStatus.initial,
    this.uploadPhotoName,
    this.errorMessage,
  });

  UploadImageState copyWith({
    UploadImageStatus? status,
    String? uploadPhotoName,
    String? errorMessage,
  }) {
    return UploadImageState(
      status: status ?? this.status,
      uploadPhotoName: uploadPhotoName ?? this.uploadPhotoName,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage,uploadPhotoName];
}
