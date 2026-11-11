import 'package:flutter/material.dart';

import 'data/mock_vehicles.dart';
import 'models/vehicle.dart';
import 'navigation/app_route.dart';
import 'screens/login_screen.dart';
import 'screens/vehicle_form_screen.dart';
import 'screens/vehicle_list_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/app_shell.dart';

void main() {
  runApp(const VmsAdminApp());
}

/// Root widget for the Vehicle Management System (VMS) Flutter Web Frontend.
class VmsAdminApp extends StatelessWidget {
  const VmsAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VMS Admin Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const VmsRootNavigator(),
    );
  }
}

/// Top-level state coordinator handling mock authentication, navigation,
/// and in-memory fleet records.
class VmsRootNavigator extends StatefulWidget {
  const VmsRootNavigator({super.key});

  @override
  State<VmsRootNavigator> createState() => _VmsRootNavigatorState();
}

class _VmsRootNavigatorState extends State<VmsRootNavigator> {
  bool _isAuthenticated = false;
  String _currentUserEmail = 'admin@vms-fleet.local';

  AppDestination _currentDestination = AppDestination.vehicleList;
  final List<Vehicle> _vehicles = List<Vehicle>.of(initialMockVehicles);
  Vehicle? _editingVehicle;

  void _handleLogin(String email) {
    setState(() {
      _currentUserEmail = email;
      _isAuthenticated = true;
      _currentDestination = AppDestination.vehicleList;
    });
  }

  void _handleLogout() {
    setState(() {
      _isAuthenticated = false;
      _editingVehicle = null;
      _currentDestination = AppDestination.vehicleList;
    });
  }

  void _selectDestination(AppDestination destination) {
    setState(() {
      if (destination == AppDestination.vehicleForm) {
        _editingVehicle = null;
      }
      _currentDestination = destination;
    });
  }

  void _openCreateVehicleForm() {
    setState(() {
      _editingVehicle = null;
      _currentDestination = AppDestination.vehicleForm;
    });
  }

  void _openEditVehicleForm(Vehicle vehicle) {
    setState(() {
      _editingVehicle = vehicle;
      _currentDestination = AppDestination.vehicleForm;
    });
  }

  void _handleSaveVehicle(Vehicle savedVehicle) {
    final existingIndex = _vehicles.indexWhere((v) => v.id == savedVehicle.id);
    final isUpdating = existingIndex >= 0;

    setState(() {
      if (isUpdating) {
        _vehicles[existingIndex] = savedVehicle;
      } else {
        _vehicles.insert(0, savedVehicle);
      }
      _editingVehicle = null;
      _currentDestination = AppDestination.vehicleList;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isUpdating
              ? 'Updated ${savedVehicle.plateNumber} (${savedVehicle.displayName})'
              : 'Registered ${savedVehicle.plateNumber} (${savedVehicle.displayName})',
        ),
      ),
    );
  }

  void _handleDeleteVehicle(Vehicle vehicle) {
    setState(() {
      _vehicles.removeWhere((v) => v.id == vehicle.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed ${vehicle.plateNumber} from fleet list'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return LoginScreen(onLoginSuccess: _handleLogin);
    }

    final isEditing =
        _currentDestination == AppDestination.vehicleForm &&
        _editingVehicle != null;

    final pageTitle = isEditing
        ? 'Edit Vehicle'
        : _currentDestination.title;

    final pageSubtitle = isEditing
        ? 'Modify fleet record for ${_editingVehicle!.plateNumber}'
        : _currentDestination.subtitle;

    return AppShell(
      currentDestination: _currentDestination,
      pageTitle: pageTitle,
      pageSubtitle: pageSubtitle,
      currentUserEmail: _currentUserEmail,
      onSelectDestination: _selectDestination,
      onLogout: _handleLogout,
      child: switch (_currentDestination) {
        AppDestination.vehicleList => VehicleListScreen(
          vehicles: _vehicles,
          onAddVehicle: _openCreateVehicleForm,
          onEditVehicle: _openEditVehicleForm,
          onDeleteVehicle: _handleDeleteVehicle,
        ),
        AppDestination.vehicleForm => VehicleFormScreen(
          initialVehicle: _editingVehicle,
          onSave: _handleSaveVehicle,
          onCancel: () => _selectDestination(AppDestination.vehicleList),
        ),
      },
    );
  }
}
