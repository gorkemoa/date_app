import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart' as sv;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

// ──────────────────────────────────────────────
// Veri modeli — herhangi bir kaynaktan beslenir
// ──────────────────────────────────────────────
class StoryItem {
  final String name;
  final String? photoUrl;
  final String timeLabel;

  const StoryItem({
    required this.name,
    this.photoUrl,
    this.timeLabel = '2 saat önce',
  });
}

// ──────────────────────────────────────────────
// Açma yardımcısı
// ──────────────────────────────────────────────
void showStoryViewer(
  BuildContext context,
  List<StoryItem> items,
  int initialIndex,
) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, _) => FadeTransition(
        opacity: animation,
        child: _StoryViewerScreen(items: items, initialIndex: initialIndex),
      ),
    ),
  );
}

// ──────────────────────────────────────────────
// Ana Viewer ekranı — story_view paketi kullanır
// ──────────────────────────────────────────────
class _StoryViewerScreen extends StatefulWidget {
  const _StoryViewerScreen({
    required this.items,
    required this.initialIndex,
  });

  final List<StoryItem> items;
  final int initialIndex;

  @override
  State<_StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<_StoryViewerScreen> {
  late final sv.StoryController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _controller = sv.StoryController();
    _currentIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<sv.StoryItem> _buildItems() {
    return widget.items.asMap().entries.map((entry) {
      final i = entry.key;
      final item = entry.value;

      final content = item.photoUrl != null
          ? sv.StoryItem.pageImage(
              url: item.photoUrl!,
              controller: _controller,
              shown: i < widget.initialIndex,
              duration: const Duration(seconds: 5),
              imageFit: BoxFit.cover,
              loadingWidget: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
              errorWidget: Container(
                color: Colors.black,
                child: const Center(
                  child: Icon(Icons.person_rounded,
                      color: Colors.white54, size: 64),
                ),
              ),
            )
          : sv.StoryItem(
              Container(
                color: Colors.black87,
                child: const Center(
                  child: Icon(Icons.person_rounded,
                      color: Colors.white54, size: 64),
                ),
              ),
              shown: i < widget.initialIndex,
              duration: const Duration(seconds: 5),
            );

      return content;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Stack(
        children: [
          // ── story_view paketi — progress bar + gesture yönetimi ──
          sv.StoryView(
            storyItems: _buildItems(),
            controller: _controller,
            repeat: false,
            inline: false,
            progressPosition: sv.ProgressPosition.top,
            indicatorColor: Colors.white.withValues(alpha: 0.30),
            indicatorForegroundColor: Colors.white,
            indicatorHeight: sv.IndicatorHeight.small,
            indicatorOuterPadding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            onComplete: () => Navigator.of(context).pop(),
            onVerticalSwipeComplete: (direction) {
              if (direction == sv.Direction.down) {
                Navigator.of(context).pop();
              }
            },
            onStoryShow: (_, index) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                if (mounted) {
                  setState(() => _currentIndex = index);
                }
              });
            },
          ),

          // ── Header overlay — isim, avatar, zaman + kapat ──
          SafeArea(
            bottom: false,
            child: IgnorePointer(
              // Sadece kapat butonu IgnorePointer dışında
              ignoring: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 30, 12, 0),
                child: _StoryHeader(
                  item: widget.items[_currentIndex],
                  onClose: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Header — avatar + isim + zaman + kapat
// ──────────────────────────────────────────────
class _StoryHeader extends StatelessWidget {
  const _StoryHeader({required this.item, required this.onClose});

  final StoryItem item;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Gradient halka + avatar
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE040FB),
                Color(0xFFFF6B35),
                Color(0xFFFFD700),
              ],
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(1.5),
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.surfaceVariant,
              backgroundImage: item.photoUrl != null
                  ? NetworkImage(item.photoUrl!)
                  : null,
              child: item.photoUrl == null
                  ? const Icon(Icons.person_rounded,
                      color: Colors.white70, size: 20)
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 10),

        // İsim + zaman
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: AppTextStyles.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                item.timeLabel,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),

        // Kapat butonu
        GestureDetector(
          onTap: onClose,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              Icons.close_rounded,
              color: Colors.white.withValues(alpha: 0.90),
              size: 26,
            ),
          ),
        ),
      ],
    );
  }
}

