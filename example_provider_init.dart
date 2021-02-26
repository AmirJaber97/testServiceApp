final logger = getLogger('Main');

void main({String env}) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (env == null) env = 'prod';
  bool isDev = env == 'dev';
  await init(env);
  runApp(_build(isDev));
}

Future init(env) async {
  setupLocator();
  Logger.level = Level.info;
  AppConfig config = locator<AppConfig>();
  await Hive.initFlutter();
  await locator<Preferences>().openBox();
  await config.forEnvironment(env);
  final DynamicLinkService _dynamicLinkService = locator<DynamicLinkService>();
  await _dynamicLinkService.handleDynamicLinks();
  await locator<Api>().startSocket();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  ConnectionStatusSingleton connectionStatus =
      ConnectionStatusSingleton.getInstance();
  connectionStatus.initialize();
  Firebase.initializeApp();
}

Widget _build(isDev) {
  if (isDev) {
    return preview.DevicePreview(
      builder: (BuildContext context) {
        return _providers();
      },
    );
  } else {
    return _providers();
  }
}

Widget _providers() {
  return MultiProvider(
    providers: [
      StreamProvider<User>(
        create: (context) =>
            locator<AuthenticationService>().userController.stream,
      ),
      ChangeNotifierProvider<BookingCalendarViewModel>(
        create: (context) => BookingCalendarViewModel(api: locator<Api>()),
      ),
      ChangeNotifierProvider<SearchViewModel>(
        create: (context) => SearchViewModel(api: locator<Api>()),
      ),
      ChangeNotifierProvider<CategoriesViewModel>(
        create: (context) => CategoriesViewModel(api: locator<Api>()),
      ),
      ChangeNotifierProvider<BusinessViewModel>(
        create: (context) => BusinessViewModel(api: locator<Api>()),
      ),
      ChangeNotifierProvider<ProfileViewModel>(
        create: (context) => ProfileViewModel(),
      ),
      ChangeNotifierProvider<HomeViewModel>(
        create: (context) => HomeViewModel(),
      ),
      ChangeNotifierProvider<ThemeProvider>(
        create: (context) => ThemeProvider(),
      ),
      ChangeNotifierProvider<LanguageProvider>(
        create: (context) => LanguageProvider(),
      ),
    ],
    child: App(),
  );
}
