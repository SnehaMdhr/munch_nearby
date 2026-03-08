import 'package:equatable/equatable.dart';

class UploadImageEntity extends Equatable {
  final String? media; 
  final String? mediaType; 

  const UploadImageEntity({
    this.media,
    this.mediaType,
  });

  @override
  List<Object?> get props => [
        media,
        mediaType,
      ];
}
