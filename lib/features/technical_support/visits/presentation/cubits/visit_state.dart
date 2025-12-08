import 'package:tabib_soft_company/features/technical_support/visits/data/models/visit_model.dart';

// تعريف VisitStatus enum
enum VisitStatus {
  initial,
  loading,
  loaded,
  error,
}

class VisitState {
  final VisitStatus status;
  final List<VisitModel> visits;
  final String? errorMessage;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  const VisitState({
    this.status = VisitStatus.initial,
    this.visits = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMore = true,
  });

  VisitState copyWith({
    VisitStatus? status,
    List<VisitModel>? visits,
    String? errorMessage,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
  }) {
    return VisitState(
      status: status ?? this.status,
      visits: visits ?? this.visits,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
