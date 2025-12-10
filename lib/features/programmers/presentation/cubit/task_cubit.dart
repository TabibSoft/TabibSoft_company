import 'package:bloc/bloc.dart';
import 'package:tabib_soft_company/features/programmers/data/model/section_model.dart';
import 'package:tabib_soft_company/features/programmers/data/repo/task_repository.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository _taskRepository;

  TaskCubit(this._taskRepository)
      : super(const TaskState(
          TaskStatus.initial,
          [],
          null,
          null,
          sections: [],
        ));

  Future<void> fetchTasks() async {
    emit(state.copyWith(status: TaskStatus.loading));
    final result = await _taskRepository.getAllTasks();
    result.when(
      success: (tasks) {
        // استخراج الـ sections من المهام
        final sections = tasks.map((task) {
          return SectionModel(
            id: task.id,
            name: task.name,
            isTest: false,
          );
        }).toList();

        emit(state.copyWith(
          status: TaskStatus.success,
          tasks: tasks,
          sections: sections,
        ));
      },
      failure: (error) {
        emit(state.copyWith(
          status: TaskStatus.failure,
          errorMessage: error.errMessages,
        ));
      },
    );
  }

  Future<void> fetchTaskById(String id) async {
    emit(state.copyWith(status: TaskStatus.loading));
    final result = await _taskRepository.getTaskById(id);
    result.when(
      success: (task) {
        emit(state.copyWith(
          status: TaskStatus.success,
          selectedTask: task,
        ));
      },
      failure: (error) {
        emit(state.copyWith(
          status: TaskStatus.failure,
          errorMessage: error.errMessages,
        ));
      },
    );
  }
}
