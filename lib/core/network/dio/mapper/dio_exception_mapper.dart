import 'package:crypto_informer/core/error/app_exception.dart';
import 'package:crypto_informer/core/network/dio/mapper/dio_http_exception_mapper.dart';
import 'package:crypto_informer/core/network/dio/mapper/dio_transport_exception_mapper.dart';
import 'package:dio/dio.dart';

extension DioExceptionMapper on DioException {
  AppException toAppException() =>
      tryMapHttpException() ?? mapTransportException();
}
