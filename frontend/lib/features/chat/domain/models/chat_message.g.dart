// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      senderId: (json['sender_id'] as num).toInt(),
      roomId: (json['room_id'] as num).toInt(),
      senderEmail: json['sender_email'] as String?,
      message: json['message'] as String,
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'sender_id': instance.senderId,
      'room_id': instance.roomId,
      'sender_email': instance.senderEmail,
      'message': instance.message,
    };
