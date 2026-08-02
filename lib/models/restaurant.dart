class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisines,
    required this.rating,
    required this.priceLevel,
    required this.waitTime,
    required this.description,
    required this.imageKey,
    this.imageData,
  });

  final String id;
  final String name;
  final List<String> cuisines;
  final double rating;
  final int priceLevel;
  final String waitTime;
  final String description;

  /// Fallback style category ('italian', 'sushi', 'spice', 'dessert', ...)
  /// used to render a generated gradient+icon card when [imageData] is
  /// absent or fails to decode.
  final String imageKey;

  /// Optional base64-encoded JPEG, set by an admin via the "Manage
  /// Restaurants" screen. Kept well under Firestore's 1 MiB document limit
  /// by client-side compression before it's ever saved — see
  /// `lib/services/image_utils.dart`.
  final String? imageData;

  String get cuisineLabel => cuisines.join(' · ');
  String get priceLabel => List.filled(priceLevel, r'$').join();

  Restaurant copyWith({
    String? name,
    List<String>? cuisines,
    double? rating,
    int? priceLevel,
    String? waitTime,
    String? description,
    String? imageKey,
    String? imageData,
  }) =>
      Restaurant(
        id: id,
        name: name ?? this.name,
        cuisines: cuisines ?? this.cuisines,
        rating: rating ?? this.rating,
        priceLevel: priceLevel ?? this.priceLevel,
        waitTime: waitTime ?? this.waitTime,
        description: description ?? this.description,
        imageKey: imageKey ?? this.imageKey,
        imageData: imageData ?? this.imageData,
      );

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json['id'] as String,
        name: json['name'] as String,
        cuisines: List<String>.from(json['cuisines'] as List),
        rating: (json['rating'] as num).toDouble(),
        priceLevel: json['priceLevel'] as int,
        waitTime: json['waitTime'] as String,
        description: json['description'] as String,
        imageKey: json['imageKey'] as String? ?? 'restaurant',
        imageData: json['imageData'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'cuisines': cuisines,
        'rating': rating,
        'priceLevel': priceLevel,
        'waitTime': waitTime,
        'description': description,
        'imageKey': imageKey,
        'imageData': imageData,
      };
}