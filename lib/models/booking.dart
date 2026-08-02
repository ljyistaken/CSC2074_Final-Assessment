enum BookingStatus { confirmed, pending, cancelled }

class Booking {
  const Booking({
    required this.id,
    required this.reference,
    required this.restaurantId,
    required this.restaurantName,
    required this.dateTime,
    required this.partySize,
    required this.tableType,
    required this.specialRequest,
    required this.status,
  });

  final String id;
  final String reference;
  final String restaurantId;
  final String restaurantName;
  final DateTime dateTime;
  final int partySize;
  final String tableType;
  final String specialRequest;
  final BookingStatus status;

  Booking copyWith({
    DateTime? dateTime,
    int? partySize,
    String? tableType,
    String? specialRequest,
    BookingStatus? status,
  }) =>
      Booking(
        id: id,
        reference: reference,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        dateTime: dateTime ?? this.dateTime,
        partySize: partySize ?? this.partySize,
        tableType: tableType ?? this.tableType,
        specialRequest: specialRequest ?? this.specialRequest,
        status: status ?? this.status,
      );

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'] as String,
        reference: json['reference'] as String,
        restaurantId: json['restaurantId'] as String,
        restaurantName: json['restaurantName'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        partySize: json['partySize'] as int,
        tableType: json['tableType'] as String,
        specialRequest: json['specialRequest'] as String? ?? '',
        status: BookingStatus.values.byName(json['status'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'reference': reference,
        'restaurantId': restaurantId,
        'restaurantName': restaurantName,
        'dateTime': dateTime.toIso8601String(),
        'partySize': partySize,
        'tableType': tableType,
        'specialRequest': specialRequest,
        'status': status.name,
      };
}
