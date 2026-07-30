import 'package:flutter/material.dart';

import 'controllers/booking_controller.dart';
import 'data/mock_booking_repository.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

class RestaurantBookingApp extends StatefulWidget {
  const RestaurantBookingApp({super.key});

  @override
  State<RestaurantBookingApp> createState() => _RestaurantBookingAppState();
}

class _RestaurantBookingAppState extends State<RestaurantBookingApp> {
  late final BookingController controller;

  @override
  void initState() {
    super.initState();
    controller = BookingController(repository: MockBookingRepository());
    controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BookingScope(
      controller: controller,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tablely',
        theme: AppTheme.light,
        home: const SplashScreen(),
        builder: (context, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) return child!;
              return ColoredBox(
                color: const Color(0xFF202020),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: SizedBox(
                      width: 430,
                      height: constraints.maxHeight,
                      child: child,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class BookingScope extends InheritedNotifier<BookingController> {
  const BookingScope({
    super.key,
    required BookingController controller,
    required super.child,
  }) : super(notifier: controller);

  static BookingController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<BookingScope>();
    assert(scope != null, 'BookingScope was not found in the widget tree.');
    return scope!.notifier!;
  }
}
