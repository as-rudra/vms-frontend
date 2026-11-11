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
        title: const Text('Remove Vehicle'),
        content: Text(
          'Are you sure you want to remove ${vehicle.plateNumber} '
          '(${vehicle.displayName}) from the mock fleet list?',
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove'),
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
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1360),
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
                            return _buildDesktopTable(context, filtered);
                          }
                          return _buildCompactCardList(context, filtered);
                        },
                      ),
              ),
            ],
          ),
        ),
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
                accentColor: AppColors.primary,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: SummaryStatCard(
                label: 'Active Fleet',
                value: '${_countByStatus(VehicleStatus.active)}',
                icon: Icons.check_circle_outline,
                accentColor: AppColors.statusActiveAccent,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: SummaryStatCard(
                label: 'In Maintenance',
                value: '${_countByStatus(VehicleStatus.maintenance)}',
                icon: Icons.build_circle_outlined,
                accentColor: AppColors.statusMaintenanceAccent,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: SummaryStatCard(
                label: 'Inactive / Standby',
                value: '${_countByStatus(VehicleStatus.inactive)}',
                icon: Icons.pause_circle_outline,
                accentColor: AppColors.statusInactiveAccent,
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Edit Vehicle',
          onPressed: () => widget.onEditVehicle(vehicle),
          icon: const Icon(
            Icons.edit_outlined,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ),
        IconButton(
          tooltip: 'Remove Vehicle',
          onPressed: () => _confirmDelete(context, vehicle),
          icon: Icon(
            Icons.delete_outline,
            size: 20,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopTable(BuildContext context, List<Vehicle> vehicles) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 820),
        child: DataTable(
          dataRowMinHeight: 60,
          dataRowMaxHeight: 68,
          columnSpacing: AppSpacing.xl,
          columns: const [
            DataColumn(label: Text('Plate Number')),
            DataColumn(label: Text('Vehicle')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Assigned Driver')),
            DataColumn(label: Text('Mileage (km)'), numeric: true),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: vehicles.map((vehicle) {
            return DataRow(
              cells: [
                DataCell(_buildPlateTag(vehicle.plateNumber)),
                DataCell(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${vehicle.make} ${vehicle.model}',
                        style: textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Year ${vehicle.year} • ID ${vehicle.id}',
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        vehicle.type.icon,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(vehicle.type.label),
                    ],
                  ),
                ),
                DataCell(Text(vehicle.assignedDriver)),
                DataCell(Text('${vehicle.mileageKm} km')),
                DataCell(StatusBadge(status: vehicle.status)),
                DataCell(_buildRowActions(context, vehicle)),
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
