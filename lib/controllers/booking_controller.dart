import 'package:flutter/foundation.dart';

import '../data/booking_repository.dart';
import '../models/booking.dart';
import '../models/restaurant.dart';

class BookingController extends ChangeNotifier {
  BookingController({required BookingRepository repository})
      : _repository = repository;

  final BookingRepository _repository;
  List<Restaurant> restaurants = [];
  List<Booking> bookings = [];
  Restaurant? selectedRestaurant;
  DateTime selectedDate = DateTime(2026, 8, 15);
  int selectedHour = 13;
  int partySize = 2;
  String tableType = 'Any available';
  String specialRequest = '';
  bool isLoading = false;
  String? errorMessage;

  Future<void> initialize() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.getRestaurants(),
        _repository.getBookings(),
      ]);
      restaurants = results[0] as List<Restaurant>;
      bookings = results[1] as List<Booking>;
      selectedRestaurant = restaurants.firstOrNull;
    } catch (_) {
      errorMessage = 'Unable to load restaurant data.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Clears all session state. Called when the signed-in user signs out,
  /// so a shared browser/device doesn't briefly show the previous
  /// account's restaurants/bookings before the next person signs in.
  void reset() {
    restaurants = [];
    bookings = [];
    selectedRestaurant = null;
    selectedDate = DateTime(2026, 8, 15);
    selectedHour = 13;
    partySize = 2;
    tableType = 'Any available';
    specialRequest = '';
    isLoading = false;
    errorMessage = null;
    notifyListeners();
  }

  /// Adds or replaces [restaurant] in the in-memory list, keyed by id.
  /// Used by the admin screen right after a successful Firestore write so
  /// the Explore tab updates immediately instead of waiting on a fresh
  /// fetch (which can lag slightly behind a write that just happened).
  void upsertRestaurant(Restaurant restaurant) {
    final index = restaurants.indexWhere((item) => item.id == restaurant.id);
    if (index == -1) {
      restaurants = [...restaurants, restaurant];
    } else {
      restaurants = [
        for (final item in restaurants)
          if (item.id == restaurant.id) restaurant else item,
      ];
    }
    notifyListeners();
  }

  /// Removes the restaurant with [restaurantId] from the in-memory list.
  /// Used by the admin screen right after a successful delete.
  void removeRestaurant(String restaurantId) {
    restaurants = restaurants.where((item) => item.id != restaurantId).toList();
    if (selectedRestaurant?.id == restaurantId) {
      selectedRestaurant = restaurants.firstOrNull;
    }
    notifyListeners();
  }

  void selectRestaurant(Restaurant restaurant) {
    selectedRestaurant = restaurant;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
  }

  void selectHour(int hour) {
    selectedHour = hour;
    notifyListeners();
  }

  void selectPartySize(int size) {
    partySize = size;
    notifyListeners();
  }

  void updateDraft({String? newTableType, String? newSpecialRequest}) {
    tableType = newTableType ?? tableType;
    specialRequest = newSpecialRequest ?? specialRequest;
    notifyListeners();
  }

  Future<Booking> confirmBooking() async {
    final restaurant = selectedRestaurant;
    if (restaurant == null) {
      throw StateError('Select a restaurant before creating a booking.');
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final booking = Booking(
      id: 'booking-$now',
      reference:
          'RB${selectedDate.month.toString().padLeft(2, '0')}${selectedDate.day.toString().padLeft(2, '0')}-${now.toString().substring(7)}',
      restaurantId: restaurant.id,
      restaurantName: restaurant.name,
      dateTime: DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedHour,
      ),
      partySize: partySize,
      tableType: tableType,
      specialRequest: specialRequest,
      status: BookingStatus.confirmed,
    );
    final created = await _repository.createBooking(booking);
    bookings = [created, ...bookings];
    notifyListeners();
    return created;
  }

  Future<Booking> updateBooking(Booking booking) async {
    final updated = await _repository.updateBooking(booking);
    bookings = [
      for (final item in bookings)
        if (item.id == updated.id) updated else item,
    ];
    notifyListeners();
    return updated;
  }

  Future<void> cancelBooking(Booking booking) async {
    await _repository.cancelBooking(booking.id);
    bookings = [
      for (final item in bookings)
        if (item.id == booking.id)
          item.copyWith(status: BookingStatus.cancelled)
        else
          item,
    ];
    notifyListeners();
  }
}