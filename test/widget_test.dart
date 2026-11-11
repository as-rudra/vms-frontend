import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vms_frontend/main.dart';

void main() {
  testWidgets('VMS Admin login and vehicle list navigation smoke test', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const VmsAdminApp());

    // Verify Login screen is displayed initially.
    expect(find.text('Sign in to VMS Admin'), findsOneWidget);
    expect(find.text('Sign In to Dashboard'), findsOneWidget);

    // Tap sign-in button with pre-filled demo credentials.
    await tester.tap(find.text('Sign In to Dashboard'));
    await tester.pumpAndSettle();

    // Verify application shell and mock vehicle list are displayed.
    expect(find.text('Total Vehicles'), findsOneWidget);
    expect(find.text('VMS-4021'), findsOneWidget);
  });
}
