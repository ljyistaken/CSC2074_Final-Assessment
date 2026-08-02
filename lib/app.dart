import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'controllers/booking_controller.dart';
import 'data/firebase_booking_repository.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

class RestaurantBookingApp extends StatefulWidget {
  const RestaurantBookingApp({super.key});

  @override
  State<RestaurantBookingApp> createState() => _RestaurantBookingAppState();
}

class _RestaurantBookingAppState extends State<RestaurantBookingApp> {
  // Created once for the lifetime of the app. FirebaseBookingRepository
  // reads FirebaseAuth.instance.currentUser at call time rather than
  // caching a uid, so this single instance keeps working correctly across
  // sign-in, sign-out, and switching accounts.
  late final BookingController controller;

  // Checked exactly once, synchronously, at startup -- NOT via a stream.
  // FirebaseAuth restores any persisted session as part of
  // Firebase.initializeApp() in main.dart, which already finished before
  // this widget builds, so `currentUser` already reflects the real
  // signed-in state here. This avoids depending on authStateChanges()
  // firing promptly, which turned out to be unreliable in Flutter Web dev
  // sessions. Login, sign-up, and logout each navigate explicitly instead
  // of waiting on that stream -- see login_screen.dart and
  // settings_screen.dart.
  late final bool startedSignedIn;

  @override
  void initState() {
    super.initState();
    controller = BookingController(repository: FirebaseBookingRepository());
    startedSignedIn = FirebaseAuth.instance.currentUser != null;
    if (startedSignedIn) {
      // Fire-and-forget: HomeScreen shows its own loading spinner via
      // controller.isLoading while this resolves.
      controller.initialize();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // IMPORTANT: BookingScope wraps MaterialApp itself, i.e. it sits
    // *above* the Navigator. Every route pushed anywhere in the app --
    // no matter how deep -- is a descendant of this widget and can reach
    // BookingScope.of(context). Nesting BookingScope *inside* a route's
    // content breaks that, since routes pushed via Navigator.push are
    // siblings of each other in the widget tree, not descendants.
    return BookingScope(
      controller: controller,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tablely',
        theme: AppTheme.light,
        home: startedSignedIn ? const HomeScreen() : const SplashScreen(),
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