import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_preferences.dart';

class PreferencesScreen extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const PreferencesScreen({
    super.key,
    required this.onNext,
  });

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  final _additionalInfoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _additionalInfoController.text =
        ref.read(userPreferencesProvider).additionalInfo ?? '';
  }

  @override
  void dispose() {
    _additionalInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(userPreferencesProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Are you open to getting a new\ncard this year?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Text(
                'Yes / No',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Switch(
                value: preferences.isOpenToNewCard ?? false,
                onChanged: (value) {
                  ref
                      .read(userPreferencesProvider.notifier)
                      .setIsOpenToNewCard(value);
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Anything else we should know?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Share your goals, pain points, or expectations',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _additionalInfoController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type your answer here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              onChanged: (value) {
                ref
                    .read(userPreferencesProvider.notifier)
                    .setAdditionalInfo(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
