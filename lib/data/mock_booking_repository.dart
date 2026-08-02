import '../models/booking.dart';
import '../models/restaurant.dart';
import 'booking_repository.dart';

class MockBookingRepository implements BookingRepository {
  final List<Restaurant> _restaurants = const [
    Restaurant(
      id: 'olive-kitchen',
      name: 'The Olive Kitchen',
      cuisines: ['Italian', 'Pizza', 'Pasta'],
      rating: 4.6,
      priceLevel: 2,
      waitTime: '15–20 min',
      description:
          'A cozy Italian restaurant offering handmade pasta and wood-fired pizzas.',
      imageKey: 'italian',
    ),
    Restaurant(
      id: 'sushi-master',
      name: 'Sushi Master',
      cuisines: ['Japanese', 'Sushi'],
      rating: 4.6,
      priceLevel: 2,
      waitTime: '10–15 min',
      description:
          'Freshly prepared sushi and Japanese favourites in a warm setting.',
      imageKey: 'sushi',
    ),
    Restaurant(
      id: 'spice-route',
      name: 'Spice Route',
      cuisines: ['Asian', 'Indian'],
      rating: 4.8,
      priceLevel: 1,
      waitTime: '20–25 min',
      description:
          'Bold regional flavours, aromatic curries, and friendly service.',
      imageKey: 'spice',
    ),
    Restaurant(
      id: 'sweet-haven',
      name: 'Sweet Haven',
      cuisines: ['Dessert', 'Cafe', 'Cake'],
      rating: 4.7,
      priceLevel: 1,
      waitTime: '5–10 min',
      description:
          'Fresh cakes, pastries, and handcrafted drinks in a relaxed cafe.',
      imageKey: 'dessert',
    ),
  ];

  final List<Booking> _bookings = [
    Booking(
      id: 'booking-1',
      reference: 'RB260815-0012',
      restaurantId: 'olive-kitchen',
      restaurantName: 'The Olive Kitchen',
      dateTime: DateTime(2026, 8, 15, 13),
      partySize: 2,
      tableType: 'Window seat',
      specialRequest: '',
      status: BookingStatus.confirmed,
    ),
    Booking(
      id: 'booking-2',
      reference: 'RB260820-0013',
      restaurantId: 'sushi-master',
      restaurantName: 'Sushi Master',
      dateTime: DateTime(2026, 8, 20, 13),
      partySize: 2,
      tableType: 'Any available',
      specialRequest: '',
      status: BookingStatus.pending,
    ),
    Booking(
      id: 'booking-3',
      reference: 'RB260825-0014',
      restaurantId: 'spice-route',
      restaurantName: 'Spice Route',
      dateTime: DateTime(2026, 8, 25, 13),
      partySize: 2,
      tableType: 'Any available',
      specialRequest: '',
      status: BookingStatus.confirmed,
    ),
  ];

  Future<void> _delay() =>
      Future<void>.delayed(const Duration(milliseconds: 150));

  @override
  Future<List<Restaurant>> getRestaurants() async {
    await _delay();
    return List.unmodifiable(_restaurants);
  }

  @override
  Future<List<Booking>> getBookings() async {
    await _delay();
    return List.unmodifiable(_bookings);
  }

  @override
  Future<Booking> createBooking(Booking booking) async {
    await _delay();
    _bookings.insert(0, booking);
    return booking;
  }

  @override
  Future<Booking> updateBooking(Booking booking) async {
    await _delay();
    final index = _bookings.indexWhere((item) => item.id == booking.id);
    if (index == -1) throw StateError('Booking not found: ${booking.id}');
    _bookings[index] = booking;
    return booking;
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await _delay();
    final index = _bookings.indexWhere((item) => item.id == bookingId);
    if (index == -1) throw StateError('Booking not found: $bookingId');
    _bookings[index] =
        _bookings[index].copyWith(status: BookingStatus.cancelled);
  }
}
