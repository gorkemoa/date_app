import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/discover/discover_card_model.dart';

class DiscoverDetailView extends StatelessWidget {
  const DiscoverDetailView({super.key, required this.card});

  final DiscoverCardModel card;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(card.nameAndAge)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (card.bio != null) ...[
              Text('Hakkında', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              Text(card.bio!, style: AppTextStyles.bodyLarge),
              const SizedBox(height: 16),
            ],
            if (card.interests.isNotEmpty) ...[
              Text('İlgi Alanları', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: card.interests
                    .map((i) => Chip(label: Text(i)))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
