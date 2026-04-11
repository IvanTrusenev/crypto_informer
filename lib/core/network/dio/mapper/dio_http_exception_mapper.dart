import 'package:crypto_informer/core/error/app_exception.dart';
import 'package:dio/dio.dart';

extension DioHttpExceptionMapper on DioException {
  AppException? tryMapHttpException() {
    if (response?.statusCode == 401) {
      return const UnauthorizedException();
    }

    if (response?.statusCode == 429) {
      return const TooManyRequestsException();
    }

    if (response?.statusCode == 404) {
      return const NotFoundException();
    }

    return null;
  }
}
