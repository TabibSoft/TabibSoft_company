import 'package:json_annotation/json_annotation.dart';

part 'login_req.g.dart';


@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;
  final String dKey;

  LoginRequest({
    required this.email,
    required this.password,
    required this.dKey,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}
