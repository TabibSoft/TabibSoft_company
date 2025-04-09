import 'package:dio/dio.dart';

abstract class ApiError {
  final String errMessages;
  final Map<String, dynamic>? details;

  const ApiError(this.errMessages, {this.details});
}

class ServerFailure extends ApiError {
  ServerFailure(super.errMessages);

  factory ServerFailure.fromDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return ServerFailure('Connection timeout with Api Server');

      case DioExceptionType.sendTimeout:
        return ServerFailure('Send timeout with ApiServer');

      case DioExceptionType.receiveTimeout:
        return ServerFailure('Receive timeout with ApiServer');

      case DioExceptionType.badCertificate:
        return ServerFailure("Dad Certificate with api server");

      case DioExceptionType.badResponse:
        return ServerFailure.fromResponse(
            e.response!.statusCode!, e.response!.data);

      case DioExceptionType.cancel:
        return ServerFailure('Request to ApiServer was canceld');

      case DioExceptionType.connectionError:
        return ServerFailure('No Internet Connection');

      case DioExceptionType.unknown:
        return ServerFailure('unknown');

      default:
        return ServerFailure('Opps There was an Error, Please try again');
    }
  }

factory ServerFailure.fromResponse(int statusCode, dynamic response) {
  String message;
  if (statusCode == 401) {
    message = 'Unauthorized access, please log in.'; // رسالة مخصصة لـ 401
  } else if (statusCode == 404) {
    message = 'Resource not found.';
  } else if (statusCode == 500) {
    message = 'Server error, please try later.';
  } else {
    if (response is String) {
      message = response; // إذا كان response نصًا، استخدمه مباشرة
    } else if (response is Map && response.containsKey('message')) {
      message = response['message']; // استخراج الرسالة من Map إذا وجدت
    } else {
      message = 'Error $statusCode'; // رسالة افتراضية مع رمز الحالة
    }
  }
  return ServerFailure(message);
}

  // factory ServerFailure.fromResponse(int statusCode, dynamic response) {
  //   if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
  //     return ServerFailure(response);
  //   } else if (statusCode == 404) {
  //     return ServerFailure('Your request not found, Please try later!');
  //   } else if (statusCode == 500) {
  //     return ServerFailure(
  //         'There is the problem with server, Please try later');
  //   } else {
  //     return ServerFailure('Opps There was an Error, Please try again');
  //   }
  // }
}
