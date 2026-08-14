import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/local_storage.dart';

enum AppLanguage { bengali, english }

class LocaleNotifier extends StateNotifier<AppLanguage> {
  LocaleNotifier() : super(AppLanguage.bengali) {
    _loadSavedLocale();
  }

  void _loadSavedLocale() {
    final saved = WebLocalStorage.load('user_language');
    if (saved == 'en') {
      state = AppLanguage.english;
    } else {
      state = AppLanguage.bengali;
    }
  }

  bool get isFirstLaunch {
    return WebLocalStorage.load('has_selected_language') != 'true';
  }

  void setLanguage(AppLanguage language) {
    state = language;
    WebLocalStorage.save('user_language', language == AppLanguage.english ? 'en' : 'bn');
    WebLocalStorage.save('has_selected_language', 'true');
  }

  void toggleLanguage() {
    if (state == AppLanguage.bengali) {
      setLanguage(AppLanguage.english);
    } else {
      setLanguage(AppLanguage.bengali);
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, AppLanguage>((ref) {
  return LocaleNotifier();
});

extension LanguageExt on AppLanguage {
  String t(String bn, String en) {
    return this == AppLanguage.bengali ? bn : en;
  }

  bool get isBengali => this == AppLanguage.bengali;
}
