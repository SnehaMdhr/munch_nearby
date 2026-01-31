import 'dart:io';


abstract interface class IUploadImageRemoteDatasource{
  Future<String> uploadImage(File image);
}
