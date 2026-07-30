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
  });

  final String id;
  final String name;
  final List<String> cuisines;
  final double rating;
  final int priceLevel;
  final String waitTime;
  final String description;
  final String imageKey;

  String get cuisineLabel => cuisines.join(' · ');
  String get priceLabel => List.filled(priceLevel, r'$').join();

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json['id'] as String,
        name: json['name'] as String,
        cuisines: List<String>.from(json['cuisines'] as List),
        rating: (json['rating'] as num).toDouble(),
        priceLevel: json['priceLevel'] as int,
        waitTime: json['waitTime'] as String,
        description: json['description'] as String,
        imageKey: json['imageKey'] as String? ?? 'restaurant',
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
      };
}
