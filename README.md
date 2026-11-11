# VMS Frontend (`vms-frontend`)

Responsive, desktop-first Flutter Web admin application for the **Vehicle Management System (VMS)**.

> **Architecture Note:** This repository contains **only** the Flutter Web frontend. The Java Spring Boot backend (`vms-backend`) is maintained as a separate project. Currently, this frontend operates using static/mock in-memory data.

## Project Structure

```text
lib/
├── main.dart                     # Application entry point & root navigation state
├── data/
│   └── mock_vehicles.dart        # Static mock dataset for local frontend development
├── models/
│   └── vehicle.dart              # Vehicle domain model, status enum, and type enum
├── navigation/
│   └── app_route.dart            # Top-level navigation destinations
├── screens/
│   ├── login_screen.dart         # Admin login screen with form validation
│   ├── vehicle_list_screen.dart  # Fleet dashboard, KPI cards, filters, and data table
│   └── vehicle_form_screen.dart  # Register / Edit vehicle screen
├── theme/
│   └── app_theme.dart            # Centralized Material 3 theme configuration
└── widgets/
    ├── app_shell.dart            # Responsive desktop sidebar + mobile drawer shell
    ├── status_badge.dart         # Reusable vehicle status pill badge
    └── summary_stat_card.dart    # Reusable fleet metric summary card
```

## Getting Started

```bash
flutter pub get
flutter analyze
flutter run -d chrome
```
