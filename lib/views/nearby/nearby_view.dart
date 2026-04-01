import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/nearby/nearby_user_model.dart';
import '../../viewmodels/nearby/nearby_view_model.dart';
import '../shared/components/error_state_view.dart';
import '../shared/components/loading_view.dart';
import 'nearby_profile_detail_view.dart';

class NearbyView extends StatefulWidget {
  const NearbyView({super.key});

  @override
  State<NearbyView> createState() => _NearbyViewState();
}

class _NearbyViewState extends State<NearbyView> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  late final AnimationController _flyAnim;

  // Animasyon başlangıç/bitiş değerleri
  LatLng _flyFrom = const LatLng(38.4268, 27.1437);
  LatLng _flyTo = const LatLng(38.4268, 27.1437);
  double _zoomFrom = 15.5;
  double _zoomTo = 15.5;

  @override
  void initState() {
    super.initState();
    _flyAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..addListener(_onFlyTick);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NearbyViewModel>().loadNearby();
    });
  }

  void _onFlyTick() {
    final t = Curves.easeInOutCubic.transform(_flyAnim.value);
    _mapController.move(
      LatLng(
        _flyFrom.latitude + (_flyTo.latitude - _flyFrom.latitude) * t,
        _flyFrom.longitude + (_flyTo.longitude - _flyFrom.longitude) * t,
      ),
      _zoomFrom + (_zoomTo - _zoomFrom) * t,
    );
  }

  @override
  void dispose() {
    _flyAnim.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _selectAndFlyTo(NearbyUserModel user) {
    final vm = context.read<NearbyViewModel>();
    final alreadySelected = vm.selectedUser?.id == user.id;
    vm.selectUser(alreadySelected ? null : user);
    if (!alreadySelected) {
      _flyFrom = _mapController.camera.center;
      _flyTo = LatLng(user.latitude, user.longitude);
      _zoomFrom = _mapController.camera.zoom;
      _zoomTo = 16.5;
      _flyAnim.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NearbyViewModel>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildBody(vm),
    );
  }

  Widget _buildBody(NearbyViewModel vm) {
    if (vm.isLoading) return const LoadingView();
    if (vm.hasError) {
      return ErrorStateView(
        message: vm.errorMessage,
        onRetry: () => context.read<NearbyViewModel>().loadNearby(),
      );
    }

    return Stack(
      children: [
        _MapLayer(
          vm: vm,
          mapController: _mapController,
          onPinTap: _selectAndFlyTo,
        ),
        const _NearbyHeader(),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (vm.selectedUser != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base,
                    0,
                    AppSpacing.base,
                    AppSpacing.sm,
                  ),
                  child: vm.selectedUser!.isPrivate
                      ? _PrivateProfileCard(
                          user: vm.selectedUser!,
                          onClose: () =>
                              context.read<NearbyViewModel>().selectUser(null),
                        )
                      : _PublicProfileCard(
                          user: vm.selectedUser!,
                          onClose: () =>
                              context.read<NearbyViewModel>().selectUser(null),
                        ),
                ),
              _NearbyBottomBar(vm: vm, onTap: _selectAndFlyTo),
            ],
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Harita katmanı
// ──────────────────────────────────────────────
class _MapLayer extends StatelessWidget {
  const _MapLayer({
    required this.vm,
    required this.mapController,
    required this.onPinTap,
  });

  final NearbyViewModel vm;
  final MapController mapController;
  final ValueChanged<NearbyUserModel> onPinTap;

  @override
  Widget build(BuildContext context) {
    // İzmir Alsancak — dar kapsam
    const center = LatLng(38.4268, 27.1437);

    return FlutterMap(
      mapController: mapController,
      options: const MapOptions(
        initialCenter: center,
        initialZoom: 15.5,
        maxZoom: 18,
        minZoom: 13,
        interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.rivorya.dateapp',
          maxZoom: 19,
        ),
        MarkerLayer(
          markers: vm.allMarkers
              .map(
                (u) => Marker(
                  point: LatLng(u.latitude, u.longitude),
                  width: u.isMe ? 68 : 72,
                  height: u.isMe ? 68 : 82,
                  child: GestureDetector(
                    onTap: u.isMe ? null : () => onPinTap(u),
                    child: _MapPin(
                      user: u,
                      isSelected: vm.selectedUser?.id == u.id,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Harita pin bileşeni
// ──────────────────────────────────────────────
class _MapPin extends StatelessWidget {
  const _MapPin({required this.user, required this.isSelected});

  final NearbyUserModel user;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    if (user.isMe) return _buildMePin();
    if (user.isPrivate) return _buildPrivatePin();
    return _buildPublicPin();
  }

  Widget _buildMePin() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 3),
            boxShadow: AppShadows.primaryGlow,
          ),
          child: ClipOval(
            child: user.photoUrl != null
                ? Image.network(
                    user.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => _fallback(AppColors.primary),
                  )
                : _fallback(AppColors.primary),
          ),
        ),
        CustomPaint(
          size: const Size(10, 6),
          painter: _PinTailPainter(color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildPrivatePin() {
    final color = isSelected ? AppColors.primary : AppColors.textDisabled;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceVariant,
            border: Border.all(color: color, width: 2),
            boxShadow: AppShadows.sm,
          ),
          child: Icon(Icons.lock_outline, size: 20, color: color),
        ),
        CustomPaint(
          size: const Size(8, 5),
          painter: _PinTailPainter(color: color),
        ),
      ],
    );
  }

  Widget _buildPublicPin() {
    final color = isSelected ? AppColors.primary : AppColors.accent;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
            boxShadow: isSelected ? AppShadows.primaryGlow : AppShadows.md,
            color: Colors.white,
          ),
          child: ClipOval(
            child: SizedBox(
              width: 42,
              height: 42,
              child: user.photoUrl != null
                  ? Image.network(
                      user.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => _fallback(color),
                    )
                  : _fallback(color),
            ),
          ),
        ),
        CustomPaint(
          size: const Size(8, 5),
          painter: _PinTailPainter(color: color),
        ),
        if (user.venueName != null)
          Container(
            margin: const EdgeInsets.only(top: 1),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(3),
              boxShadow: AppShadows.sm,
            ),
            child: Text(
              user.venueName!,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Widget _fallback(Color color) {
    return Container(
      color: color.withValues(alpha: 0.15),
      child: Icon(Icons.person, color: color, size: 22),
    );
  }
}

// ──────────────────────────────────────────────
// Pin kuyruk çizici
// ──────────────────────────────────────────────
class _PinTailPainter extends CustomPainter {
  const _PinTailPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PinTailPainter old) => old.color != color;
}

// ──────────────────────────────────────────────
// Üst başlık overlay
// ──────────────────────────────────────────────
class _NearbyHeader extends StatelessWidget {
  const _NearbyHeader();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NearbyViewModel>();
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xDDFFFFFF), Color(0x00FFFFFF)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                const Text('Yanımdakiler', style: AppTextStyles.headingLarge),
                const SizedBox(width: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: const Text(
                    'Alsancak • İzmir',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textOnSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (!vm.isLoading && vm.nearbyUsers.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${vm.nearbyUsers.length} uyumlu',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Alt kullanıcı çubuğu (yatay scroll)
// ──────────────────────────────────────────────
class _NearbyBottomBar extends StatelessWidget {
  const _NearbyBottomBar({required this.vm, required this.onTap});

  final NearbyViewModel vm;
  final ValueChanged<NearbyUserModel> onTap;

  @override
  Widget build(BuildContext context) {
    if (vm.nearbyUsers.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFAFFFFFF), Color(0x00FFFFFF)],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.lg,
            bottom: AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.radio_button_checked,
                      size: 11,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Çevrende ${vm.nearbyUsers.length} kişi müsait',
                      style: AppTextStyles.labelMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 88,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                  ),
                  itemCount: vm.nearbyUsers.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final user = vm.nearbyUsers[index];
                    return _NearbyBarChip(
                      user: user,
                      isSelected: vm.selectedUser?.id == user.id,
                      onTap: () => onTap(user),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Çubuktaki kullanıcı chip'i
// ──────────────────────────────────────────────
class _NearbyBarChip extends StatelessWidget {
  const _NearbyBarChip({
    required this.user,
    required this.isSelected,
    required this.onTap,
  });

  final NearbyUserModel user;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 68,
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.overlayLight : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!user.isPrivate)
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.secondary,
                      width: 2),
                ),
                child: ClipOval(
                  child: SizedBox(
                    width: 38,
                    height: 38,
                    child: user.photoUrl != null
                        ? Image.network(
                            user.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) =>
                                const Icon(Icons.person, size: 20),
                          )
                        : const Icon(Icons.person, size: 20),
                  ),
                ),
              )
            else
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceVariant,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 2,
                  ),
                  boxShadow: AppShadows.sm,
                ),
                child: const ClipOval(
                  child: Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: AppColors.textDisabled,
                  ),
                ),
              ),
            const SizedBox(height: 3),
            Text(
              user.isPrivate ? '•••' : user.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              user.distanceLabel,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Public profil kartı (kompakt)
// ──────────────────────────────────────────────
class _PublicProfileCard extends StatelessWidget {
  const _PublicProfileCard({required this.user, required this.onClose});

  final NearbyUserModel user;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Başlık satırı ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent, width: 2),
                ),
                child: ClipOval(
                  child: user.photoUrl != null
                      ? Image.network(
                          user.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            color: AppColors.surfaceVariant,
                            child: const Icon(Icons.person),
                          ),
                        )
                      : Container(
                          color: AppColors.surfaceVariant,
                          child: const Icon(Icons.person),
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.nameAndAge, style: AppTextStyles.headingSmall),
                    if (user.occupation != null)
                      Text(user.occupation!, style: AppTextStyles.bodySmall),
                    if (user.venueName != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.coffee_outlined,
                            size: 11,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              '${user.venueName!}  ·  ${user.distanceLabel}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.accent,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          // --- Butonlar ---
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _CardActionButton(
                label: 'Geç',
                icon: Icons.close,
                color: AppColors.swipePass,
                onTap: onClose,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _CardActionButton(
                  label: 'Profil Detay',
                  icon: Icons.person_outline,
                  color: AppColors.textSecondary,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NearbyProfileDetailView(user: user),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              _CardActionButton(
                label: 'Merhaba 👋',
                icon: Icons.waving_hand_outlined,
                color: AppColors.accent,
                filled: true,
                onTap: onClose,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Private profil kartı
// ──────────────────────────────────────────────
class _PrivateProfileCard extends StatelessWidget {
  const _PrivateProfileCard({required this.user, required this.onClose});

  final NearbyUserModel user;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.lg,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceVariant,
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: const Icon(
              Icons.lock_outline,
              size: 22,
              color: AppColors.textDisabled,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Profil Gizli', style: AppTextStyles.headingSmall),
                Text(user.distanceLabel, style: AppTextStyles.bodySmall),
                const SizedBox(height: 2),
                const Text(
                  'Bağlantı kurmak için istek gönder.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Text(
                    'İstek Gönder',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: onClose,
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Kart aksiyon butonu
// ──────────────────────────────────────────────
class _CardActionButton extends StatelessWidget {
  const _CardActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 9,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: filled ? color : color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: filled
              ? null
              : Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: filled ? Colors.white : color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: filled ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
