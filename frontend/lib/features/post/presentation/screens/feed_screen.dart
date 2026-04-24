import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/post_providers.dart';
import '../widgets/post_card.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  bool _isRefreshing = false;

  Future<void> _refresh() async {
    if (_isRefreshing) return;
    HapticFeedback.mediumImpact();
    setState(() => _isRefreshing = true);
    await ref.read(feedProvider.notifier).fetchFeed();
    if (mounted) setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);
    final myProfile = ref.watch(myProfileProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Do not filter out current user's own posts
    final filteredPosts = feedState.posts;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,

      // ── Global narrow fixed AppBar ────────────────────────────────────────
      appBar: _FeedAppBar(
        isDark: isDark,
        cs: cs,
        isRefreshing: _isRefreshing,
        onRefresh: _refresh,
        onLogout: () => _confirmLogout(context, ref),
      ),

      // ── Body — pull-to-refresh via NotificationListener ───────────────────
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          // Trigger refresh when user over-scrolls past threshold
          if (notification is OverscrollNotification &&
              notification.overscroll < -60 &&
              !_isRefreshing) {
            _refresh();
          }
          return false;
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // ── Error banner ────────────────────────────────────────────────
            if (feedState.error != null)
              SliverToBoxAdapter(
                child: _ErrorBanner(
                  error: feedState.error!,
                  onRetry: () => ref.read(feedProvider.notifier).fetchFeed(),
                  theme: theme,
                ).animate().fadeIn(duration: 300.ms),
              ),

            // ── Loading skeletons ───────────────────────────────────────────
            if (feedState.isLoading && feedState.posts.isEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => const _IgPostSkeleton(),
                  childCount: 5,
                ),
              ),

            // ── Empty state ─────────────────────────────────────────────────
            if (!feedState.isLoading &&
                filteredPosts.isEmpty &&
                feedState.error == null)
              SliverFillRemaining(
                child: _EmptyFeed(isDark: isDark, theme: theme, cs: cs),
              ),

            // ── Posts list ──────────────────────────────────────────────────
            if (filteredPosts.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 90),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final post = filteredPosts[i];
                      return PostCard(
                        key: ValueKey(post.id),
                        post: post,
                        onLike: () => ref
                            .read(feedProvider.notifier)
                            .toggleLike(post.id),
                        onCommentSubmit: (text) => ref
                            .read(feedProvider.notifier)
                            .addComment(post.id, text),
                        onUserTap: () => context
                            .push('/feed/profile/${post.authorUserId}'),
                      );
                    },
                    childCount: filteredPosts.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign out',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: Size.zero,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(authControllerProvider.notifier).logout();
    }
  }
}

// ─── Feed AppBar (global narrow style) ───────────────────────────────────────

class _FeedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDark;
  final ColorScheme cs;
  final bool isRefreshing;
  final VoidCallback onRefresh;
  final VoidCallback onLogout;

  const _FeedAppBar({
    required this.isDark,
    required this.cs,
    required this.isRefreshing,
    required this.onRefresh,
    required this.onLogout,
  });

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    final barColor = isDark ? AppColors.cardDark : Colors.white;
    final borderColor = isDark
        ? AppColors.borderDark
        : Colors.black.withValues(alpha: 0.08);
    final iconColor = cs.onSurface.withValues(alpha: 0.75);

    return Container(
      height: preferredSize.height + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        color: barColor,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            // ── Logo icon (left) ─────────────────────────────────────────
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.brandGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.apartment_rounded,
                  color: Colors.white, size: 19),
            ),

            const SizedBox(width: 10),

            // ── Brand name ────────────────────────────────────────────────
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: AppColors.brandGradient,
              ).createShader(b),
              child: Text(
                'Narrow',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: Colors.white, // masked by ShaderMask
                ),
              ),
            ),

            const Spacer(),

            // ── Refresh indicator / button ─────────────────────────────────
            _RefreshBtn(
              isRefreshing: isRefreshing,
              iconColor: iconColor,
              onTap: onRefresh,
            ),

            // ── Messages icon ──────────────────────────────────────────────
            _AppBarBtn(
              icon: Icons.maps_ugc_rounded,
              color: iconColor,
              badge: true,
              onTap: () => context.push('/chat'),
            ),

            // ── More ──────────────────────────────────────────────────────
            _MoreBtn(iconColor: iconColor, onLogout: onLogout),
          ],
        ),
      ),
    );
  }
}

// ─── Refresh button (spins while refreshing) ──────────────────────────────────

class _RefreshBtn extends StatelessWidget {
  final bool isRefreshing;
  final Color iconColor;
  final VoidCallback onTap;

  const _RefreshBtn({
    required this.isRefreshing,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isRefreshing ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: isRefreshing
              ? SizedBox(
                  key: const ValueKey('loading'),
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                )
              : Icon(
                  key: const ValueKey('refresh'),
                  Icons.refresh_rounded,
                  color: iconColor,
                  size: 24,
                ),
        ),
      ),
    );
  }
}

// ─── Generic AppBar icon button ───────────────────────────────────────────────

class _AppBarBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool badge;

  const _AppBarBtn({
    required this.icon,
    required this.color,
    required this.onTap,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, color: color, size: 24),
            if (badge)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: AppColors.brandGradient),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── More popup button ────────────────────────────────────────────────────────

class _MoreBtn extends StatelessWidget {
  final Color iconColor;
  final VoidCallback onLogout;

  const _MoreBtn({required this.iconColor, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: iconColor, size: 22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (v) {
        if (v == 'logout') onLogout();
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 18),
              SizedBox(width: 10),
              Text('Sign out'),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Error Banner ─────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final ThemeData theme;

  const _ErrorBanner(
      {required this.error, required this.onRetry, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded,
              color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              error,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.error),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ─── Empty Feed ───────────────────────────────────────────────────────────────

class _EmptyFeed extends StatelessWidget {
  final bool isDark;
  final ThemeData theme;
  final ColorScheme cs;

  const _EmptyFeed({
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
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.accent.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Icon(
              Icons.photo_camera_outlined,
              size: 40,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No posts yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Follow people to see their posts here.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.35),
            ),
          ),
        ],
      )
          .animate()
          .fadeIn(duration: 500.ms)
          .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
    );
  }
}

// ─── Instagram-style Skeleton ─────────────────────────────────────────────────

class _IgPostSkeleton extends StatelessWidget {
  const _IgPostSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF2A1A1D) : const Color(0xFFFFEEF0);
    final highlight =
        isDark ? const Color(0xFF3A2428) : const Color(0xFFFFF5F6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
          child: Row(
            children: [
              _Bone(width: 42, height: 42, radius: 21, color: base),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Bone(width: 110, height: 12, radius: 6, color: base),
                  const SizedBox(height: 5),
                  _Bone(width: 70, height: 10, radius: 5, color: base),
                ],
              ),
            ],
          ),
        ),
        _Bone(width: double.infinity, height: 280, radius: 0, color: base),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: Row(
            children: [
              _Bone(width: 28, height: 28, radius: 14, color: base),
              const SizedBox(width: 12),
              _Bone(width: 28, height: 28, radius: 14, color: base),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: _Bone(width: 80, height: 11, radius: 5, color: base),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 7, 12, 14),
          child: _Bone(width: 200, height: 11, radius: 5, color: base),
        ),
        Divider(
          height: 1,
          thickness: 0.5,
          color: isDark
              ? AppColors.borderDark
              : Colors.black.withValues(alpha: 0.06),
        ),
      ],
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 1400.ms, color: highlight.withValues(alpha: 0.6));
  }
}

class _Bone extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final Color color;

  const _Bone({
    required this.width,
    required this.height,
    required this.radius,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
