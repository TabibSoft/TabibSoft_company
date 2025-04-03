import 'package:meta/meta.dart';
import 'package:tabib_soft_company/features/auth/data/models/login_model.dart';
enum LoginStatus { initial, loading, success, failure }

class LoginState {
  final LoginStatus status;
  final LoginModel? loginModel;
  final String? error;

  LoginState({
    this.status = LoginStatus.initial,
    this.loginModel,
    this.error,
  });

  LoginState copyWith({
    LoginStatus? status,
    LoginModel? loginModel,
    String? error,
  }) {
    return LoginState(
      status: status ?? this.status,
      loginModel: loginModel ?? this.loginModel,
      error: error ?? this.error,
    );
  }
}
