import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../theme/app_theme.dart';

/// A reusable pill-shaped status badge for displaying a [VehicleStatus].
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
  });

  final VehicleStatus status;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (Color bg, Color fg) = switch (status) {
      VehicleStatus.active => (
        AppColors.statusActiveBg,
        AppColors.statusActiveFg,
      ),
      VehicleStatus.maintenance => (
        AppColors.statusMaintenanceBg,
        AppColors.statusMaintenanceFg,
      ),
      VehicleStatus.inactive => (
        AppColors.statusInactiveBg,
        AppColors.statusInactiveFg,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 16, color: fg),
          const SizedBox(width: AppSpacing.xs),
          Text(
            status.label,
            style: textTheme.labelMedium?.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}
