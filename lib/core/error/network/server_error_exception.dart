part of '../app_exception.dart';

final class ServerErrorException extends NetworkException {
  const ServerErrorException(this.statusCode);

  final int statusCode;
}
