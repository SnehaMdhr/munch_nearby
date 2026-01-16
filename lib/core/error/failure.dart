import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable{
  final String message;
  const Failure (this.message);

  @override
  List<Object> get props => [message];
}


class LocalDatabaseFailure extends Failure{
  LocalDatabaseFailure({
    String message = "Local database operation failure",
  }): super(message);
}

class ApiFailure extends Failure{
  final int? statusCode;
  ApiFailure({
    required String message,
    this.statusCode,
  }) : super(message);
}