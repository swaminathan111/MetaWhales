import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_preferences.dart';

class SpendingCategoriesScreen extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const SpendingCategoriesScreen({
    super.key,
    required this.onNext,
  });

  @override
  ConsumerState<SpendingCategoriesScreen> createState() =>
      _SpendingCategoriesScreenState();
}

class _SpendingCategoriesScreenState
    extends ConsumerState<SpendingCategoriesScreen> {
  final Set<String> _selectedCategories = {};
  final int _maxSelections = 3;

  final List<CategoryItem> _categories = [
    CategoryItem(
      icon: Icons.shopping_cart,
      label: 'Groceries',
    ),
    CategoryItem(
      icon: Icons.shopping_bag,
      label: 'Online shopping',
    ),
    CategoryItem(
      icon: Icons.restaurant,
      label: 'Dining',
    ),
    CategoryItem(
      icon: Icons.flight,
      label: 'Travel',
    ),
    CategoryItem(
      icon: Icons.local_gas_station,
      label: 'Fuel',
    ),
    CategoryItem(
      icon: Icons.bolt,
      label: 'Utilities',
    ),
    CategoryItem(
      icon: Icons.movie,
      label: 'Entertainment',
    ),
    CategoryItem(
      icon: Icons.shopping_basket,
      label: 'Shopping',
    ),
    CategoryItem(
      icon: Icons.wifi,
      label: 'Internet',
    ),
  ];

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else if (_selectedCategories.length < _maxSelections) {
        _selectedCategories.add(category);
      }
    });

    // Save to UserPreferences provider
    ref
        .read(userPreferencesProvider.notifier)
        .setSelectedCategories(_selectedCategories.toList());
  }

  @override
  void initState() {
    super.initState();
    // Load existing categories from preferences
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final preferences = ref.read(userPreferencesProvider);
      setState(() {
        _selectedCategories.addAll(preferences.selectedCategories);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What are your main\nspending categories?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Select your top $_maxSelections spending areas to help us\npersonalize your experience',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategories.contains(category.label);
                return _CategoryTile(
                  icon: category.icon,
                  label: category.label,
                  isSelected: isSelected,
                  onTap: () => _toggleCategory(category.label),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryItem {
  final IconData icon;
  final String label;

  CategoryItem({
    required this.icon,
    required this.label,
  });
}

class _CategoryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color:
                isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color:
                    isSelected ? Theme.of(context).primaryColor : Colors.black,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
