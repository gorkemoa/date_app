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

class NearbyView extends StatefulWidget {
  const NearbyView({super.key});

  @override
  State<NearbyView> createState() => _NearbyViewState();
}

class _NearbyViewState extends State<NearbyView> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NearbyViewModel>().loadNearby();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
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
        // --- Harita ---
        _MapLayer(
          vm: vm,
          mapController: _mapController,
        ),

        // --- Üst başlık ---
        const _NearbyHeader(),

        // --- Alt kullanıcı çubuğu ---
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _NearbyBottomBar(vm: vm),
        ),

        // --- Seçili kullanıcı kartı ---
        if (vm.selectedUser != null)
          Positioned(
            left: AppSpacing.base,
            right: AppSpacing.base,
            bottom: 148,
            child: _SelectedUserCard(
              user: vm.selectedUser!,
              onClose: () => context.read<NearbyViewModel>().selectUser(null),
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
  const _MapLayer({required this.vm, required this.mapController});

  final NearbyViewModel vm;
  final MapController mapController;

  @override
  Widget build(BuildContext context) {
    // İzmir Alsancak merkez olarak
    const center = LatLng(38.4280, 27.1380);

    return FlutterMap(
      mapController: mapController,
      options: const MapOptions(
        initialCenter: center,
        initialZoom: 13.5,
        maxZoom: 18,
        minZoom: 10,
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.rivorya.dateapp',
          maxZoom: 19,
        ),
        MarkerLayer(
          markers: vm.allMarkers
              .map((u) => Marker(
                    point: LatLng(u.latitude, u.longitude),
                    width: u.isMe ? 64 : 56,
                    height: u.isMe ? 64 : 56,
                    child: GestureDetector(
                      onTap: u.isMe
                          ? null
                          : () => context.read<NearbyViewModel>().selectUser(
                                vm.selectedUser?.id == u.id ? null : u,
                              ),
                      child: _MapPin(user: u),
                    ),
                  ))
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
  const _MapPin({required this.user});

  final NearbyUserModel user;

  @override
  Widget build(BuildContext context) {
    final borderColor = user.isMe ? AppColors.primary : AppColors.accent;
    final size = user.isMe ? 52.0 : 44.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 2.5),
            boxShadow: AppShadows.md,
          ),
          child: ClipOval(
            child: user.photoUrl != null
                ? Image.network(
                    user.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _pinFallback(borderColor),
                  )
                : _pinFallback(borderColor),
          ),
        ),
        // Pin iğnesi
        CustomPaint(
          size: const Size(10, 6),
          painter: _PinTailPainter(color: borderColor),
        ),
      ],
    );
  }

  Widget _pinFallback(Color color) {
    return Container(
      color: color.withValues(alpha: 0.15),
      child: Icon(Icons.person, color: color, size: 24),
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
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xCCFFFFFF), Color(0x00FFFFFF)],
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
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: const Text(
                    'İzmir',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w600,
                    ),
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
  const _NearbyBottomBar({required this.vm});

  final NearbyViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (vm.nearbyUsers.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xF0FFFFFF), Color(0x00FFFFFF)],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.xl,
            bottom: AppSpacing.base,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                ),
                child: Text(
                  '${vm.nearbyUsers.length} kişi yakınında',
                  style: AppTextStyles.labelMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 100,
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
                      onTap: () => context.read<NearbyViewModel>().selectUser(
                            vm.selectedUser?.id == user.id ? null : user,
                          ),
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
        width: 72,
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
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border,
                      width: 2,
                    ),
                    boxShadow: AppShadows.sm,
                  ),
                  child: ClipOval(
                    child: user.photoUrl != null
                        ? Image.network(
                            user.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.surfaceVariant,
                              child: const Icon(Icons.person, size: 20),
                            ),
                          )
                        : Container(
                            color: AppColors.surfaceVariant,
                            child: const Icon(Icons.person, size: 20),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              user.name,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
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
// Seçili kullanıcı mini kartı
// ──────────────────────────────────────────────
class _SelectedUserCard extends StatelessWidget {
  const _SelectedUserCard({required this.user, required this.onClose});

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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            child: ClipOval(
              child: user.photoUrl != null
                  ? Image.network(
                      user.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
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
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(user.nameAndAge, style: AppTextStyles.headingSmall),
                if (user.occupation != null)
                  Text(user.occupation!, style: AppTextStyles.bodySmall),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 12, color: AppColors.accent),
                    const SizedBox(width: 2),
                    Text(
                      user.distanceLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _ActionButtons(user: user),
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.user});
  final NearbyUserModel user;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CircleAction(
          icon: Icons.close,
          color: AppColors.swipePass,
          onTap: () => context.read<NearbyViewModel>().selectUser(null),
        ),
        const SizedBox(width: AppSpacing.xs),
        _CircleAction(
          icon: Icons.favorite,
          color: AppColors.swipeLike,
          onTap: () => context.read<NearbyViewModel>().selectUser(null),
        ),
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
