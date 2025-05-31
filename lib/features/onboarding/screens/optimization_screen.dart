import 'package:flutter/material.dart';

class OptimizationScreen extends StatelessWidget {
  final VoidCallback onNext;

  const OptimizationScreen({
    super.key,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final optimizations = [
      'Rewards / Cashback',
      'Lounge access',
      'Travel perks',
      'Low fees',
      'Fuel savings',
      'Dining deals',
    ];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What do you most want to\noptimise?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              itemCount: optimizations.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _OptimizationTile(
                  title: optimizations[index],
                  isSelected: index == 3, // Low fees selected by default
                  onTap: () {
                    // TODO: Handle optimization selection
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OptimizationTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptimizationTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: isSelected ? Theme.of(context).primaryColor : Colors.black,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
