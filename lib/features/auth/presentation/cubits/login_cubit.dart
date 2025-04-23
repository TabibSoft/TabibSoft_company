import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabib_soft_company/features/auth/data/repos/login_repo.dart';

import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginReposetory _repo;

  LoginCubit(this._repo) : super(LoginState.initial);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  Future<void> login({
    required String dKey,
  }) async {
    emit(state.copyWith(status: LoginStatus.loading));

    final result = await _repo.login(
        email: emailController.text,
        password: passController.text,
        dKey: 'dKey' // TODO: Add dKey,
        );

    result.when(
      success: (data) {
        emit(
          state.copyWith(
            status: LoginStatus.success,
            data: data,
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            status: LoginStatus.failure,
            error: error.errMessages,
          ),
        );
      },
    );
  }
}
