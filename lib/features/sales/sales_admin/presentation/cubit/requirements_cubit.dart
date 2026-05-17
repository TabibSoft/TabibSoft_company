import 'package:flutter_bloc/flutter_bloc.dart';
import 'requirements_state.dart';
import '../../data/models/requirement_model.dart';
import '../../data/repos/requirements_repo.dart';

class RequirementsCubit extends Cubit<RequirementsState> {
  final RequirementsRepository _repository;

  RequirementsCubit(this._repository) : super(const RequirementsState());

  // دالة لجلب البيانات من API
  Future<void> fetchRequirements({
    required int page,
    required int pageSize,
    String? fromDate,
    String? toDate,
    String? salesPersonId,
    String? statusName,
    String? name,
    bool isRefresh = false,
  }) async {
    if (isRefresh) {
      emit(state.copyWith(
        status: RequirementsStatus.loading,
        requirements: [],
        currentPage: 1,
      ));
    } else if (page == 1) {
      emit(state.copyWith(status: RequirementsStatus.loading));
    } else {
      emit(state.copyWith(status: RequirementsStatus.loadingMore));
    }

    try {
      final body = {
        "from": fromDate ??
            DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        "to": toDate ?? DateTime.now().toIso8601String(),
        "salesId": salesPersonId,
        "statusName": statusName,
        "name": name,
        "search": name, // Adding search as it's common in other APIs
      };

      final response = await _repository.getRequirementsData(body);

      // تطبيق الفلترة المحلية لضمان ظهور النتائج حتى لو لم يدعمها الـ API بشكل كامل
      var filteredData = response.data;
      if (name != null && name.trim().isNotEmpty) {
        final query = name.trim().toLowerCase();
        filteredData = response.data.where((item) {
          return item.customerName.toLowerCase().contains(query) ||
              item.salesPersonName.toLowerCase().contains(query) ||
              (item.programName.toLowerCase().contains(query)) ||
              (item.note?.toLowerCase().contains(query) ?? false);
        }).toList();
      }

      final newRequirements = isRefresh || page == 1
          ? filteredData
          : [...state.requirements, ...filteredData];

      emit(state.copyWith(
        status: RequirementsStatus.loaded,
        requirements: newRequirements,
        statusCounts: response.statusCounts ?? [],
        currentPage: page,
        totalPages: response.totalPages ?? 1,
        totalRecords: response.totalRecords ?? response.data.length,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RequirementsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // دالة لجلب قائمة مندوبي المبيعات (المهندسين)
  Future<void> fetchSalesPersons() async {
    try {
      final engineers = await _repository.getAllEngineers();

      final salesPersons = engineers
          .map((e) => SalesPerson(
                id: e.id ?? '',
                name: e.name ?? '',
                telephone: e.telephone,
              ))
          .toList();

      emit(state.copyWith(salesPersons: salesPersons));
    } catch (e) {
      // في حالة الفشل، نبقي القائمة فارغة
    }
  }

  // دالة لتحديث ملاحظة الأدمن
  Future<void> updateAdminNote({
    required String requirementId,
    required String measurementId,
    required String note,
  }) async {
    try {
      final body = {
        "requirementId": requirementId,
        "measurementId": measurementId,
        "adminNote": note,
      };

      await _repository.updateAdminNote(body);

      // تحديث البيانات المحلية بعد النجاح
      final updatedRequirements = state.requirements.map((req) {
        if (req.id == requirementId) {
          return RequirementReport(
            id: req.id,
            measurementId: req.measurementId,
            customerName: req.customerName,
            salesPersonName: req.salesPersonName,
            note: req.note,
            programName: req.programName,
            creationDate: req.creationDate,
            nextCallDate: req.nextCallDate,
            imagesList: req.imagesList,
            adminNote: note,
            adminNoteUser: req.adminNoteUser,
            adminNoteDate: DateTime.now().toIso8601String(),
            statusName: req.statusName,
            statusColor: req.statusColor,
          );
        }
        return req;
      }).toList();

      emit(state.copyWith(requirements: updatedRequirements));
    } catch (e) {
      // يمكن إضافة معالجة الأخطاء هنا مثل إظهار Toast
    }
  }
}
