import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tabib_soft_company/core/networking/api_error_handler.dart';
import 'package:tabib_soft_company/core/networking/api_service.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/data/models/notes/add_note_model.dart';

class AddNoteRepository {
  final ApiService _apiService;

  AddNoteRepository(this._apiService);

  Future<Either<ServerFailure, void>> addNote(AddNoteDto dto) async {
    try {
      final imageFiles = dto.imageFiles != null && dto.imageFiles!.isNotEmpty
          ? await Future.wait(
              dto.imageFiles!.map((path) async {
                // Normalize path separators for cross-platform compatibility
                final normalizedPath = path.replaceAll(r'\', '/');
                return await MultipartFile.fromFile(normalizedPath);
              }).toList())
          : null;
      await _apiService.addRequirement(
        dto.measurementId,
        dto.notes,
        dto.expectedCallDate?.toIso8601String(),
        dto.expectedCallTimeFrom,
        dto.expectedCallTimeTo,
        imageFiles,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }
}