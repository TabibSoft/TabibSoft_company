import 'package:equatable/equatable.dart';
import 'package:tabib_soft_company/features/programmers/data/model/customization_task_model.dart';
import 'package:tabib_soft_company/features/programmers/data/model/task_details_model.dart';

enum TaskStatus { initial, loading, success, failure }

class TaskState extends Equatable {
  final TaskStatus status;
  final List<CustomizationTaskModel> tasks;
  final TaskDetailsModel? selectedTask;
  final String? errorMessage;

  const TaskState({
    this.status = TaskStatus.initial,
    this.tasks = const [],
    this.selectedTask,
    this.errorMessage,
  });

  TaskState copyWith({
    TaskStatus? status,
    List<CustomizationTaskModel>? tasks,
    TaskDetailsModel? selectedTask,
    String? errorMessage,
  }) {
    return TaskState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      selectedTask: selectedTask ?? this.selectedTask,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, tasks, selectedTask, errorMessage];
}