import 'package:equatable/equatable.dart';
import 'package:tabib_soft_company/features/auth/data/models/login_response.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  final LoginStatus? status;
  final LoginResponse? data;
  final String? error;

  const LoginState({
    this.status,
    this.data,
    this.error,
  });

  static LoginState initial = const LoginState(
    status: LoginStatus.initial,
    data: null,
    error: '',
  );

  LoginState copyWith({
    LoginStatus? status,
    LoginResponse? data,
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

  @override
  String toString() =>
      'LoginState(status: $status, data: $data, error: $error)';
}
