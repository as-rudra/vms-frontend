import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';
import '../widgets/summary_stat_card.dart';

/// Displays the fleet overview, search/filter controls, and vehicle directory.
class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({
    super.key,
    required this.vehicles,
    required this.onAddVehicle,
    required this.onEditVehicle,
    required this.onDeleteVehicle,
  });

  final List<Vehicle> vehicles;
  final VoidCallback onAddVehicle;
  final ValueChanged<Vehicle> onEditVehicle;
  final ValueChanged<Vehicle> onDeleteVehicle;

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  String _searchQuery = '';
  VehicleStatus? _selectedStatus;

  List<Vehicle> get _filteredVehicles {
    final query = _searchQuery.trim().toLowerCase();
    return widget.vehicles.where((vehicle) {
      final matchesStatus =
          _selectedStatus == null || vehicle.status == _selectedStatus;
      if (!matchesStatus) return false;
      if (query.isEmpty) return true;

      return vehicle.plateNumber.toLowerCase().contains(query) ||
          vehicle.make.toLowerCase().contains(query) ||
          vehicle.model.toLowerCase().contains(query) ||
          vehicle.assignedDriver.toLowerCase().contains(query);
    }).toList();
  }

  int _countByStatus(VehicleStatus status) {
    return widget.vehicles.where((v) => v.status == status).length;
  }

  Future<void> _confirmDelete(BuildContext context, Vehicle vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text(
          'Are you sure you want to delete ${vehicle.plateNumber} '
          '(${vehicle.displayName}) from the mock fleet list?',
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Delete Vehicle'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      widget.onDeleteVehicle(vehicle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredVehicles;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSummaryRow(),
          const SizedBox(height: AppSpacing.xl),
          _buildFilterToolbar(context),
          const SizedBox(height: AppSpacing.lg),
          Card(
            clipBehavior: Clip.antiAlias,
            child: filtered.isEmpty
                ? _buildEmptyState(context)
                : LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth >= 820) {
                        return _buildDesktopTable(
                          context,
                          filtered,
                          constraints.maxWidth,
                        );
                      }
                      return _buildCompactCardList(context, filtered);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1000
            ? 4
            : constraints.maxWidth >= 600
                ? 2
                : 1;
        const spacing = AppSpacing.lg;
        final itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: itemWidth,
              child: SummaryStatCard(
                label: 'Total Vehicles',
                value: '${widget.vehicles.length}',
                icon: Icons.directions_car_outlined,
                accentColor: AppColors.statTotalAccent,
                backgroundColor: AppColors.statTotalBg,
                borderColor: AppColors.statTotalBorder,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: SummaryStatCard(
                label: 'Active Fleet',
                value: '${_countByStatus(VehicleStatus.active)}',
                icon: Icons.check_circle_outline,
                accentColor: AppColors.statActiveAccent,
                backgroundColor: AppColors.statActiveBg,
                borderColor: AppColors.statActiveBorder,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: SummaryStatCard(
                label: 'In Maintenance',
                value: '${_countByStatus(VehicleStatus.maintenance)}',
                icon: Icons.build_circle_outlined,
                accentColor: AppColors.statMaintenanceAccent,
                backgroundColor: AppColors.statMaintenanceBg,
                borderColor: AppColors.statMaintenanceBorder,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: SummaryStatCard(
                label: 'Inactive / Standby',
                value: '${_countByStatus(VehicleStatus.inactive)}',
                icon: Icons.pause_circle_outline,
                accentColor: AppColors.statInactiveAccent,
                backgroundColor: AppColors.statInactiveBg,
                borderColor: AppColors.statInactiveBorder,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterToolbar(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.md,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 260, maxWidth: 380),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: const InputDecoration(
                  hintText: 'Search by plate, make, model, or driver...',
                  prefixIcon: Icon(Icons.search, size: 20),
                ),
              ),
            ),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilterChip(
                  label: const Text('All Statuses'),
                  selected: _selectedStatus == null,
                  onSelected: (_) => setState(() => _selectedStatus = null),
                ),
                ...VehicleStatus.values.map((status) {
                  return FilterChip(
                    label: Text(status.label),
                    selected: _selectedStatus == status,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = selected ? status : null;
                      });
                    },
                  );
                }),
                const SizedBox(width: AppSpacing.sm),
                FilledButton.icon(
                  onPressed: widget.onAddVehicle,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Register Vehicle'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlateTag(String plateNumber) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Text(
        plateNumber,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          fontFamily: 'monospace',
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildRowActions(BuildContext context, Vehicle vehicle) {
    final compactButtonStyle = OutlinedButton.styleFrom(
      minimumSize: const Size(0, 36),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontSize: 13,
      ),
    );

    final deleteButtonStyle = OutlinedButton.styleFrom(
      foregroundColor: AppColors.danger,
      backgroundColor: AppColors.dangerSoft,
      minimumSize: const Size(0, 36),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      side: const BorderSide(color: AppColors.dangerBorder),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontSize: 13,
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          style: compactButtonStyle,
          onPressed: () => widget.onEditVehicle(vehicle),
          icon: const Icon(
            Icons.edit_outlined,
            size: 16,
            color: AppColors.textSecondary,
          ),
          label: const Text('Edit'),
        ),
        const SizedBox(width: AppSpacing.sm),
        OutlinedButton.icon(
          style: deleteButtonStyle,
          onPressed: () => _confirmDelete(context, vehicle),
          icon: const Icon(
            Icons.delete_outline,
            size: 16,
            color: AppColors.danger,
          ),
          label: const Text('Delete'),
        ),
      ],
    );
  }

  Widget _buildDesktopTable(
    BuildContext context,
    List<Vehicle> vehicles,
    double availableWidth,
  ) {
    final textTheme = Theme.of(context).textTheme;

    const horizontalMargin = AppSpacing.xl; // 24px left & right
    const columnSpacing = AppSpacing.lg; // 16px between 7 columns (6 gaps)
    const minTableWidth = 968.0;

    final tableWidth = math.max(availableWidth, minTableWidth);
    final extraWidth = math.max(0.0, tableWidth - minTableWidth);

    // Base column widths + proportional share of extra full-screen width.
    final plateWidth = 96.0 + (extraWidth * 0.12);
    final vehicleWidth = 148.0 + (extraWidth * 0.22);
    final typeWidth = 104.0 + (extraWidth * 0.14);
    final driverWidth = 112.0 + (extraWidth * 0.18);
    final mileageWidth = 84.0 + (extraWidth * 0.10);
    final statusWidth = 124.0 + (extraWidth * 0.12);
    final actionsWidth = 156.0 + (extraWidth * 0.12);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: tableWidth),
        child: DataTable(
          horizontalMargin: horizontalMargin,
          columnSpacing: columnSpacing,
          dataRowMinHeight: 60,
          dataRowMaxHeight: 68,
          columns: [
            DataColumn(
              label: SizedBox(
                width: plateWidth,
                child: const Text('Plate Number'),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: vehicleWidth,
                child: const Text('Vehicle'),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: typeWidth,
                child: const Text('Type'),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: driverWidth,
                child: const Text('Assigned Driver'),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: mileageWidth,
                child: const Text('Mileage (km)'),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: statusWidth,
                child: const Text('Status'),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: actionsWidth,
                child: const Align(
                  alignment: Alignment.centerRight,
                  child: Text('Actions'),
                ),
              ),
            ),
          ],
          rows: vehicles.map((vehicle) {
            return DataRow(
              cells: [
                DataCell(
                  SizedBox(
                    width: plateWidth,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _buildPlateTag(vehicle.plateNumber),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: vehicleWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${vehicle.make} ${vehicle.model}',
                          style: textTheme.titleSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Year ${vehicle.year} • ID ${vehicle.id}',
                          style: textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: typeWidth,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          vehicle.type.icon,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Flexible(
                          child: Text(
                            vehicle.type.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: driverWidth,
                    child: Text(
                      vehicle.assignedDriver,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: mileageWidth,
                    child: Text('${vehicle.mileageKm} km'),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: statusWidth,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: StatusBadge(status: vehicle.status),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: actionsWidth,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _buildRowActions(context, vehicle),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCompactCardList(BuildContext context, List<Vehicle> vehicles) {
    final textTheme = Theme.of(context).textTheme;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vehicles.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _buildPlateTag(vehicle.plateNumber),
                        StatusBadge(status: vehicle.status),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      vehicle.displayName,
                      style: textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${vehicle.type.label} • Driver: ${vehicle.assignedDriver} • ${vehicle.mileageKm} km',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              _buildRowActions(context, vehicle),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 48,
        horizontal: AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.search_off_outlined,
            size: 48,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No matching vehicles found',
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Try clearing your search filter or register a new vehicle.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _selectedStatus = null;
              });
            },
            child: const Text('Reset Filters'),
          ),
        ],
      ),
    );
  }
}
