import "package:freezed_annotation/freezed_annotation.dart";

import "../../domain/entities/auth_tokens.dart";

part "auth_tokens_model.freezed.dart";
part "auth_tokens_model.g.dart";

@freezed
class AuthTokensModel with _$AuthTokensModel {
  const factory AuthTokensModel({
    required String access,
    required String refresh,
  }) = _AuthTokensModel;

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensModelFromJson(json);
}

extension AuthTokensModelMapper on AuthTokensModel {
  AuthTokens toEntity() =>
      AuthTokens(accessToken: access, refreshToken: refresh);
}

