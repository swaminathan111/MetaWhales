import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _hasCompletedOnboardingKey = 'has_completed_onboarding';
  static const String _isNewUserKey = 'is_new_user';

  final SharedPreferences _prefs;

  OnboardingService(this._prefs);

  bool get isNewUser => _prefs.getBool(_isNewUserKey) ?? true;
  bool get hasCompletedOnboarding =>
      _prefs.getBool(_hasCompletedOnboardingKey) ?? false;

  Future<void> setNewUser(bool isNew) async {
    await _prefs.setBool(_isNewUserKey, isNew);
  }

  Future<void> completeOnboarding() async {
    await _prefs.setBool(_hasCompletedOnboardingKey, true);
  }

  Future<void> resetOnboarding() async {
    await _prefs.setBool(_hasCompletedOnboardingKey, false);
  }
}
