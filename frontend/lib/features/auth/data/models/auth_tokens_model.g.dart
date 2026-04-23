// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_tokens_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthTokensModelImpl _$$AuthTokensModelImplFromJson(
  Map<String, dynamic> json,
) => _$AuthTokensModelImpl(
  access: json['access'] as String,
  refresh: json['refresh'] as String,
);

Map<String, dynamic> _$$AuthTokensModelImplToJson(
  _$AuthTokensModelImpl instance,
) => <String, dynamic>{'access': instance.access, 'refresh': instance.refresh};
