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
    // 1. جلب البيانات المخبأة محلياً لعرضها فوراً وتقليل وقت الانتظار
    final cachedTasks = _taskRepository.getCachedTasks();
    if (cachedTasks != null && cachedTasks.isNotEmpty) {
      final sections = cachedTasks.map((task) {
        return SectionModel(
          id: task.id,
          name: task.name,
          isTest: false,
        );
      }).toList();

      emit(state.copyWith(
        status: TaskStatus.success,
        tasks: cachedTasks,
        sections: sections,
      ));
      // لا نستخدم return هنا لأننا نريد تحديث البيانات من الـ API أيضاً
    } else {
      // إذا لم يوجد كاش، نظهر الـ loading كالمعتاد
      emit(state.copyWith(status: TaskStatus.loading));
    }

    // 2. طلب البيانات الفعلية من الـ API لتحديث الصفحة بأحدث المهام
    final result = await _taskRepository.getAllTasks();
    result.when(
      success: (tasks) {
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
        // إذا كانت هناك بيانات قديمة معروضة، لا نظهر الخطأ للمستخدم لتجنب الإزعاج
        if (state.tasks.isEmpty) {
          emit(state.copyWith(
            status: TaskStatus.failure,
            errorMessage: error.errMessages,
          ));
        }
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
