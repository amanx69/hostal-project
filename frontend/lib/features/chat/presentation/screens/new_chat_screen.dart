import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/chat/data/chat_api.dart';
import 'package:frontend/features/chat/domain/models/user_summary.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/chat_providers.dart';


class NewChatScreen extends ConsumerStatefulWidget {
  const NewChatScreen({super.key});

  @override
  ConsumerState<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends ConsumerState<NewChatScreen> {
  bool _isCreatingGroup = false;
  final Set<int> _selectedUserIds = {};
  final TextEditingController _groupNameCtrl = TextEditingController();
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isSubmitting = false;
  List<UserSummary> _searchResults = [];
  bool _isSearching = false;

  void _onSearchChanged(String query) async {
    if (query.trim().isEmpty) {
      if (mounted) setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    if (mounted) setState(() => _isSearching = true);
    try {
      final api = ref.read(chatApiProvider);
      final results = await api.searchUsers(query);
      if (mounted) setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _toggleGroupMode() {
    setState(() {
      _isCreatingGroup = !_isCreatingGroup;
      _selectedUserIds.clear();
      _groupNameCtrl.clear();
    });
  }

  void _onUserTapped(UserSummary user) async {
    if (_isCreatingGroup) {
      setState(() {
        if (_selectedUserIds.contains(user.id)) {
          _selectedUserIds.remove(user.id);
        } else {
          _selectedUserIds.add(user.id);
        }
      });
    } else {
      // 1-on-1 chat
      setState(() => _isSubmitting = true);
      try {
        final api = ref.read(chatApiProvider);
        final room = await api.createOrGetRoom(user.id);
        if (mounted) {
          final name = user.username ?? user.email;
          context.pushReplacement('/chat/${room.id}?name=$name');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _createGroup() async {
    final name = _groupNameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Group name cannot be empty')));
      return;
    }
    if (_selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select at least one member')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final api = ref.read(chatApiProvider);
      final groupId = await api.createGroup(name);
      await api.addGroupMembers(groupId, _selectedUserIds.toList());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Group created successfully')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    final followersAsync = ref.watch(chatFollowersProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      appBar: AppBar(
        title: Text(_isCreatingGroup ? 'New Group' : 'New Chat'),
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        actions: [
          if (!_isCreatingGroup)
            TextButton(
              onPressed: _toggleGroupMode,
              child: const Text('Create Group'),
            ),
          if (_isCreatingGroup)
            TextButton(
              onPressed: _selectedUserIds.isNotEmpty ? _createGroup : null,
              child: _isSubmitting 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Text('Create'),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_isCreatingGroup)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _groupNameCtrl,
                decoration: InputDecoration(
                  hintText: 'Group Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceDark : Colors.grey[100],
                ),
              ),
            ),
            
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: _isCreatingGroup ? 0 : 16.0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search username or email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: isDark ? AppColors.surfaceDark : Colors.grey[100],
              ),
            ),
          ),
          
          Expanded(
            child: _searchCtrl.text.trim().isNotEmpty
              ? _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                  ? const Center(child: Text('No users found.'))
                  : ListView.separated(
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final user = _searchResults[index];
                        final isSelected = _selectedUserIds.contains(user.id);
                        return ListTile(
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                child: const Icon(Icons.person, color: AppColors.primary),
                              ),
                              if (_isCreatingGroup && isSelected)
                                const Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: CircleAvatar(
                                    radius: 8,
                                    backgroundColor: Colors.green,
                                    child: Icon(Icons.check, size: 10, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                          title: Text(user.username ?? user.email.split('@').first),
                          subtitle: Text(user.email),
                          onTap: () => _onUserTapped(user),
                        );
                      },
                    )
              : followersAsync.when(
              data: (users) {
                if (users.isEmpty) {
                  return const Center(child: Text('You have no followers to chat with.'));
                }
                return ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final isSelected = _selectedUserIds.contains(user.id);
                    
                    return ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: const Icon(Icons.person, color: AppColors.primary),
                          ),
                          if (_isCreatingGroup && isSelected)
                            const Positioned(
                              right: 0,
                              bottom: 0,
                              child: CircleAvatar(
                                radius: 8,
                                backgroundColor: Colors.green,
                                child: Icon(Icons.check, size: 10, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                      title: Text(user.username ?? user.email.split('@').first),
                      subtitle: Text(user.email),
                      onTap: () => _onUserTapped(user),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed to load followers: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
