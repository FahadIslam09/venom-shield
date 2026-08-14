import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';

enum AppLanguage { bengali, english }

class LocaleNotifier extends StateNotifier<AppLanguage> {
  bool _isFirstLaunch;
  bool _dialogShown = false;

  LocaleNotifier({
    AppLanguage initialLanguage = AppLanguage.bengali,
    bool initialIsFirstLaunch = true,
  })  : _isFirstLaunch = initialIsFirstLaunch,
        super(initialLanguage);

  bool get isFirstLaunch => _isFirstLaunch && !_dialogShown;

  void markDialogShown() {
    _dialogShown = true;
  }

  void setLanguage(AppLanguage language) {
    state = language;
    _isFirstLaunch = false;
    _dialogShown = true;
    DatabaseHelper.instance.saveSetting('user_language', language == AppLanguage.english ? 'en' : 'bn');
    DatabaseHelper.instance.saveSetting('has_selected_language', 'true');
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
