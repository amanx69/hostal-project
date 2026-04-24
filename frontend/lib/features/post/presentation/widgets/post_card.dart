import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';

import '../../data/models/post_model.dart';
import '../../../../../core/theme/app_theme.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onLike;
  final Future<void> Function(String text) onCommentSubmit;
  final VoidCallback? onUserTap;
  final VoidCallback? onDelete;
  final bool isOwner;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onCommentSubmit,
    this.onUserTap,
    this.onDelete,
    this.isOwner = false,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with TickerProviderStateMixin {
  bool _showComments = false;
  final _commentCtrl = TextEditingController();
  bool _isSubmittingComment = false;

  // Like animation
  late final AnimationController _heartBurst;
  late final AnimationController _doubleTapHeart;
  bool _showDoubleTapHeart = false;

  @override
  void initState() {
    super.initState();
    _heartBurst = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _doubleTapHeart = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _heartBurst.dispose();
    _doubleTapHeart.dispose();
    super.dispose();
  }

  void _handleLike() {
    HapticFeedback.lightImpact();
    _heartBurst.forward(from: 0);
    widget.onLike();
  }

  void _handleDoubleTap() {
    HapticFeedback.mediumImpact();
    if (!widget.post.likedByMe) {
      widget.onLike();
    }
    setState(() => _showDoubleTapHeart = true);
    _doubleTapHeart.forward(from: 0).then((_) {
      if (mounted) setState(() => _showDoubleTapHeart = false);
    });
  }

  Future<void> _handleCommentSubmit() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSubmittingComment = true);
    _commentCtrl.clear();
    await widget.onCommentSubmit(text);
    if (mounted) setState(() => _isSubmittingComment = false);
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;

    return Container(
      color: cardBg,
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          _IgHeader(
            post: post,
            onUserTap: widget.onUserTap,
            onDelete: widget.isOwner ? () => _confirmDelete(context) : null,
            isDark: isDark,
          ),

          // ── Media (edge to edge, double-tap to like) ─────────────────────
          if (post.media != null && post.media!.isNotEmpty)
            GestureDetector(
              onDoubleTap: _handleDoubleTap,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _MediaViewer(
                    url: post.media!,
                    isDark: isDark,
                  ),
                  // Double-tap heart overlay
                  if (_showDoubleTapHeart)
                    AnimatedBuilder(
                      animation: _doubleTapHeart,
                      builder: (_, __) {
                        final t = _doubleTapHeart.value;
                        final opacity = t < 0.5 ? t * 2 : (1 - t) * 2;
                        final scale = 0.6 + (t * 0.7);
                        return Opacity(
                          opacity: opacity.clamp(0, 1),
                          child: Transform.scale(
                            scale: scale,
                            child: const Icon(
                              Icons.favorite_rounded,
                              color: Colors.white,
                              size: 90,
                              shadows: [
                                Shadow(
                                  color: Colors.black38,
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),

          // ── Text-only post (no media) ─────────────────────────────────────
          if (post.media == null || post.media!.isEmpty)
            if (post.description != null && post.description!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                margin: const EdgeInsets.symmetric(horizontal: 0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.08),
                      AppColors.accent.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: Text(
                  post.description!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.55,
                    color: cs.onSurface.withValues(alpha: 0.85),
                    fontSize: 15,
                  ),
                ),
              ),

          // ── Action bar ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
            child: Row(
              children: [
                // Like
                _IgActionBtn(
                  icon: widget.post.likedByMe
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: widget.post.likedByMe
                      ? AppColors.error
                      : cs.onSurface.withValues(alpha: 0.75),
                  onTap: _handleLike,
                  controller: _heartBurst,
                ),
                const SizedBox(width: 4),
                // Comment
                _IgActionBtn(
                  icon: Icons.chat_bubble_outline_rounded,
                  color: cs.onSurface.withValues(alpha: 0.75),
                  onTap: () => setState(() => _showComments = !_showComments),
                ),
                const Spacer(),
              ],
            ),
          ),

          // ── Likes count ───────────────────────────────────────────────────
          if (post.likesCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  key: ValueKey(post.likesCount),
                  '${post.likesCount} ${post.likesCount == 1 ? 'like' : 'likes'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

          // ── Caption (title + description below likes) ─────────────────────
          if (post.title != null && post.title!.isNotEmpty ||
              (post.media != null &&
                  post.description != null &&
                  post.description!.isNotEmpty))
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 5, 14, 0),
              child: RichText(
                text: TextSpan(
                  children: [
                    if (post.title != null && post.title!.isNotEmpty)
                      TextSpan(
                        text: '${post.postUser?.username ?? ''} ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                    if (post.title != null && post.title!.isNotEmpty)
                      TextSpan(
                        text: post.title!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.85),
                        ),
                      ),
                    // Description below image (if has media)
                    if (post.media != null &&
                        post.description != null &&
                        post.description!.isNotEmpty)
                      TextSpan(
                        text: post.title != null && post.title!.isNotEmpty
                            ? '\n${post.description!}'
                            : '${post.postUser?.username ?? ''} ${post.description!}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.75),
                          fontWeight: post.title == null
                              ? FontWeight.w400
                              : FontWeight.w400,
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // ── Comments preview ──────────────────────────────────────────────
          if (post.commentsCount > 0 && !_showComments)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
              child: GestureDetector(
                onTap: () => setState(() => _showComments = true),
                child: Text(
                  'View all ${post.commentsCount} comments',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.4),
                    fontSize: 13,
                  ),
                ),
              ),
            ),

          // ── Comment preview (first comment) ──────────────────────────────
          if (!_showComments && post.comments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 3, 14, 0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${post.comments.first.userEmail.split('@').first} ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                        fontSize: 12.5,
                      ),
                    ),
                    TextSpan(
                      text: post.comments.first.text,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.75),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // ── Timestamp ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
            child: Text(
              _formatTime(post.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.35),
                fontSize: 10.5,
                letterSpacing: 0.2,
              ),
            ),
          ),

          // ── Expanded comments ─────────────────────────────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _showComments
                ? _IgCommentsSection(
                    comments: post.comments,
                    controller: _commentCtrl,
                    isSubmitting: _isSubmittingComment,
                    onSubmit: _handleCommentSubmit,
                    isDark: isDark,
                  )
                : const SizedBox.shrink(),
          ),

          // ── Divider ───────────────────────────────────────────────────────
          Divider(
            height: 1,
            thickness: 0.5,
            color: isDark
                ? AppColors.borderDark
                : Colors.black.withValues(alpha: 0.08),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Post',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to delete this post?'),
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
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && widget.onDelete != null) widget.onDelete!();
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      final months = [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}';
    } catch (_) {
      return '';
    }
  }
}

// ─── Instagram-style Header ───────────────────────────────────────────────────

class _IgHeader extends StatelessWidget {
  final Post post;
  final VoidCallback? onUserTap;
  final VoidCallback? onDelete;
  final bool isDark;

  const _IgHeader({
    required this.post,
    this.onUserTap,
    this.onDelete,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final username = post.postUser?.username ?? 'Unknown';
    final avatarUrl = post.postUser?.profilePicture;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      child: Row(
        children: [
          // Avatar with gradient ring
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onUserTap,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.cardDark : Colors.white,
                ),
                child: _MiniAvatar(url: avatarUrl, username: username, size: 34),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Username + verified badge
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onUserTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // More options / delete
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_horiz_rounded,
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (v) {
              if (v == 'delete' && onDelete != null) onDelete!();
            },
            itemBuilder: (_) => [
              if (onDelete != null)
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded,
                          color: AppColors.error, size: 18),
                      SizedBox(width: 10),
                      Text('Delete',
                          style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.flag_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('Report'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Instagram Action Button ──────────────────────────────────────────────────

class _IgActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final AnimationController? controller;

  const _IgActionBtn({
    required this.icon,
    required this.color,
    required this.onTap,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: controller != null
            ? AnimatedBuilder(
                animation: controller!,
                builder: (_, __) => Transform.scale(
                  scale: 1 + (controller!.value * 0.4 * (1 - controller!.value)),
                  child: Icon(icon, color: color, size: 26),
                ),
              )
            : Icon(icon, color: color, size: 26),
      ),
    );
  }
}

// ─── Comments Section (IG style) ──────────────────────────────────────────────

class _IgCommentsSection extends StatelessWidget {
  final List<Comment> comments;
  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final bool isDark;

  const _IgCommentsSection({
    required this.comments,
    required this.controller,
    required this.isSubmitting,
    required this.onSubmit,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      color: isDark
          ? Colors.white.withValues(alpha: 0.03)
          : Colors.black.withValues(alpha: 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comments list
          ...comments.take(8).map(
                (c) => _IgCommentRow(comment: c, isDark: isDark)
                    .animate()
                    .fadeIn(duration: 200.ms),
              ),
          if (comments.length > 8)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Text(
                'View all ${comments.length} comments',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.4),
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 10),
          // Comment input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: !isSubmitting,
                  decoration: InputDecoration(
                    hintText: 'Add a comment…',
                    hintStyle: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.35),
                      fontSize: 13,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : Colors.black.withValues(alpha: 0.12),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : Colors.black.withValues(alpha: 0.12),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                    ),
                    filled: true,
                    fillColor: isDark ? AppColors.cardDark : Colors.white,
                  ),
                  style:
                      theme.textTheme.bodySmall?.copyWith(fontSize: 13),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSubmit(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: isSubmitting ? null : onSubmit,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: isSubmitting
                      ? const Padding(
                          padding: EdgeInsets.all(9),
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_rounded,
                          color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Comment Row ──────────────────────────────────────────────────────────────

class _IgCommentRow extends StatelessWidget {
  final Comment comment;
  final bool isDark;

  const _IgCommentRow({required this.comment, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final handle = comment.userEmail.split('@').first;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              handle.isNotEmpty ? handle[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$handle ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                      fontSize: 12.5,
                    ),
                  ),
                  TextSpan(
                    text: comment.text,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.8),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mini Avatar ──────────────────────────────────────────────────────────────

class _MiniAvatar extends StatelessWidget {
  final String? url;
  final String username;
  final double size;

  const _MiniAvatar({this.url, required this.username, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final initials =
        username.isNotEmpty ? username[0].toUpperCase() : '?';

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: url != null && url!.isNotEmpty
            ? Image.network(
                url!,
                fit: BoxFit.cover,
              )
            : Container(
                color: AppColors.primary,
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
      ),
    );
  }
}

// ─── Media Viewer ─────────────────────────────────────────────────────────────

class _MediaViewer extends StatefulWidget {
  final String url;
  final bool isDark;

  const _MediaViewer({required this.url, required this.isDark});

  @override
  State<_MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<_MediaViewer> {
  VideoPlayerController? _controller;
  bool _isVideo = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    final lowerUrl = widget.url.toLowerCase();
    _isVideo = lowerUrl.endsWith('.mp4') || lowerUrl.endsWith('.mov') || lowerUrl.endsWith('.avi');
    
    if (_isVideo) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..initialize().then((_) {
          if (mounted) setState(() => _isInitialized = true);
          _controller?.setLooping(true);
          _controller?.play();
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVideo) {
      return Image.network(
        widget.url,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : AspectRatio(
                aspectRatio: 4 / 3,
                child: Container(
                  color: widget.isDark ? AppColors.borderDark : const Color(0xFFF0F0F0),
                  child: Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
        errorBuilder: (_, __, ___) => Container(
          height: 220,
          color: widget.isDark ? AppColors.borderDark : const Color(0xFFF0F0F0),
          child: const Center(
            child: Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey),
          ),
        ),
      );
    }

    if (_isInitialized && _controller != null) {
      return AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: VideoPlayer(_controller!),
      );
    }

    return Container(
      height: 300,
      color: Colors.black87,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  final String text;
  final double size;

  const _Initials(this.text, this.size);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: AppColors.primary,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.40,
        ),
      ),
    );
  }
}
