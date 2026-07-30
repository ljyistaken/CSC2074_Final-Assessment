# Restaurant Booking Front End

A local-first Flutter implementation of the CSC2074 restaurant booking
prototype. The app uses Flutter SDK components and does not require internet
access, authentication, or a database.

## Run locally

```sh
flutter pub get
flutter run
```

## Project structure

- `lib/screens/` - one file per prototype screen
- `lib/widgets/` - reusable interface components
- `lib/models/` - backend-friendly restaurant and booking models
- `lib/controllers/` - booking state and user actions
- `lib/data/booking_repository.dart` - database/backend contract
- `lib/data/mock_booking_repository.dart` - local mock implementation
- `lib/theme/` - shared colours and typography

## Connecting a database later

Create a class such as `FirebaseBookingRepository` or
`SupabaseBookingRepository` that implements `BookingRepository`. Implement its
five methods using the chosen backend, then replace this line in `lib/app.dart`:

```dart
controller = BookingController(repository: MockBookingRepository());
```

with the new repository:

```dart
controller = BookingController(repository: FirebaseBookingRepository());
```

The screens and controller do not need to be rewritten. Both models include
`fromJson` and `toJson` helpers for database/API mapping.
