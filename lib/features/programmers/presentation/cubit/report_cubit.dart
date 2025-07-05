import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/programmers/data/model/task_update_model.dart';
import 'package:tabib_soft_company/features/programmers/data/repo/report_repository.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final ReportRepository _reportRepository;

  ReportCubit(this._reportRepository) : super(const ReportState());

  Future<void> markReportAsDone(String reportId) async {
    emit(state.copyWith(status: ReportStatus.loading));
    final result = await _reportRepository.markReportAsDone(reportId);
    result.when(
      success: (_) {
        emit(state.copyWith(status: ReportStatus.success));
      },
      failure: (error) {
        emit(state.copyWith(status: ReportStatus.failure, errorMessage: error.errMessages));
      },
    );
  }

  Future<void> updateTask(TaskUpdateModel task) async {
    emit(state.copyWith(status: ReportStatus.loading));
    final result = await _reportRepository.updateTask(task);
    result.when(
      success: (_) {
        emit(state.copyWith(status: ReportStatus.success));
      },
      failure: (error) {
        emit(state.copyWith(status: ReportStatus.failure, errorMessage: error.errMessages));
      },
    );
  }
}