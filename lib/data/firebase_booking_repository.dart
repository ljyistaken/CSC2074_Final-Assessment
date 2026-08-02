import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/booking.dart';
import '../models/restaurant.dart';
import 'booking_repository.dart';

/// Firestore-backed implementation of [BookingRepository]. Also exposes
/// extra restaurant-management methods (add/update/delete/seed) used by
/// the admin screen -- those aren't part of the shared [BookingRepository]
/// interface since they're an admin-only concern, not something every
/// backend implementation needs to support.
///
/// Firestore layout:
/// ```
/// users/{uid}                  { email, role: 'user' | 'admin' }
/// restaurants/{restaurantId}   shared catalog, same for every signed-in user
/// bookings/{bookingId}         has a `userId` field scoping it to the
///                              account that created it (see firestore.rules)
/// ```
class FirebaseBookingRepository implements BookingRepository {
  FirebaseBookingRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _restaurants =>
      _db.collection('restaurants');
  CollectionReference<Map<String, dynamic>> get _bookings =>
      _db.collection('bookings');

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('No signed-in user. Cannot access booking data.');
    }
    return uid;
  }

  @override
  Future<List<Restaurant>> getRestaurants() async {
    final snapshot = await _restaurants.get();
    return snapshot.docs.map(_restaurantFromDoc).toList();
  }

  @override
  Future<List<Booking>> getBookings() async {
    final snapshot = await _bookings.where('userId', isEqualTo: _uid).get();
    final bookings = snapshot.docs.map(_bookingFromDoc).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return bookings;
  }

  @override
  Future<Booking> createBooking(Booking booking) async {
    await _bookings.doc(booking.id).set({
      ...booking.toJson(),
      'userId': _uid,
    });
    return booking;
  }

  @override
  Future<Booking> updateBooking(Booking booking) async {
    final doc = _bookings.doc(booking.id);
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      throw StateError('Booking not found: ${booking.id}');
    }
    await doc.update(booking.toJson());
    return booking;
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await _bookings.doc(bookingId).update({
      'status': BookingStatus.cancelled.name,
    });
  }

  // --- Admin-only restaurant management -----------------------------------
  // Enforced server-side too: firestore.rules only allows writes to
  // `restaurants` from accounts whose users/{uid}.role == 'admin'.

  Future<void> addRestaurant(Restaurant restaurant) async {
    await _restaurants.doc(restaurant.id).set(restaurant.toJson());
  }

  Future<void> updateRestaurant(Restaurant restaurant) async {
    await _restaurants.doc(restaurant.id).update(restaurant.toJson());
  }

  Future<void> deleteRestaurant(String restaurantId) async {
    await _restaurants.doc(restaurantId).delete();
  }

  /// Populates the `restaurants` collection with the built-in starter
  /// catalog. Only writes if the collection is currently empty. This is
  /// intentionally *not* called automatically from [getRestaurants] --
  /// trigger it manually (e.g. the "Load Starter Restaurants" button on
  /// the admin screen) so deleting the last restaurant doesn't silently
  /// bring the defaults back.
  Future<void> seedDefaultRestaurantsIfEmpty() async {
    final snapshot = await _restaurants.limit(1).get();
    if (snapshot.docs.isNotEmpty) return;
    final batch = _db.batch();
    for (final restaurant in _defaultRestaurants) {
      batch.set(_restaurants.doc(restaurant.id), restaurant.toJson());
    }
    await batch.commit();
  }

  Restaurant _restaurantFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return Restaurant.fromJson({'id': doc.id, ...doc.data()});
  }

  Booking _bookingFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return Booking.fromJson({'id': doc.id, ...doc.data()});
  }

  static const _defaultRestaurants = [
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
}