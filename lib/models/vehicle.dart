import 'package:flutter/material.dart';

/// Represents the operational status of a vehicle in the fleet.
enum VehicleStatus {
  active('Active', Icons.check_circle_outline),
  maintenance('In Maintenance', Icons.build_circle_outlined),
  inactive('Inactive', Icons.pause_circle_outline);

  const VehicleStatus(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Represents the category/body type of a vehicle.
enum VehicleType {
  sedan('Sedan', Icons.directions_car_outlined),
  suv('SUV', Icons.directions_car_filled_outlined),
  van('Cargo Van', Icons.airport_shuttle_outlined),
  truck('Truck', Icons.local_shipping_outlined),
  electric('Electric (EV)', Icons.electric_car_outlined);

  const VehicleType(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Core domain model representing a single vehicle in the VMS.
class Vehicle {
  const Vehicle({
    required this.id,
    required this.plateNumber,
    required this.make,
    required this.model,
    required this.year,
    required this.type,
    required this.status,
    required this.assignedDriver,
    required this.mileageKm,
    this.notes = '',
  });

  final String id;
  final String plateNumber;
  final String make;
  final String model;
  final int year;
  final VehicleType type;
  final VehicleStatus status;
  final String assignedDriver;
  final int mileageKm;
  final String notes;

  /// Full display title for the vehicle (e.g., "2024 Toyota Hilux").
  String get displayName => '$year $make $model';

  /// Creates an updated copy of this vehicle with modified fields.
  Vehicle copyWith({
    String? id,
    String? plateNumber,
    String? make,
    String? model,
    int? year,
    VehicleType? type,
    VehicleStatus? status,
    String? assignedDriver,
    int? mileageKm,
    String? notes,
  }) {
    return Vehicle(
      id: id ?? this.id,
      plateNumber: plateNumber ?? this.plateNumber,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      type: type ?? this.type,
      status: status ?? this.status,
      assignedDriver: assignedDriver ?? this.assignedDriver,
      mileageKm: mileageKm ?? this.mileageKm,
      notes: notes ?? this.notes,
    );
  }
}

