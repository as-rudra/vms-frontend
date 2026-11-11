import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/vehicle.dart';
import '../theme/app_theme.dart';

/// Screen for registering a new vehicle or editing an existing vehicle record.
class VehicleFormScreen extends StatefulWidget {
  const VehicleFormScreen({
    super.key,
    this.initialVehicle,
    required this.onSave,
    required this.onCancel,
  });

  /// When non-null, the form operates in "Edit Vehicle" mode.
  final Vehicle? initialVehicle;
  final ValueChanged<Vehicle> onSave;
  final VoidCallback onCancel;

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _plateController;
  late final TextEditingController _makeController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _driverController;
  late final TextEditingController _mileageController;
  late final TextEditingController _notesController;

  late VehicleType _selectedType;
  late VehicleStatus _selectedStatus;

  bool get _isEditing => widget.initialVehicle != null;

  @override
  void initState() {
    super.initState();
    _plateController = TextEditingController();
    _makeController = TextEditingController();
    _modelController = TextEditingController();
    _yearController = TextEditingController();
    _driverController = TextEditingController();
    _mileageController = TextEditingController();
    _notesController = TextEditingController();
    _populateFields(widget.initialVehicle);
  }

  @override
  void didUpdateWidget(covariant VehicleFormScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialVehicle?.id != widget.initialVehicle?.id) {
      _populateFields(widget.initialVehicle);
    }
  }

  void _populateFields(Vehicle? vehicle) {
    _plateController.text = vehicle?.plateNumber ?? '';
    _makeController.text = vehicle?.make ?? '';
    _modelController.text = vehicle?.model ?? '';
    _yearController.text = '${vehicle?.year ?? DateTime.now().year}';
    _driverController.text = vehicle?.assignedDriver ?? '';
    _mileageController.text = '${vehicle?.mileageKm ?? 0}';
    _notesController.text = vehicle?.notes ?? '';
    _selectedType = vehicle?.type ?? VehicleType.sedan;
    _selectedStatus = vehicle?.status ?? VehicleStatus.active;
  }

  @override
  void dispose() {
    _plateController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _driverController.dispose();
    _mileageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final id = widget.initialVehicle?.id ??
        'VEH-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';

    final driverText = _driverController.text.trim();

    final savedVehicle = Vehicle(
      id: id,
      plateNumber: _plateController.text.trim().toUpperCase(),
      make: _makeController.text.trim(),
      model: _modelController.text.trim(),
      year: int.parse(_yearController.text.trim()),
      type: _selectedType,
      status: _selectedStatus,
      assignedDriver: driverText.isEmpty ? 'Unassigned' : driverText,
      mileageKm: int.parse(_mileageController.text.trim()),
      notes: _notesController.text.trim(),
    );

    widget.onSave(savedVehicle);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: AppSpacing.lg,
                      runSpacing: AppSpacing.md,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEditing
                                  ? 'Edit Vehicle (${widget.initialVehicle!.plateNumber})'
                                  : 'Register New Vehicle',
                              style: textTheme.titleLarge,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              _isEditing
                                  ? 'Update the vehicle specifications, operational status, or driver assignment.'
                                  : 'Enter the vehicle details below to add it to the local fleet directory.',
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ),
                        OutlinedButton.icon(
                          onPressed: widget.onCancel,
                          icon: const Icon(Icons.arrow_back, size: 18),
                          label: const Text('Back to Fleet'),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                      child: Divider(height: 1),
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isTwoColumn = constraints.maxWidth >= 640;
                        const spacing = AppSpacing.lg;
                        final fieldWidth = isTwoColumn
                            ? (constraints.maxWidth - spacing) / 2
                            : constraints.maxWidth;

                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: [
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: _plateController,
                                textCapitalization:
                                    TextCapitalization.characters,
                                decoration: const InputDecoration(
                                  labelText: 'License Plate Number *',
                                  hintText: 'e.g. VMS-8042',
                                  prefixIcon: Icon(
                                    Icons.badge_outlined,
                                    size: 20,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'License plate number is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: DropdownButtonFormField<VehicleType>(
                                initialValue: _selectedType,
                                decoration: const InputDecoration(
                                  labelText: 'Vehicle Category *',
                                  prefixIcon: Icon(
                                    Icons.category_outlined,
                                    size: 20,
                                  ),
                                ),
                                items: VehicleType.values.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(type.label),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _selectedType = value);
                                  }
                                },
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: _makeController,
                                decoration: const InputDecoration(
                                  labelText: 'Manufacturer / Make *',
                                  hintText: 'e.g. Toyota, Ford, Hyundai',
                                  prefixIcon: Icon(
                                    Icons.precision_manufacturing_outlined,
                                    size: 20,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Vehicle make is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: _modelController,
                                decoration: const InputDecoration(
                                  labelText: 'Vehicle Model *',
                                  hintText: 'e.g. Hilux 4x4, Transit',
                                  prefixIcon: Icon(
                                    Icons.directions_car_outlined,
                                    size: 20,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Vehicle model is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: _yearController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Model Year *',
                                  hintText: 'e.g. 2025',
                                  prefixIcon: Icon(
                                    Icons.calendar_today_outlined,
                                    size: 20,
                                  ),
                                ),
                                validator: (value) {
                                  final year = int.tryParse(value ?? '');
                                  if (year == null ||
                                      year < 1990 ||
                                      year > 2030) {
                                    return 'Enter a valid year between 1990 and 2030';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: DropdownButtonFormField<VehicleStatus>(
                                initialValue: _selectedStatus,
                                decoration: const InputDecoration(
                                  labelText: 'Operational Status *',
                                  prefixIcon: Icon(
                                    Icons.flag_outlined,
                                    size: 20,
                                  ),
                                ),
                                items: VehicleStatus.values.map((status) {
                                  return DropdownMenuItem(
                                    value: status,
                                    child: Text(status.label),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _selectedStatus = value);
                                  }
                                },
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: _driverController,
                                decoration: const InputDecoration(
                                  labelText: 'Assigned Driver',
                                  hintText: 'Leave blank if unassigned',
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                controller: _mileageController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Odometer Mileage (km) *',
                                  hintText: 'e.g. 15000',
                                  prefixIcon: Icon(
                                    Icons.speed_outlined,
                                    size: 20,
                                  ),
                                ),
                                validator: (value) {
                                  final km = int.tryParse(value ?? '');
                                  if (km == null || km < 0) {
                                    return 'Enter a valid non-negative mileage';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              width: constraints.maxWidth,
                              child: TextFormField(
                                controller: _notesController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  labelText: 'Fleet & Maintenance Notes',
                                  hintText:
                                      'Optional notes regarding assignment, equipment, or upcoming service...',
                                  alignLabelWithHint: true,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: widget.onCancel,
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        FilledButton.icon(
                          onPressed: _handleSubmit,
                          icon: const Icon(Icons.check, size: 18),
                          label: Text(
                            _isEditing ? 'Save Changes' : 'Register Vehicle',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
