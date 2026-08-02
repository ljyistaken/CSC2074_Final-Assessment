import 'package:flutter/material.dart';

import '../app.dart';
import '../models/restaurant.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/choice_chip_group.dart';
import 'restaurant_details_screen.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final searchController = TextEditingController();
  String cuisine = 'All';
  int price = 0;
  double rating = 0;
  bool showResults = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurants = BookingScope.of(context).restaurants.where((item) {
      final query = searchController.text.toLowerCase();
      return (query.isEmpty ||
              item.name.toLowerCase().contains(query) ||
              item.cuisineLabel.toLowerCase().contains(query)) &&
          (cuisine == 'All' || item.cuisines.contains(cuisine)) &&
          (price == 0 || item.priceLevel == price) &&
          (rating == 0 || item.rating >= rating);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => setState(() {
              searchController.clear();
              cuisine = 'All';
              price = 0;
              rating = 0;
              showResults = false;
            }),
            child: const Text('Reset'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Search restaurants...',
                  suffixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 22),
              _label('Cuisine'),
              Wrap(
                spacing: 9,
                children: ['All', 'Italian', 'Asian', 'Japanese']
                    .map((value) => AppChoiceChip(
                          label: value,
                          value: value,
                          selectedValue: cuisine,
                          onSelected: (value) =>
                              setState(() => cuisine = value),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              _label('Price Range'),
              Wrap(
                spacing: 9,
                children: [0, 1, 2, 3]
                    .map((value) => AppChoiceChip(
                          label: value == 0
                              ? 'All'
                              : List.filled(value, r'$').join(),
                          value: value,
                          selectedValue: price,
                          onSelected: (value) => setState(() => price = value),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              _label('Rating'),
              Wrap(
                spacing: 9,
                children: [0.0, 4.0, 4.5, 4.8]
                    .map((value) => AppChoiceChip(
                          label: value == 0 ? 'All' : '$value+',
                          value: value,
                          selectedValue: rating,
                          onSelected: (value) => setState(() => rating = value),
                        ))
                    .toList(),
              ),
              if (showResults) ...[
                const SizedBox(height: 18),
                Text('${restaurants.length} restaurants found',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    itemCount: restaurants.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, index) => _ResultTile(
                      restaurant: restaurants[index],
                    ),
                  ),
                ),
              ] else
                const Spacer(),
              AppButton(
                label: 'Apply Filters',
                onPressed: () => setState(() => showResults = true),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(value, style: Theme.of(context).textTheme.titleMedium),
      );
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.restaurant});
  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: AppColors.soft,
        child: Icon(Icons.restaurant, color: AppColors.red),
      ),
      title: Text(restaurant.name,
          style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text('${restaurant.cuisineLabel} • ★ ${restaurant.rating}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        BookingScope.of(context).selectRestaurant(restaurant);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RestaurantDetailsScreen()),
        );
      },
    );
  }
}
