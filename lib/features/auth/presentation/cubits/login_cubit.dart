import 'package:bloc/bloc.dart';
import 'package:tabib_soft_company/features/auth/data/repos/login_repo.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginReposetory _repo;

  LoginCubit(LoginReposetory repo)
      : _repo = repo,
        super(const LoginState());


  Future<void> login({
    required String email,
    required String password,
    required String dKey,
  }) async {
    emit(state.copyWith(status: LoginStatus.loading, error: null));
    try {
      final result = await _repo.login(
        email: email,
        password: password,
        dKey: dKey,
      );
      emit(state.copyWith(status: LoginStatus.success, data: result));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
