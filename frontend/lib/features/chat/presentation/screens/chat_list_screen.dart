import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/chat_providers.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    final roomsAsync = ref.watch(chatRoomsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: roomsAsync.when(
        data: (rooms) {
          if (rooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 60, color: cs.onSurface.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('No messages yet', style: TextStyle(color: cs.onSurface.withOpacity(0.5))),
                ],
              ),
            );
          }
          return ListView.separated(
            itemCount: rooms.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final room = rooms[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Icon(Icons.person, color: AppColors.primary),
                ),
                title: Text(room.secondUser?['username'] ?? room.secondUser?['email']?.split('@').first ?? 'Room ${room.id}'),
                subtitle: const Text('Tap to open chat...'),
                onTap: () {
                  final name = room.secondUser?['username'] ?? room.secondUser?['email']?.split('@').first ?? 'Room ${room.id}';
                  context.push('/chat/${room.id}?name=$name');
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/chat/new'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.chat_rounded, color: Colors.white),
      ),
    );
  }
}
