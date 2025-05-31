import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  final SharedPreferences _prefs;
  static const String _hasCompletedOnboardingKey = 'has_completed_onboarding';
  static const String _isNewUserKey = 'is_new_user';
  static const String _selectedOptimizationsKey = 'selected_optimizations';
  static const String _selectedCategoriesKey = 'selected_categories';
  static const String _hasAddedCardKey = 'has_added_card';

  OnboardingService(this._prefs);

  bool get isNewUser => _prefs.getBool(_isNewUserKey) ?? true;
  bool get hasCompletedOnboarding =>
      _prefs.getBool(_hasCompletedOnboardingKey) ?? false;

  Future<void> setNewUser(bool isNew) async {
    await _prefs.setBool(_isNewUserKey, isNew);
  }

  Future<void> setOnboardingComplete() async {
    await _prefs.setBool(_hasCompletedOnboardingKey, true);
    await setNewUser(false);
  }

  Future<void> saveSelectedOptimizations(List<String> optimizations) async {
    await _prefs.setStringList(_selectedOptimizationsKey, optimizations);
  }

  List<String> getSelectedOptimizations() {
    return _prefs.getStringList(_selectedOptimizationsKey) ?? [];
  }

  Future<void> saveSelectedCategories(List<String> categories) async {
    await _prefs.setStringList(_selectedCategoriesKey, categories);
  }

  List<String> getSelectedCategories() {
    return _prefs.getStringList(_selectedCategoriesKey) ?? [];
  }

  Future<void> setHasAddedCard(bool value) async {
    await _prefs.setBool(_hasAddedCardKey, value);
  }

  bool get hasAddedCard => _prefs.getBool(_hasAddedCardKey) ?? false;

  Future<void> resetOnboarding() async {
    await _prefs.remove(_hasCompletedOnboardingKey);
    await _prefs.remove(_isNewUserKey);
    await _prefs.remove(_selectedOptimizationsKey);
    await _prefs.remove(_selectedCategoriesKey);
    await _prefs.remove(_hasAddedCardKey);
  }
}
