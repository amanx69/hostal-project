import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/chat/data/chat_api.dart';
import 'package:frontend/features/chat/domain/models/chat_message.dart';
import 'package:frontend/features/chat/domain/models/chat_room.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/token_storage_service.dart';
import 'package:frontend/features/post/presentation/providers/post_providers.dart';
import 'package:frontend/features/chat/domain/models/user_summary.dart';

final chatRoomsProvider = FutureProvider.autoDispose<List<ChatRoom>>((ref) async {
  final api = ref.read(chatApiProvider);
  return api.getChatRooms();
});

final chatFollowersProvider = FutureProvider.autoDispose<List<UserSummary>>((ref) async {
  final api = ref.read(chatApiProvider);
  final myProfile = ref.watch(myProfileProvider);
  final userId = myProfile.profile?.userId;
  if (userId == null) return [];
  return api.getFollowers(userId);
});

final chatHistoryProvider = FutureProvider.family.autoDispose<List<ChatMessage>, int>((ref, roomId) async {
  final api = ref.read(chatApiProvider);
  return api.getMessages(roomId);
});

final chatWebSocketProvider =
    StreamProvider.family.autoDispose<ChatMessage, int>((ref, roomId) async* {
  final token = await ref.read(tokenStorageProvider).readAccessToken();
  final wsUrl = AppConstants.apiBaseUrl
      .replaceFirst('http', 'ws')
      .replaceFirst('https', 'wss');

  final channel = WebSocketChannel.connect(
    Uri.parse('$wsUrl/ws/chat/$roomId/?token=$token'),
  );

  ref.onDispose(() => channel.sink.close());

  await for (final message in channel.stream) {
    if (message is String) {
      try {
        final decoded = jsonDecode(message);
        // The server sends {"message": "...", "sender_id": ..., "room_id": ...}
        if (decoded.containsKey('message') && decoded.containsKey('sender_id')) {
          yield ChatMessage.fromJson(decoded);
        }
      } catch (e) {
        // ignore raw text like "you are connected to chat_1"
      }
    }
  }
});

final chatMessageSenderProvider = Provider.family.autoDispose<Function(String), int>((ref, roomId) {
  return (String text) async {
    final token = await ref.read(tokenStorageProvider).readAccessToken();
    final wsUrl = AppConstants.apiBaseUrl
        .replaceFirst('http', 'ws')
        .replaceFirst('https', 'wss');

    final channel = WebSocketChannel.connect(
      Uri.parse('$wsUrl/ws/chat/$roomId/?token=$token'),
    );

    channel.sink.add(jsonEncode({'message': text}));
    
    // wait slightly to let message send before closing
    await Future.delayed(const Duration(milliseconds: 200));
    channel.sink.close();
  };
});
