import 'package:crypto_informer/core/error/app_exception.dart';
import 'package:dio/dio.dart';

extension DioTransportExceptionMapper on DioException {
  AppException mapTransportException() {
    final status = response?.statusCode;

    if (type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout) {
      return const NetworkTimeoutException();
    }

    if (status != null) {
      return ServerErrorException(status);
    }

    return const NetworkUnavailableException();
  }
}
