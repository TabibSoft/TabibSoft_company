import 'package:json_annotation/json_annotation.dart';

part 'login_model.g.dart';

@JsonSerializable()
class LoginModel {
  final String token;
  final User user;

  LoginModel({required this.token, required this.user});

  factory LoginModel.fromJson(Map<String, dynamic> json) => _$LoginModelFromJson(json);
  Map<String, dynamic> toJson() => _$LoginModelToJson(this);
}

@JsonSerializable()
class User {
  @JsonKey(name: 'userId')
  final String id;

  @JsonKey(name: 'userName')
  final String name;

  final String email;

  @JsonKey(name: 'roles')
  final List<String> roles;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}



