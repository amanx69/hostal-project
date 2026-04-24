import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/chat/domain/models/chat_message.dart';
import '../../../../core/network/dio_client.dart';
import '../domain/models/chat_room.dart';
import '../domain/models/user_summary.dart';

final chatApiProvider = Provider((ref) => ChatApi(ref.read(dioProvider)));

class ChatApi {
  final Dio _dio;
  ChatApi(this._dio);

  Future<List<ChatRoom>> getChatRooms() async {
    final res = await _dio.get('/api/chats/roomlist/');
    final data = res.data;
    if (data['success'] == true) {
      final List rooms = data['rooms'] ?? [];
      return rooms.map((r) => ChatRoom.fromJson(r)).toList();
    }
    return [];
  }

  Future<ChatRoom> createOrGetRoom(int user2Id) async {
    final res = await _dio.post('/api/chats/create_chat/', data: {
      'user2_id': user2Id,
    });
    final data = res.data;
    if (data['success'] == true) {
      return ChatRoom.fromJson(data['userdata']);
    }
    throw Exception(data['message'] ?? 'Failed to open chat');
  }

  Future<List<ChatMessage>> getMessages(int roomId) async {
    final res = await _dio.get('/api/chats/$roomId/messages/');
    final data = res.data;
    if (data['success'] == true) {
      final List msgs = data['messages'] ?? [];
      return msgs.map((m) => ChatMessage.fromJson(m)).toList();
    }
    return [];
  }

  Future<List<UserSummary>> getFollowers(int userId) async {
    final res = await _dio.get('/api/posts/followers/$userId/');
    final data = res.data;
    if (data['success'] == true) {
      final List users = data['followers'] ?? [];
      return users.map((u) => UserSummary.fromJson(u)).toList();
    }
    return [];
  }

  Future<List<UserSummary>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    final res = await _dio.get('/api/auth/search/?q=$query');
    final data = res.data;
    if (data['success'] == true) {
      final List users = data['users'] ?? [];
      return users.map((u) => UserSummary.fromJson(u)).toList();
    }
    return [];
  }

  Future<int> createGroup(String name) async {
    final res = await _dio.post('/api/chats/create_groupe/', data: {
      'groupe_name': name,
    });
    final data = res.data;
    if (data['success'] == true) {
      return data['groupe_id'];
    }
    throw Exception(data['message'] ?? 'Failed to create group');
  }

  Future<void> addGroupMembers(int groupId, List<int> userIds) async {
    final res = await _dio.post('/api/chats/$groupId/add_users/', data: {
      'users': userIds,
    });
    // Assuming backend returns 200/201 on success
  }
}
