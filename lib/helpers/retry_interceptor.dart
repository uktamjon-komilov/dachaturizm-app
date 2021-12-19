import 'dart:io';

import 'package:dachaturizm/helpers/dio_connectivity_request_retrier.dart';
import 'package:dio/dio.dart';

class RetryOnConnectionChangeInterceptor extends Interceptor {
  final DioConnectivityRequestRetrier requestRetrier;

  RetryOnConnectionChangeInterceptor({
    required this.requestRetrier,
  });

  @override
  Future onError(DioError err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      try {
        final response =
            await requestRetrier.scheduleRequestRetry(err.requestOptions);
        handler.resolve(response);
        // return ;
      } catch (e) {
        print(e);
        return requestRetrier.scheduleRequestRetry(err.requestOptions);
      }
    }
    return err;
  }

  bool _shouldRetry(DioError err) {
    return err.type == DioErrorType.other &&
        err.error != null &&
        err.error is SocketException;
  }
}
