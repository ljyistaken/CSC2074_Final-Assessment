import 'package:flutter/material.dart';

import '../app.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/restaurant_image.dart';
import 'select_date_screen.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  const RestaurantDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final restaurant = BookingScope.of(context).selectedRestaurant!;
    return AppScaffold(
      bottom: AppButton(
        label: 'Select Date & Time',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SelectDateScreen()),
        ),
      ),
      child: ListView(
        children: [
          RestaurantImage(
            imageKey: restaurant.imageKey,
            imageData: restaurant.imageData,
            width: double.infinity,
            height: 280,
          ),
          const SizedBox(height: 24),
          Text(restaurant.name,
              style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 12),
          Text(restaurant.cuisineLabel,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppColors.muted)),
          const SizedBox(height: 20),
          Text(
            '★ ${restaurant.rating} · ${restaurant.priceLabel} · ${restaurant.waitTime}',
            style: const TextStyle(
              color: AppColors.warning,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 38),
          Text('About', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(restaurant.description,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppColors.muted, height: 1.7)),
        ],
      ),
    );
  }
}