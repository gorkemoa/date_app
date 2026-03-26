import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../viewmodels/registration/registration_view_model.dart';

// İzmir ilçeleri
const List<String> _izmirDistricts = [
  'Aliağa', 'Balçova', 'Bayındır', 'Bayraklı', 'Bergama', 'Beydağ',
  'Bornova', 'Buca', 'Çeşme', 'Çiğli', 'Dikili', 'Foça', 'Gaziemir',
  'Güzelbahçe', 'Karabağlar', 'Karaburun', 'Karşıyaka', 'Kemalpaşa',
  'Kınık', 'Kiraz', 'Konak', 'Menderes', 'Menemen', 'Narlıdere',
  'Ödemiş', 'Selçuk', 'Seferihisar', 'Tire', 'Torbalı', 'Urla',
];

// Aktif şehirler (yakında açılacak olanlar da gösterilir, ama grayed out)
const List<String> _cities = [
  'İzmir', 'İstanbul', 'Ankara', 'Bursa', 'Antalya', 'Adana', 'Konya',
];

class StepBasicInfoView extends StatefulWidget {
  const StepBasicInfoView({super.key});

  @override
  State<StepBasicInfoView> createState() => _StepBasicInfoViewState();
}

class _StepBasicInfoViewState extends State<StepBasicInfoView> {
  late final TextEditingController _bioCtrl;
  DateTime? _birthDate;
  UserGender? _gender;
  String _city = '';
  String _district = '';

  @override
  void initState() {
    super.initState();
    final draft = context.read<RegistrationViewModel>().draft;
    _birthDate = draft.birthDate;
    _gender = draft.gender;
    _city = draft.city;
    _district = draft.district;
    _bioCtrl = TextEditingController(text: draft.bio);
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    super.dispose();
  }

  void _save() {
    context.read<RegistrationViewModel>().updateBasicInfo(
          birthDate: _birthDate,
          gender: _gender,
          bio: _bioCtrl.text.trim(),
          city: _city,
          district: _district,
        );
  }

  Future<void> _pickBirthDate() async {
    FocusScope.of(context).unfocus();
    final initial = _birthDate ?? DateTime(DateTime.now().year - 25);
    DateTime tempDate = initial;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DatePickerSheet(
        initialDate: initial,
        onDateChanged: (d) => tempDate = d,
        onConfirm: () {
          setState(() => _birthDate = tempDate);
          _save();
        },
      ),
    );
  }

  Future<void> _pickDistrict() async {
    if (_city != 'İzmir') return;
    FocusScope.of(context).unfocus();
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DistrictPickerSheet(districts: _izmirDistricts),
    );
    if (picked != null) {
      setState(() => _district = picked);
      _save();
    }
  }

  Future<void> _pickCity() async {
    FocusScope.of(context).unfocus();
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _CityPickerSheet(),
    );
    if (picked != null && picked == 'İzmir') {
      setState(() {
        _city = picked;
        _district = '';
      });
      _save();
    }
  }

  String _formatDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day.$month.${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl, vertical: AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            const Text('Merhaba! 👋', style: AppTextStyles.displayMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Seni biraz tanıyalım',
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // ── Doğum Tarihi ──
            _SectionLabel(label: 'Doğum Tarihi'),
            const SizedBox(height: AppSpacing.xs),
            _TappableField(
              value: _birthDate != null ? _formatDate(_birthDate!) : null,
              hint: 'Tarih seçin',
              icon: Icons.cake_outlined,
              onTap: _pickBirthDate,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Yalnızca 18 yaş ve üzeri kullanıcılar katılabilir.',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textDisabled),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Cinsiyet ──
            _SectionLabel(label: 'Cinsiyet'),
            const SizedBox(height: AppSpacing.sm),
            _GenderSelector(
              selected: _gender,
              onSelected: (g) {
                setState(() => _gender = g);
                _save();
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── İl / İlçe ──
            _SectionLabel(label: 'Konum'),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: _TappableField(
                    value: _city.isNotEmpty ? _city : null,
                    hint: 'İl seçin',
                    icon: Icons.location_city_outlined,
                    onTap: _pickCity,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 7,
                  child: _TappableField(
                    value: _district.isNotEmpty ? _district : null,
                    hint: 'İlçe seçin',
                    icon: Icons.place_outlined,
                    onTap: _city == 'İzmir' ? _pickDistrict : null,
                    disabled: _city != 'İzmir',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Biyografi ──
            _SectionLabel(label: 'Kendinizden Bahsedin'),
            const SizedBox(height: AppSpacing.xs),
            _BioField(
              controller: _bioCtrl,
              onChanged: (_) => _save(),
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Section label
// ──────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: AppTextStyles.labelMedium
            .copyWith(color: AppColors.textPrimary, letterSpacing: 0.2));
  }
}

// ──────────────────────────────────────────────
// Tappable field (date, city, district)
// ──────────────────────────────────────────────
class _TappableField extends StatelessWidget {
  const _TappableField({
    required this.hint,
    required this.icon,
    required this.onTap,
    this.value,
    this.disabled = false,
  });

  final String? value;
  final String hint;
  final IconData icon;
  final VoidCallback? onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: disabled
              ? AppColors.surfaceVariant.withValues(alpha: 0.5)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: hasValue
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.border,
          ),
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: disabled
                  ? AppColors.textDisabled
                  : (hasValue ? AppColors.primary : AppColors.textSecondary),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                value ?? hint,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: disabled
                      ? AppColors.textDisabled
                      : (hasValue
                          ? AppColors.textPrimary
                          : AppColors.textDisabled),
                  fontWeight:
                      hasValue ? FontWeight.w500 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color:
                  disabled ? AppColors.textDisabled : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Gender selector (pill buttons)
// ──────────────────────────────────────────────
class _GenderSelector extends StatelessWidget {
  const _GenderSelector(
      {required this.selected, required this.onSelected});

  final UserGender? selected;
  final void Function(UserGender) onSelected;

  static const _options = [
    (label: 'Erkek', gender: UserGender.male, icon: '👨'),
    (label: 'Kadın', gender: UserGender.female, icon: '👩'),
    (label: 'Diğer', gender: UserGender.other, icon: '🌈'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _options.map((opt) {
        final isSelected = selected == opt.gender;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => onSelected(opt.gender),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md, horizontal: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ],
                ),
                child: Column(
                  children: [
                    Text(opt.icon,
                        style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      opt.label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ──────────────────────────────────────────────
// Bio text field with character counter
// ──────────────────────────────────────────────
class _BioField extends StatefulWidget {
  const _BioField({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final void Function(String) onChanged;

  @override
  State<_BioField> createState() => _BioFieldState();
}

class _BioFieldState extends State<_BioField> {
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _charCount = widget.controller.text.length;
  }

  @override
  Widget build(BuildContext context) {
    const maxChars = 100;
    final isNearLimit = _charCount >= 80;
    final isAtLimit = _charCount >= maxChars;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: TextField(
            controller: widget.controller,
            maxLines: 4,
            maxLength: maxChars,
            buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                null,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText:
                  'Kendinizi kısaca tanıtın... (maks. $maxChars karakter)',
              hintStyle: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textDisabled),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppSpacing.base),
            ),
            onChanged: (v) {
              setState(() => _charCount = v.length);
              widget.onChanged(v);
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '$_charCount / $maxChars',
          style: AppTextStyles.caption.copyWith(
            color: isAtLimit
                ? AppColors.error
                : (isNearLimit
                    ? AppColors.warning
                    : AppColors.textDisabled),
            fontWeight:
                isNearLimit ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Date picker bottom sheet
// ──────────────────────────────────────────────
class _DatePickerSheet extends StatelessWidget {
  const _DatePickerSheet({
    required this.initialDate,
    required this.onDateChanged,
    required this.onConfirm,
  });
  final DateTime initialDate;
  final void Function(DateTime) onDateChanged;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl, vertical: AppSpacing.base),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Doğum Tarihi',
                    style: AppTextStyles.headingSmall),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm();
                  },
                  child: Text(
                    'Tamam',
                    style: AppTextStyles.labelLarge
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: initialDate,
              maximumDate: DateTime(now.year - 18, now.month, now.day),
              minimumDate: DateTime(1940),
              onDateTimeChanged: onDateChanged,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.base),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// City picker bottom sheet
// ──────────────────────────────────────────────
class _CityPickerSheet extends StatelessWidget {
  const _CityPickerSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl, vertical: AppSpacing.base),
            child: Row(
              children: [
                Text('Şehir Seçin', style: AppTextStyles.headingSmall),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    'Yalnızca İzmir aktif',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          ..._cities.map((city) {
            final isActive = city == 'İzmir';
            return ListTile(
              onTap: isActive ? () => Navigator.pop(context, city) : null,
              title: Text(
                city,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isActive
                      ? AppColors.textPrimary
                      : AppColors.textDisabled,
                  fontWeight:
                      isActive ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
              trailing: isActive
                  ? const Icon(Icons.check_rounded,
                      color: AppColors.primary, size: 18)
                  : Text(
                      'Yakında',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textDisabled),
                    ),
            );
          }),
          SizedBox(
              height: MediaQuery.of(context).padding.bottom +
                  AppSpacing.base),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// District picker bottom sheet
// ──────────────────────────────────────────────
class _DistrictPickerSheet extends StatefulWidget {
  const _DistrictPickerSheet({required this.districts});
  final List<String> districts;

  @override
  State<_DistrictPickerSheet> createState() =>
      _DistrictPickerSheetState();
}

class _DistrictPickerSheetState extends State<_DistrictPickerSheet> {
  late List<String> _filtered;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.districts;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _filter(String q) {
    setState(() {
      _filtered = widget.districts
          .where((d) => d.toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl)),
        ),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius:
                    BorderRadius.circular(AppRadius.full),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl, vertical: AppSpacing.base),
              child: Text('İzmir İlçeleri',
                  style: AppTextStyles.headingSmall),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _filter,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'İlçe ara...',
                  hintStyle: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textDisabled),
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.textSecondary, size: 18),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.sm),
                    borderSide:
                        const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.sm),
                    borderSide:
                        const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.sm),
                    borderSide:
                        const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.base,
                      vertical: AppSpacing.sm),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: ListView.builder(
                controller: sc,
                itemCount: _filtered.length,
                itemBuilder: (_, i) => ListTile(
                  onTap: () =>
                      Navigator.pop(context, _filtered[i]),
                  title: Text(_filtered[i],
                      style: AppTextStyles.bodyMedium),
                  trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColors.textDisabled),
                ),
              ),
            ),
            SizedBox(
                height: MediaQuery.of(context).padding.bottom +
                    AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

