import 'package:flutter_test/flutter_test.dart';
import 'package:front_end_final_assessment/controllers/booking_controller.dart';
import 'package:front_end_final_assessment/data/mock_booking_repository.dart';
import 'package:front_end_final_assessment/models/booking.dart';

void main() {
  late BookingController controller;

  setUp(() async {
    controller = BookingController(repository: MockBookingRepository());
    await controller.initialize();
  });

  tearDown(() => controller.dispose());

  test('loads restaurants and bookings from repository', () {
    expect(controller.errorMessage, isNull);
    expect(controller.restaurants, isNotEmpty);
    expect(controller.bookings, hasLength(3));
    expect(controller.selectedRestaurant, isNotNull);
  });

  test('creates a booking from the current draft', () async {
    final previousCount = controller.bookings.length;
    controller.selectDate(DateTime(2026, 9, 12));
    controller.selectHour(19);
    controller.selectPartySize(4);
    controller.updateDraft(
      newTableType: 'Outdoor',
      newSpecialRequest: 'Nut allergy',
    );

    final booking = await controller.confirmBooking();

    expect(controller.bookings, hasLength(previousCount + 1));
    expect(booking.partySize, 4);
    expect(booking.dateTime.hour, 19);
    expect(booking.tableType, 'Outdoor');
    expect(booking.specialRequest, 'Nut allergy');
  });

  test('updates and cancels an existing booking', () async {
    final original = controller.bookings.first;
    final updated = original.copyWith(
      partySize: 3,
      tableType: 'Window seat',
    );

    await controller.updateBooking(updated);
    expect(
      controller.bookings
          .firstWhere((item) => item.id == original.id)
          .partySize,
      3,
    );

    await controller.cancelBooking(updated);
    expect(
      controller.bookings.firstWhere((item) => item.id == original.id).status,
      BookingStatus.cancelled,
    );
  });
}
