import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserPreferences {
  final String? monthlySpending;
  final bool? isOpenToNewCard;
  final String? additionalInfo;
  final List<String> selectedOptimizations;

  UserPreferences({
    this.monthlySpending,
    this.isOpenToNewCard,
    this.additionalInfo,
    this.selectedOptimizations = const [],
  });

  UserPreferences copyWith({
    String? monthlySpending,
    bool? isOpenToNewCard,
    String? additionalInfo,
    List<String>? selectedOptimizations,
  }) {
    return UserPreferences(
      monthlySpending: monthlySpending ?? this.monthlySpending,
      isOpenToNewCard: isOpenToNewCard ?? this.isOpenToNewCard,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      selectedOptimizations:
          selectedOptimizations ?? this.selectedOptimizations,
    );
  }
}

final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
  return UserPreferencesNotifier();
});

class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  UserPreferencesNotifier() : super(UserPreferences());

  void setMonthlySpending(String spending) {
    state = state.copyWith(monthlySpending: spending);
  }

  void setIsOpenToNewCard(bool isOpen) {
    state = state.copyWith(isOpenToNewCard: isOpen);
  }

  void setAdditionalInfo(String info) {
    state = state.copyWith(additionalInfo: info);
  }

  void toggleOptimization(String optimization) {
    final currentOptimizations = List<String>.from(state.selectedOptimizations);
    if (currentOptimizations.contains(optimization)) {
      currentOptimizations.remove(optimization);
    } else {
      currentOptimizations.add(optimization);
    }
    state = state.copyWith(selectedOptimizations: currentOptimizations);
  }

  void clearPreferences() {
    state = UserPreferences();
  }
}
