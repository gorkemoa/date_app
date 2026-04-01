import 'package:flutter/material.dart';
import 'package:story/story.dart';
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
// Ana Viewer ekranı — story paketi kullanır
// ──────────────────────────────────────────────
class _StoryViewerScreen extends StatelessWidget {
  const _StoryViewerScreen({
    required this.items,
    required this.initialIndex,
  });

  final List<StoryItem> items;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: StoryPageView(
        itemBuilder: (context, pageIndex, storyIndex) {
          final item = items[storyIndex];
          if (item.photoUrl != null) {
            return StoryImage(
              key: ValueKey(item.photoUrl),
              imageProvider: NetworkImage(item.photoUrl!),
              fit: BoxFit.cover,
            );
          } else {
            return Container(
              color: Colors.black87,
              child: const Center(
                child: Icon(Icons.person_rounded,
                    color: Colors.white54, size: 64),
              ),
            );
          }
        },
        gestureItemBuilder: (context, pageIndex, storyIndex) {
          return Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + 26,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _StoryHeader(
                  item: items[storyIndex],
                  onClose: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          );
        },
        pageLength: 1,
        storyLength: (int pageIndex) {
          return items.length;
        },
        initialStoryIndex: (int pageIndex) {
          return initialIndex;
        },
        onPageLimitReached: () {
          Navigator.of(context).pop();
        },
        indicatorDuration: const Duration(seconds: 5),
        indicatorPadding: EdgeInsets.only(
          top: MediaQuery.paddingOf(context).top + 10,
          left: 12,
          right: 12,
        ),
        indicatorHeight: 2,
        indicatorVisitedColor: Colors.white,
        indicatorUnvisitedColor: Colors.white.withValues(alpha: 0.30),
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

