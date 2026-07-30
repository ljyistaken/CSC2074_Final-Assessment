import '../models/booking.dart';
import '../models/restaurant.dart';

/// Backend contract for the restaurant booking feature.
///
/// A backend developer can implement this interface with Firebase, Supabase,
/// SQLite, or a REST API and replace [MockBookingRepository] in `app.dart`.
abstract interface class BookingRepository {
  Future<List<Restaurant>> getRestaurants();
  Future<List<Booking>> getBookings();
  Future<Booking> createBooking(Booking booking);
  Future<Booking> updateBooking(Booking booking);
  Future<void> cancelBooking(String bookingId);
}
