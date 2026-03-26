class OnboardingOptionModel {
  final String id;
  final String label;
  final String? emoji;
  final String? iconPath;
  final bool isSelected;

  const OnboardingOptionModel({
    required this.id,
    required this.label,
    this.emoji,
    this.iconPath,
    this.isSelected = false,
  });

  OnboardingOptionModel copyWith({bool? isSelected}) {
    return OnboardingOptionModel(
      id: id,
      label: label,
      emoji: emoji,
      iconPath: iconPath,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
