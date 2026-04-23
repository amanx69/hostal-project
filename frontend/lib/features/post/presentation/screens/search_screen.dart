import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/post_providers.dart';
import '../widgets/post_card.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Filter posts by query
    final results = _query.trim().isEmpty
        ? <dynamic>[]
        : feedState.posts.where((p) {
            final q = _query.toLowerCase();
            final title = (p.title ?? '').toLowerCase();
            final desc = (p.description ?? '').toLowerCase();
            final user = (p.postUser?.username ?? '').toLowerCase();
            return title.contains(q) || desc.contains(q) || user.contains(q);
          }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.cardDark : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        // Icon-only brand logo
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.brandGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.apartment_rounded,
                color: Colors.white, size: 18),
          ),
        ),
        title: _SearchBar(
          controller: _ctrl,
          onChanged: (v) => setState(() => _query = v),
          isDark: isDark,
          cs: cs,
        ),
        titleSpacing: 4,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Divider(
            height: 0.5,
            thickness: 0.5,
            color: isDark
                ? AppColors.borderDark
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
      ),
      body: _query.trim().isEmpty
          ? _EmptySearch(isDark: isDark, theme: theme, cs: cs)
          : results.isEmpty
              ? _NoResults(query: _query, isDark: isDark, theme: theme, cs: cs)
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 90),
                  itemCount: results.length,
                  itemBuilder: (_, i) {
                    final post = results[i];
                    return PostCard(
                      key: ValueKey(post.id),
                      post: post,
                      onLike: () =>
                          ref.read(feedProvider.notifier).toggleLike(post.id),
                      onCommentSubmit: (text) =>
                          ref.read(feedProvider.notifier).addComment(post.id, text),
                      onUserTap: () =>
                          context.push('/feed/profile/${post.authorUserId}'),
                    ).animate().fadeIn(
                          duration: 300.ms,
                          delay: Duration(milliseconds: i * 40),
                        );
                  },
                ),
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isDark;
  final ColorScheme cs;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.isDark,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.borderDark.withValues(alpha: 0.6)
            : AppColors.borderLight.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: false,
        style: TextStyle(
          fontSize: 14,
          color: cs.onSurface,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: 'Search posts, people…',
          hintStyle: TextStyle(
            color: cs.onSurface.withValues(alpha: 0.4),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: cs.onSurface.withValues(alpha: 0.4),
            size: 20,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    controller.clear();
                    onChanged('');
                  },
                  child: Icon(
                    Icons.close_rounded,
                    color: cs.onSurface.withValues(alpha: 0.4),
                    size: 18,
                  ),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        ),
      ),
    );
  }
}

// ─── Empty Search ─────────────────────────────────────────────────────────────

class _EmptySearch extends StatelessWidget {
  final bool isDark;
  final ThemeData theme;
  final ColorScheme cs;

  const _EmptySearch(
      {required this.isDark, required this.theme, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.12),
                  AppColors.accent.withValues(alpha: 0.08),
                ],
              ),
            ),
            child: Icon(
              Icons.search_rounded,
              size: 36,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Search Hostal',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find posts, people, and more.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.35),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}

// ─── No Results ───────────────────────────────────────────────────────────────

class _NoResults extends StatelessWidget {
  final String query;
  final bool isDark;
  final ThemeData theme;
  final ColorScheme cs;

  const _NoResults({
    required this.query,
    required this.isDark,
    required this.theme,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded,
              size: 48, color: cs.onSurface.withValues(alpha: 0.2)),
          const SizedBox(height: 12),
          Text(
            'No results for "$query"',
            style: theme.textTheme.titleSmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.45),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different search term.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms),
    );
  }
}
