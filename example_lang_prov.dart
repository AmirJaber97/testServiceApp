class LanguageProvider extends BaseModel {
  Preferences preferences;

  static String _language = 'en';

  Locale appLocale = Locale(_language);

  LanguageProvider() {
    init();
  }

  void init() {
    preferences = locator<Preferences>();
    language;
  }

  get language {
    setNotifier(NotifierState.Loading);
    _language = preferences.getLanguage();
    if (_language == null) {
      appLocale = null;
    } else {
      appLocale = Locale(_language);
    }
    setNotifier(NotifierState.Loaded);
  }

  void updateLanguage(String language) {
    setNotifier(NotifierState.Loading);
    preferences.setLanguage(language);

    switch (language) {
      case 'ru':
        appLocale = Locale(language);
        break;
      case 'uk':
        appLocale = Locale(language);
        break;
      case 'en':
        appLocale = Locale(language);
        break;
      default:
        appLocale = Locale('en');
        break;
    }
    setNotifier(NotifierState.Loaded);
  }
}
