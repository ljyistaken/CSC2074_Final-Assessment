import 'package:flutter/material.dart';

import '../app.dart';
import '../data/firebase_booking_repository.dart';
import '../models/restaurant.dart';
import '../services/image_utils.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/choice_chip_group.dart';
import '../widgets/restaurant_image.dart';

/// Restaurant catalog management for admins.
///
/// Keeps its own local `restaurants` list rather than re-querying
/// Firestore after every change. Re-fetching immediately after a write
/// worked most of the time but could occasionally race ahead of the
/// write actually being visible to a fresh query -- updating the local
/// list directly with the exact object just saved sidesteps that
/// entirely and feels instant. The shared BookingController is updated
/// the same way (see upsertRestaurant/removeRestaurant) so the Explore
/// tab reflects the change immediately too.
class AdminRestaurantsScreen extends StatefulWidget {
  const AdminRestaurantsScreen({super.key});

  @override
  State<AdminRestaurantsScreen> createState() =>
      _AdminRestaurantsScreenState();
}

class _AdminRestaurantsScreenState extends State<AdminRestaurantsScreen> {
  final repository = FirebaseBookingRepository();
  List<Restaurant>? restaurants;
  String? loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await repository.getRestaurants();
      if (!mounted) return;
      setState(() {
        restaurants = result;
        loadError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => loadError = '$error');
    }
  }

  void _applyAdded(Restaurant restaurant) {
    setState(() => restaurants = [...?restaurants, restaurant]);
    BookingScope.of(context).upsertRestaurant(restaurant);
    _refreshAll();
  }

  void _applyUpdated(Restaurant restaurant) {
    setState(() {
      restaurants = [
        for (final item in restaurants ?? const <Restaurant>[])
          if (item.id == restaurant.id) restaurant else item,
      ];
    });
    BookingScope.of(context).upsertRestaurant(restaurant);
    _refreshAll();
  }

  Future<void> _delete(Restaurant restaurant) async {
    try {
      await repository.deleteRestaurant(restaurant.id);
      if (!mounted) return;
      setState(() {
        restaurants = (restaurants ?? const <Restaurant>[])
            .where((item) => item.id != restaurant.id)
            .toList();
      });
      BookingScope.of(context).removeRestaurant(restaurant.id);
      await _refreshAll();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete: $error')),
      );
    }
  }

  Future<void> _seedStarterRestaurants() async {
    await repository.seedDefaultRestaurantsIfEmpty();
    await _refreshAll();
  }

  /// Re-fetches the admin list from Firestore and re-runs the shared
  /// controller's load, so both the admin screen and the Explore tab are
  /// guaranteed to reflect whatever is actually saved -- called after
  /// every add/edit/delete on top of the instant local-state update
  /// above, and also wired to a manual refresh button / pull-to-refresh
  /// as a fallback you can always trigger yourself.
  Future<void> _refreshAll() async {
    await _load();
    if (!mounted) return;
    await BookingScope.of(context).initialize();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Manage Restaurants',
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: _refreshAll,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      bottom: AppButton(
        label: 'Add Restaurant',
        icon: Icons.add_rounded,
        onPressed: () async {
          final result = await Navigator.push<Restaurant>(
            context,
            MaterialPageRoute(
              builder: (_) => _RestaurantFormScreen(repository: repository),
            ),
          );
          if (result != null) _applyAdded(result);
        },
      ),
      child: Builder(
        builder: (context) {
          if (loadError != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_rounded,
                        color: AppColors.red, size: 52),
                    const SizedBox(height: 14),
                    Text(loadError!, textAlign: TextAlign.center),
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: _load,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }
          final loaded = restaurants;
          if (loaded == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (loaded.isEmpty) ...[
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'No restaurants yet.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Load Starter Restaurants',
                  outlined: true,
                  onPressed: _seedStarterRestaurants,
                ),
                const SizedBox(height: 16),
              ],
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshAll,
                  child: ListView.separated(
                    itemCount: loaded.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final restaurant = loaded[index];
                      return _AdminRestaurantTile(
                        restaurant: restaurant,
                        onEdit: () async {
                          final result = await Navigator.push<Restaurant>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => _RestaurantFormScreen(
                                repository: repository,
                                existing: restaurant,
                              ),
                            ),
                          );
                          if (result != null) _applyUpdated(result);
                        },
                        onDelete: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Delete restaurant?'),
                              content: Text(
                                'This removes "${restaurant.name}" for everyone. '
                                'This cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) await _delete(restaurant);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AdminRestaurantTile extends StatelessWidget {
  const _AdminRestaurantTile({
    required this.restaurant,
    required this.onEdit,
    required this.onDelete,
  });

  final Restaurant restaurant;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          RestaurantImage(
            imageKey: restaurant.imageKey,
            imageData: restaurant.imageData,
            width: 74,
            height: 74,
            borderRadius: 14,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(restaurant.name,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(restaurant.cuisineLabel,
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: AppColors.red),
          ),
        ],
      ),
    );
  }
}

class _RestaurantFormScreen extends StatefulWidget {
  const _RestaurantFormScreen({
    required this.repository,
    this.existing,
  });

  final FirebaseBookingRepository repository;
  final Restaurant? existing;

  @override
  State<_RestaurantFormScreen> createState() => _RestaurantFormScreenState();
}

class _RestaurantFormScreenState extends State<_RestaurantFormScreen> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController cuisinesController;
  late final TextEditingController ratingController;
  late final TextEditingController waitTimeController;
  late final TextEditingController descriptionController;
  late int priceLevel;
  late String imageKey;
  String? imageData;
  late Set<String> exploreCategories;
  bool saving = false;
  bool pickingImage = false;

  bool get isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    nameController = TextEditingController(text: existing?.name ?? '');
    cuisinesController =
        TextEditingController(text: existing?.cuisines.join(', ') ?? '');
    ratingController =
        TextEditingController(text: existing?.rating.toString() ?? '4.5');
    waitTimeController =
        TextEditingController(text: existing?.waitTime ?? '10–15 min');
    descriptionController =
        TextEditingController(text: existing?.description ?? '');
    priceLevel = existing?.priceLevel ?? 2;
    imageKey = existing?.imageKey ?? 'italian';
    imageData = existing?.imageData;
    exploreCategories = _detectCategories(existing?.cuisines ?? const []);
  }

  /// The Explore tab's category filter (see home_screen.dart) matches
  /// specific keywords in `cuisines` rather than a dedicated field. These
  /// toggles guarantee the right keyword is present instead of relying on
  /// free-text cuisines happening to match, and pre-check themselves here
  /// when editing an existing restaurant.
  static Set<String> _detectCategories(List<String> cuisines) {
    final lower = cuisines.map((c) => c.toLowerCase()).toSet();
    const asianKeywords = {
      'asian',
      'japanese',
      'indian',
      'sushi',
      'chinese',
      'korean',
    };
    const dessertKeywords = {'dessert', 'bakery', 'cafe', 'cake'};
    return {
      if (lower.contains('italian')) 'Italian',
      if (lower.any(asianKeywords.contains)) 'Asian',
      if (lower.any(dessertKeywords.contains)) 'Dessert',
    };
  }

  @override
  void dispose() {
    nameController.dispose();
    cuisinesController.dispose();
    ratingController.dispose();
    waitTimeController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickPhoto() async {
    setState(() => pickingImage = true);
    try {
      final encoded = await ImageUtils.pickAndEncodeImage();
      if (encoded != null) setState(() => imageData = encoded);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    } finally {
      if (mounted) setState(() => pickingImage = false);
    }
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => saving = true);
    try {
      final typedCuisines = cuisinesController.text
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList();
      // Merge in the Explore Category toggles, de-duped case-insensitively
      // against whatever was typed (e.g. typing "Italian" and toggling
      // the Italian chip shouldn't produce two entries).
      final seen = <String>{};
      final combinedCuisines = <String>[];
      for (final cuisine in [...typedCuisines, ...exploreCategories]) {
        if (seen.add(cuisine.toLowerCase())) combinedCuisines.add(cuisine);
      }
      final restaurant = Restaurant(
        id: widget.existing?.id ??
            'restaurant-${DateTime.now().millisecondsSinceEpoch}',
        name: nameController.text.trim(),
        cuisines: combinedCuisines,
        rating: double.tryParse(ratingController.text.trim()) ?? 4.5,
        priceLevel: priceLevel,
        waitTime: waitTimeController.text.trim(),
        description: descriptionController.text.trim(),
        imageKey: imageKey,
        imageData: imageData,
      );
      if (isEditing) {
        await widget.repository.updateRestaurant(restaurant);
      } else {
        await widget.repository.addRestaurant(restaurant);
      }
      if (!mounted) return;
      // Return the exact saved object so the caller can update its lists
      // directly instead of re-querying Firestore.
      Navigator.pop(context, restaurant);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: $error')),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: isEditing ? 'Edit Restaurant' : 'Add Restaurant',
      bottom: AppButton(
        label: saving ? 'Saving...' : 'Save Restaurant',
        onPressed: saving ? null : save,
      ),
      child: Form(
        key: formKey,
        child: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: pickingImage ? null : pickPhoto,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    RestaurantImage(
                      imageKey: imageKey,
                      imageData: imageData,
                      width: 160,
                      height: 120,
                      borderRadius: 16,
                    ),
                    Container(
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.red,
                        shape: BoxShape.circle,
                      ),
                      child: pickingImage
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.camera_alt_rounded,
                              color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                imageData != null
                    ? 'Tap to change photo'
                    : 'Tap to add a photo (optional)',
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),
            _label('Fallback Style'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 9,
              children: ['italian', 'sushi', 'spice', 'dessert']
                  .map((key) => AppChoiceChip(
                        label: key[0].toUpperCase() + key.substring(1),
                        value: key,
                        selectedValue: imageKey,
                        onSelected: (value) => setState(() => imageKey = value),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 6),
            const Text(
              'Used when no photo is set, or if the photo fails to load.',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 24),
            _label('Explore Categories'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 9,
              children: ['Italian', 'Asian', 'Dessert'].map((category) {
                final selected = exploreCategories.contains(category);
                return FilterChip(
                  label: Text(category),
                  selected: selected,
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                  backgroundColor: Colors.white,
                  selectedColor: AppColors.red,
                  side: BorderSide(
                    color: selected ? AppColors.red : AppColors.border,
                    width: 1.4,
                  ),
                  shape: const StadiumBorder(),
                  onSelected: (value) => setState(() {
                    if (value) {
                      exploreCategories.add(category);
                    } else {
                      exploreCategories.remove(category);
                    }
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 6),
            const Text(
              'Controls which Explore tab filter chips this restaurant '
              'shows up under. Select none if it doesn\'t fit any.',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 24),
            _label('Name'),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Restaurant name'),
              validator: (value) =>
                  (value?.trim().isNotEmpty ?? false) ? null : 'Required',
            ),
            const SizedBox(height: 18),
            _label('Cuisines (comma separated)'),
            TextFormField(
              controller: cuisinesController,
              decoration: const InputDecoration(
                  hintText: 'e.g. Italian, Pizza, Pasta'),
              validator: (value) =>
                  (value?.trim().isNotEmpty ?? false) ? null : 'Required',
            ),
            const SizedBox(height: 18),
            _label('Description'),
            TextFormField(
              controller: descriptionController,
              maxLines: 3,
              decoration:
                  const InputDecoration(hintText: 'Short description'),
              validator: (value) =>
                  (value?.trim().isNotEmpty ?? false) ? null : 'Required',
            ),
            const SizedBox(height: 18),
            _label('Rating (0–5)'),
            TextFormField(
              controller: ratingController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: 'e.g. 4.6'),
              validator: (value) {
                final parsed = double.tryParse(value?.trim() ?? '');
                if (parsed == null || parsed < 0 || parsed > 5) {
                  return 'Enter a number from 0 to 5';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            _label('Wait Time'),
            TextFormField(
              controller: waitTimeController,
              decoration: const InputDecoration(hintText: 'e.g. 10–15 min'),
              validator: (value) =>
                  (value?.trim().isNotEmpty ?? false) ? null : 'Required',
            ),
            const SizedBox(height: 18),
            _label('Price Level'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 9,
              children: [1, 2, 3]
                  .map((level) => AppChoiceChip(
                        label: List.filled(level, r'$').join(),
                        value: level,
                        selectedValue: priceLevel,
                        onSelected: (value) =>
                            setState(() => priceLevel = value),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style:
                const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      );
}