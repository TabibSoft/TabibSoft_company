import 'package:tabib_soft_company/features/programmers/data/model/customization_task_model.dart';
import 'package:tabib_soft_company/features/programmers/data/model/task_details_model.dart';
import 'package:tabib_soft_company/features/programmers/data/model/section_model.dart';

enum TaskStatus { initial, loading, success, failure }

class TaskState {
  final TaskStatus status;
  final List<CustomizationTaskModel> tasks;
  final TaskDetailsModel? selectedTask;
  final String? errorMessage;
  final List<SectionModel> sections;

  const TaskState(
    this.status,
    this.tasks,
    this.selectedTask,
    this.errorMessage, {
    this.sections = const [],
  });

  TaskState copyWith({
    TaskStatus? status,
    List<CustomizationTaskModel>? tasks,
    TaskDetailsModel? selectedTask,
    String? errorMessage,
    List<SectionModel>? sections,
  }) {
    return TaskState(
      status ?? this.status,
      tasks ?? this.tasks,
      selectedTask ?? this.selectedTask,
      errorMessage ?? this.errorMessage,
      sections: sections ?? this.sections,
    );
  }
}
