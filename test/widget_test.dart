import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:front_end_final_assessment/app.dart';

void main() {
  testWidgets('shows the local splash screen', (tester) async {
    await tester.pumpWidget(const RestaurantBookingApp());
    expect(find.text('Delicious moments\nstart here'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('home category buttons filter restaurant results',
      (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const RestaurantBookingApp());
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter your email'),
      'user@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter your password'),
      'password',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
    await tester.pumpAndSettle();

    expect(find.text('Popular Restaurants'), findsOneWidget);
    await tester.tap(find.text('Asian'));
    await tester.pumpAndSettle();

    expect(find.text('Asian Restaurants'), findsOneWidget);
    expect(find.text('Sushi Master'), findsOneWidget);
    expect(find.text('The Olive Kitchen'), findsNothing);
  });
}
