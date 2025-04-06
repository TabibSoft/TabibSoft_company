import 'package:equatable/equatable.dart';
import 'package:tabib_soft_company/features/auth/data/models/login_model.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  final LoginStatus status;
  final LoginModel? data;
  final String? error;

  const LoginState({
    this.status = LoginStatus.initial,
    this.data,
    this.error,
  });

  LoginState copyWith({
    LoginStatus? status,
    LoginModel? data,
    String? error,
  }) {
    return LoginState(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, data, error];
}
