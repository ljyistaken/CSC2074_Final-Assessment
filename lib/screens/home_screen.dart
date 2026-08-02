import 'package:flutter/material.dart';

import '../app.dart';
import '../models/restaurant.dart';
import '../theme/app_theme.dart';
import '../widgets/restaurant_image.dart';
import 'my_bookings_screen.dart';
import 'restaurant_details_screen.dart';
import 'search_filter_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentIndex == 0
          ? const _ExploreBody()
          : MyBookingsScreen(
              embedded: true,
              onBack: () => setState(() => currentIndex = 0),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        indicatorColor: AppColors.soft,
        onDestinationSelected: (value) => setState(() => currentIndex = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore, color: AppColors.red),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon:
                Icon(Icons.calendar_month_rounded, color: AppColors.red),
            label: 'My Bookings',
          ),
        ],
      ),
    );
  }
}

class _ExploreBody extends StatefulWidget {
  const _ExploreBody();

  @override
  State<_ExploreBody> createState() => _ExploreBodyState();
}

class _ExploreBodyState extends State<_ExploreBody> {
  String selectedCategory = 'All';

  List<Restaurant> _filteredRestaurants(List<Restaurant> restaurants) {
    if (selectedCategory == 'All') return restaurants;
    return restaurants.where((restaurant) {
      final cuisines =
          restaurant.cuisines.map((value) => value.toLowerCase()).toSet();
      return switch (selectedCategory) {
        'Italian' => cuisines.contains('italian'),
        'Asian' => cuisines.any(
            {'asian', 'japanese', 'indian', 'sushi', 'chinese', 'korean'}
                .contains,
          ),
        'Dessert' =>
          cuisines.any({'dessert', 'bakery', 'cafe', 'cake'}.contains),
        _ => true,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final controller = BookingScope.of(context);
    final visibleRestaurants = _filteredRestaurants(controller.restaurants);
    return SafeArea(
      child: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : controller.errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off_rounded,
                            color: AppColors.red, size: 52),
                        const SizedBox(height: 14),
                        Text(controller.errorMessage!,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 14),
                        FilledButton(
                          onPressed: controller.initialize,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: controller.initialize,
                  child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 38, 24, 0),
                      sliver: SliverList.list(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text('Hi, User!',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge),
                              ),
                              IconButton.filled(
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.red,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const SettingsScreen()),
                                ),
                                icon: const Icon(Icons.person_outline_rounded),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'What would you like to eat today?',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppColors.muted,
                                    ),
                          ),
                          const SizedBox(height: 30),
                          TextField(
                            readOnly: true,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SearchFilterScreen()),
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Search restaurants, cuisines...',
                              suffixIcon: Icon(Icons.search_rounded,
                                  color: AppColors.ink),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text('Categories',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _Category(
                                icon: Icons.restaurant,
                                label: 'All',
                                selected: selectedCategory == 'All',
                                onTap: () =>
                                    setState(() => selectedCategory = 'All'),
                              ),
                              _Category(
                                icon: Icons.local_pizza,
                                label: 'Italian',
                                selected: selectedCategory == 'Italian',
                                onTap: () => setState(
                                    () => selectedCategory = 'Italian'),
                              ),
                              _Category(
                                icon: Icons.ramen_dining,
                                label: 'Asian',
                                selected: selectedCategory == 'Asian',
                                onTap: () =>
                                    setState(() => selectedCategory = 'Asian'),
                              ),
                              _Category(
                                icon: Icons.cake,
                                label: 'Dessert',
                                selected: selectedCategory == 'Dessert',
                                onTap: () => setState(
                                    () => selectedCategory = 'Dessert'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Text(
                              selectedCategory == 'All'
                                  ? 'Popular Restaurants'
                                  : '$selectedCategory Restaurants',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    if (visibleRestaurants.isEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            children: [
                              const Icon(Icons.no_meals_outlined,
                                  color: AppColors.muted, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                'No $selectedCategory restaurants available.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (visibleRestaurants.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                        sliver: SliverGrid.builder(
                          itemCount: visibleRestaurants.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: .69,
                          ),
                          itemBuilder: (context, index) => _RestaurantCard(
                            restaurant: visibleRestaurants[index],
                          ),
                        ),
                      ),
                  ],
                  ),
                ),
    );
  }
}

class _Category extends StatelessWidget {
  const _Category({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$label category',
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 62,
                height: 50,
                decoration: BoxDecoration(
                  color: selected ? AppColors.red : AppColors.soft,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  icon,
                  color: selected ? Colors.white : AppColors.red,
                  size: 28,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.red : AppColors.muted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({required this.restaurant});
  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        BookingScope.of(context).selectRestaurant(restaurant);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RestaurantDetailsScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RestaurantImage(
              imageKey: restaurant.imageKey,
              imageData: restaurant.imageData,
              height: 122,
              width: double.infinity,
              borderRadius: 19,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      restaurant.cuisineLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                    const Spacer(),
                    Text(
                      '★ ${restaurant.rating}',
                      style: const TextStyle(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}