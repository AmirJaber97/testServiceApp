

class Preferences {
  static const _preferencesBox = '_preferencesBox';
  static const _firstLaunch = '_firstLaunch';
  static const _darkMode = '_darkMode';
  static const _currentLanguage = '_currentLanguage';
  static const _scheduleViewCalendar = '_scheduleViewCalendar';
  static const _currentCity = '_currentCity';
  static const _coordinates = '_coordinates';
  static const _lastLoginMethod = '_lastLoginMethod';
  static const _loggedOut = '_loggedOut';
  static const _viberOtp = '_viberOtp';
  static const _telegramOtp = '_telegramOtp';
  static const _searchHistory = '_searchHistory';
  static const _noServicesInCity = '_noServicesInCity';
  static const _currentCountryCode = '_currentCountryCode';
  static const _currentBusinessPage = '_currentBusinessPage';
  static const _selectedCountryCode = '_selectedCountryCode';

  Box<dynamic> _box;

  Future openBox() async {
    this._box = await Hive.openBox<dynamic>(_preferencesBox);
  }

  bool isFirstLaunch() => _getValue(_firstLaunch) ?? true;

  Future setFirstLaunch(bool firstLaunch) =>
      _setValue(_firstLaunch, firstLaunch);

  bool darkMode() => _getValue(_darkMode) ?? false;

  Future setDarkMode(bool darkMode) => _setValue(_darkMode, darkMode);

  getLanguage() => _getValue(_currentLanguage);

  Future setLanguage(String language) => _setValue(_currentLanguage, language);

  getCurrentCountryCode() => _getValue(_currentCountryCode);

  Future setCurrentCountryCode(String code) => _setValue(_currentCountryCode, code);

  getCurrentCode() => _getValue(_selectedCountryCode);

  Future setCurrentCode(String codeN) => _setValue(_selectedCountryCode, codeN);

  bool getSelectedBusinessPage() => _getValue(_currentBusinessPage) ?? true;

  Future setSelectedBusinessPage(bool businessPage) =>
      _setValue(_currentBusinessPage, businessPage);

  bool isScheduleViewCalendar() => _getValue(_scheduleViewCalendar) ?? true;

  Future setScheduleViewCalender(bool viewCalendar) =>
      _setValue(_scheduleViewCalendar, viewCalendar);

  getCity() => _getValue(_currentCity);

  Future setCity(String location) => _setValue(_currentCity, location);

  getCoordinates() => _getValue(_coordinates);

  Future setCoordinates(List coordinates) =>
      _setValue(_coordinates, coordinates);

  getLoginMethod() =>
      LoginMethodExtention.toEnum(_getValue(_lastLoginMethod)) ?? null;

  Future setLoginMethod(LoginMethod loginMethod) =>
      _setValue(_lastLoginMethod, loginMethod.toString());

  bool loggedOut() => _getValue(_loggedOut);

  Future setLoggedOut(bool loggedOut) => _setValue(_loggedOut, loggedOut);

  getViberOtp() => _getValue(_viberOtp);

  Future setViberOtp(int otp) => _setValue(_viberOtp, otp);

  getTelegramOtp() => _getValue(_telegramOtp);

  Future setTelegramOtp(int otp) => _setValue(_telegramOtp, otp);

  getSearchHistory() {
    List<dynamic> sh = _getValue(_searchHistory);
    if (sh == null) {
      return [];
    } else {
      return sh;
    }
  }

  Future setSearchHistory(List<dynamic> history) {
    if (history.length > 5) {
      history.removeAt(0);
    }
    return _setValue(_searchHistory, history);
  }

  noServicesInCity() => _getValue(_noServicesInCity) ?? true;

  Future setNoServicesInCity(bool noServicesInCity) =>
      _setValue(_noServicesInCity, noServicesInCity);

  T _getValue<T>(dynamic key, {T defaultValue}) {
    logger.i(
        'Cache => Received ${_box.get(key, defaultValue: defaultValue) as T} from $key');
    return _box.get(key, defaultValue: defaultValue) as T;
  }

  Future _setValue<T>(dynamic key, T value) {
    logger.i('Cache => Setting $key to $value');
    return _box.put(key, value);
  }

  Future clearCache() {
    return _box.clear();
  }
}
