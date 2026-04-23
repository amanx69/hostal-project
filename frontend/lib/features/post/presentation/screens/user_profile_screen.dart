import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/post_providers.dart';
import '../widgets/post_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// User Profile Screen  (X / Twitter layout — other user's profile)
// ─────────────────────────────────────────────────────────────────────────────

class UserProfileScreen extends ConsumerWidget {
  final int userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(userProfileProvider(userId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show skeleton while loading OR on the initial frame before fetch sets isLoading
    if (profileState.profile == null && profileState.error == null) {
      return _XProfileSkeleton(isDark: isDark);
    }

    // ── Error ────────────────────────────────────────────────────────────────
    if (profileState.error != null || profileState.profile == null) {
      return _ErrorScaffold(
        error: profileState.error ?? 'Profile not found',
        isDark: isDark,
        onRetry: () =>
            ref.read(userProfileProvider(userId).notifier).fetchProfile(),
        onBack: () => context.pop(),
      );
    }

    final profile = profileState.profile!;
    final isFollowing = profile.isFollowing;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Cover + avatar header ──────────────────────────────────────
            SliverToBoxAdapter(
              child: _XProfileHeader(
                avatarUrl: profile.profilePicture,
                username: profile.username,
                isDark: isDark,
                trailing: _XFollowBtn(
                  isFollowing: isFollowing,
                  onToggle: () => ref
                      .read(userProfileProvider(userId).notifier)
                      .toggleFollow(),
                ),
                topAction: Row(
                  children: [
                    _CircleBtn(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => context.pop(),
                      isDark: isDark,
                    ),
                    const Spacer(),
                    _CircleBtn(
                      icon: Icons.more_horiz_rounded,
                      onTap: () {},
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),

            // ── Name + handle + bio ────────────────────────────────────────
            SliverToBoxAdapter(
              child: _XNameBlock(
                name: profile.username,
                handle: '@${profile.username.toLowerCase()}',
                bio: profile.bio,
                location: profile.location,
                email: null, // don't expose other user's email
                isDark: isDark,
              ).animate().fadeIn(duration: 350.ms),
            ),

            // ── Stats ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _XStatsRow(
                posts: profile.posts.length,
                followers: profile.followersCount,
                following: profile.followingCount,
                isDark: isDark,
              ).animate().fadeIn(delay: 80.ms),
            ),

            // ── Posts tab divider ──────────────────────────────────────────
            SliverToBoxAdapter(child: _XDivider(isDark: isDark)),

            // ── Posts ──────────────────────────────────────────────────────
            if (profile.posts.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _XEmptyPosts(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final post = profile.posts[i];
                      return PostCard(
                        key: ValueKey(post.id),
                        post: post,
                        onLike: () =>
                            ref.read(feedProvider.notifier).toggleLike(post.id),
                        onCommentSubmit: (text) =>
                            ref.read(feedProvider.notifier).addComment(post.id, text),
                        onUserTap: null, // already on this profile
                      ).animate().fadeIn(
                            duration: 300.ms,
                            delay: Duration(milliseconds: i * 50),
                          );
                    },
                    childCount: profile.posts.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared X-style building blocks
// ─────────────────────────────────────────────────────────────────────────────

class _XProfileHeader extends StatelessWidget {
  final String? avatarUrl;
  final String username;
  final bool isDark;
  final Widget? trailing;
  final Widget? topAction;

  const _XProfileHeader({
    required this.avatarUrl,
    required this.username,
    required this.isDark,
    this.trailing,
    this.topAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Cover banner with avatar overlapping ───────────────────────────
        Stack(
          clipBehavior: Clip.none,
          children: [
            _CoverBanner(username: username, isDark: isDark),

            if (topAction != null)
              Positioned(
                top: MediaQuery.of(context).padding.top + 6,
                left: 10,
                right: 10,
                child: topAction!,
              ),

            Positioned(
              bottom: -44,
              left: 16,
              child: _XAvatar(url: avatarUrl, username: username),
            ),
          ],
        ),

        const SizedBox(height: 52),

        // ── Follow / edit button aligned right ─────────────────────────────
        if (trailing != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(children: [const Spacer(), trailing!]),
          ),
      ],
    );
  }
}

class _CoverBanner extends StatelessWidget {
  final String username;
  final bool isDark;

  const _CoverBanner({required this.username, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final hue =
        username.isNotEmpty ? (username.codeUnitAt(0) * 137) % 360 : 0;
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HSLColor.fromAHSL(
                    1, hue.toDouble(), 0.55, isDark ? 0.28 : 0.40)
                .toColor(),
            AppColors.primary,
            AppColors.accent,
          ],
        ),
      ),
    );
  }
}

class _XAvatar extends StatelessWidget {
  final String? url;
  final String username;

  const _XAvatar({this.url, required this.username});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final init = username.isNotEmpty ? username[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? AppColors.surfaceDark : Colors.white,
      ),
      child: Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: AppColors.brandGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ClipOval(
          child: url != null && url!.isNotEmpty
              ? Image.network(
                  url!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _AvatarInitials(init: init),
                )
              : _AvatarInitials(init: init),
        ),
      ),
    );
  }
}

class _AvatarInitials extends StatelessWidget {
  final String init;

  const _AvatarInitials({required this.init});

  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.primary,
        alignment: Alignment.center,
        child: Text(
          init,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 30,
          ),
        ),
      );
}

class _XNameBlock extends StatelessWidget {
  final String name;
  final String handle;
  final String? bio;
  final String? location;
  final String? email;
  final bool isDark;

  const _XNameBlock({
    required this.name,
    required this.handle,
    this.bio,
    this.location,
    this.email,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            handle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.45),
            ),
          ),
          if (bio != null && bio!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              bio!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.85),
                height: 1.5,
              ),
            ),
          ],
          if (location != null || email != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 14,
              runSpacing: 4,
              children: [
                if (location != null)
                  _XInfoChip(
                      icon: Icons.location_on_outlined, label: location!),
                if (email != null && email!.isNotEmpty)
                  _XInfoChip(icon: Icons.link_rounded, label: email!),
              ],
            ),
          ],
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

class _XInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _XInfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context)
        .colorScheme
        .onSurface
        .withValues(alpha: 0.45);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 13, color: color, fontWeight: FontWeight.w400)),
      ],
    );
  }
}

class _XStatsRow extends StatelessWidget {
  final int posts;
  final int followers;
  final int following;
  final bool isDark;

  const _XStatsRow({
    required this.posts,
    required this.followers,
    required this.following,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
      child: Row(
        children: [
          _XStat(value: posts, label: 'Posts', theme: theme, cs: cs),
          const SizedBox(width: 20),
          _XStat(value: following, label: 'Following', theme: theme, cs: cs),
          const SizedBox(width: 20),
          _XStat(value: followers, label: 'Followers', theme: theme, cs: cs),
        ],
      ),
    );
  }
}

class _XStat extends StatelessWidget {
  final int value;
  final String label;
  final ThemeData theme;
  final ColorScheme cs;

  const _XStat({
    required this.value,
    required this.label,
    required this.theme,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value.toString(),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.45),
            ),
          ),
        ],
      );
}

class _XDivider extends StatelessWidget {
  final bool isDark;

  const _XDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Posts',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 3,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: AppColors.brandGradient),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 0.5,
          color: isDark
              ? AppColors.borderDark
              : Colors.black.withValues(alpha: 0.08),
        ),
      ],
    );
  }
}

class _XEmptyPosts extends StatelessWidget {
  const _XEmptyPosts();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.photo_camera_outlined,
              size: 48, color: cs.onSurface.withValues(alpha: 0.15)),
          const SizedBox(height: 14),
          Text(
            'No posts yet',
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.35),
              fontSize: 15,
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}

/// X-style follow button (filled when not following, outline when following)
class _XFollowBtn extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onToggle;

  const _XFollowBtn({required this.isFollowing, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isFollowing ? Colors.transparent : AppColors.primary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isFollowing
                ? (isDark
                    ? AppColors.borderDark
                    : Colors.black.withValues(alpha: 0.25))
                : AppColors.primary,
            width: 1.2,
          ),
        ),
        child: Text(
          isFollowing ? 'Following' : 'Follow',
          style: TextStyle(
            color: isFollowing
                ? (isDark ? Colors.white : Colors.black87)
                : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _CircleBtn(
      {required this.icon, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

// ─── Error scaffold ───────────────────────────────────────────────────────────

class _ErrorScaffold extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final VoidCallback? onBack;
  final bool isDark;

  const _ErrorScaffold({
    required this.error,
    required this.onRetry,
    this.onBack,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        elevation: 0,
        leading: onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: onBack,
              )
            : null,
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_off_outlined,
                size: 52, color: cs.onSurface.withValues(alpha: 0.2)),
            const SizedBox(height: 14),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.45), fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 17),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── X Profile Skeleton ───────────────────────────────────────────────────────

class _XProfileSkeleton extends StatelessWidget {
  final bool isDark;

  const _XProfileSkeleton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final base = isDark ? const Color(0xFF2A1A1D) : const Color(0xFFFFEEF0);
    final shimmer =
        isDark ? const Color(0xFF3A2428) : const Color(0xFFFFF5F6);

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SBone(width: double.infinity, height: 150, radius: 0, color: base),
          const SizedBox(height: 52),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SBone(width: 140, height: 18, radius: 8, color: base),
                const SizedBox(height: 6),
                _SBone(width: 100, height: 13, radius: 6, color: base),
                const SizedBox(height: 12),
                _SBone(width: 220, height: 13, radius: 6, color: base),
                const SizedBox(height: 4),
                _SBone(width: 180, height: 13, radius: 6, color: base),
                const SizedBox(height: 16),
                Row(children: [
                  _SBone(width: 55, height: 13, radius: 6, color: base),
                  const SizedBox(width: 16),
                  _SBone(width: 75, height: 13, radius: 6, color: base),
                  const SizedBox(width: 16),
                  _SBone(width: 65, height: 13, radius: 6, color: base),
                ]),
              ],
            ),
          ),
        ],
      )
          .animate(onPlay: (c) => c.repeat())
          .shimmer(duration: 1400.ms, color: shimmer.withValues(alpha: 0.6)),
    );
  }
}

class _SBone extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final Color color;

  const _SBone({
    required this.width,
    required this.height,
    required this.radius,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}
