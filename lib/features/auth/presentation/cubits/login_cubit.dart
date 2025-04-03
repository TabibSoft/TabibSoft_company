import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/auth/data/repos/login_repo.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepository repository;

  LoginCubit({required this.repository}) : super(LoginState());

  Future<void> login({
    required String username,
    required String password,
    required String token,
  }) async {
    emit(state.copyWith(status: LoginStatus.loading));
    final result = await repository.login(
      username: username,
      password: password,
      token: token,
    );
    result.when(
      success: (loginModel) {
        emit(state.copyWith(status: LoginStatus.success, loginModel: loginModel));
      },
      failure: (error) {
        emit(state.copyWith(status: LoginStatus.failure, error: error.errMessages));
      },
    );
  }
}
