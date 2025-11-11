// New File: lib/features/home/data/repos/notifications/notification_repo.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/features/sales/notifications/data/model/notification_model.dart';

class NotificationRepository {
  final ApiService _apiService;

  NotificationRepository(this._apiService);

  Future<Either<ServerFailure, List<NotificationModel>>> getNotifications() async {
    try {
      final response = await _apiService.getNotifications();
      return Right(response);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  
}