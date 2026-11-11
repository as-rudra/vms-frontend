import 'package:flutter/material.dart';

/// Represents the top-level sections inside the authenticated VMS Admin shell.
enum AppDestination {
  vehicleList(
    title: 'Vehicle Fleet',
    subtitle: 'Manage and monitor registered company vehicles',
    icon: Icons.directions_car_outlined,
    selectedIcon: Icons.directions_car,
  ),
  vehicleForm(
    title: 'Register Vehicle',
    subtitle: 'Add a new vehicle or update existing fleet records',
    icon: Icons.add_box_outlined,
    selectedIcon: Icons.add_box,
  );

  const AppDestination({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selectedIcon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final IconData selectedIcon;
}

