class LoginViewModel extends BaseModel {
  final logger = getLogger('LoginViewModel');
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  final Api _api = locator<Api>();
  final Preferences _preferences = locator<Preferences>();
  PermissionHandler permissionHandler = locator<PermissionHandler>();
  LocationUtils locationUtils = LocationUtils();
  bool isAndroid = Platform.isAndroid;

  var persistentCookies;

  int otp;
  int saveOtpRetry = 0;

  void init(LoginMethod method, context) async {
    setNotifier(NotifierState.Loading);
    logger.i(
        'Initializing Login.. Checking for cookie.. user last logged in with $method');
    var catModel = Provider.of<CategoriesViewModel>(context, listen: false);
    if (await Permission.locationWhenInUse.serviceStatus.isEnabled ||
        await Permission.location.serviceStatus.isEnabled ||
        await Permission.locationAlways.serviceStatus.isEnabled) {
      /// TODO: make asynchronous
      await permissionHandler.requestLocation();
      var locationStatus = await Permission.location.status;
      var locationWhenInUseStatus = await Permission.locationWhenInUse.status;
      var locationAlwaysStatus = await Permission.locationAlways.status;
      if (locationStatus == PermissionStatus.granted ||
          locationWhenInUseStatus == PermissionStatus.granted ||
          locationAlwaysStatus == PermissionStatus.granted) {
        catModel.locationPermitted = true;
        await locationUtils.getLocation();
        await catModel.getCity();
      } else {
        catModel.locationPermitted = false;
      }
    } else {
      logger.i("Location is fucked up");
      catModel.locationPermitted = false;
    }

    checkCookie(method, context);

    if (Platform.isIOS) {
      AppleSignIn.onCredentialRevoked.listen((_) {
        print('Credentials revoked');
      });
    }
    setNotifier(NotifierState.Loaded);
  }

  Future checkCookie(LoginMethod method, context) async {
    persistentCookies = await cookie;
    List<Cookie> cookies = persistentCookies.loadForRequest(
        Uri.parse('https://backend-dev.skedq.com/api/skedq/login/$method'));
    logger.i('Cookies available ${cookies.length}');
    cookies.forEach((element) {
      logger.i('Cookie: ${element.name}');
    });
    if (cookies.length > 1) {
      await silentLogin(method, context);
    }
  }

  Future silentLogin(LoginMethod method, context) async {
    logger.i('User already logged in using $method, getting user data...');
    var catModel = Provider.of<CategoriesViewModel>(context, listen: false);
    setNotifier(NotifierState.Loading);
    try {
      await cityOps(catModel, context);

      await _authenticationService.updateUser();
      setNotifier(NotifierState.Loaded);
      _setValuesAndNavigate(
          method: method, didLogout: false, route: RoutePaths.Home);
    } catch (error) {
      _handleFailure(error, "silentLogin ${method}");
      setNotifier(NotifierState.Loaded);
      print(error);
    }
  }

  Future login(LoginMethod method, context) async {
    logger.i('Logging in using $method');
    var catModel = Provider.of<CategoriesViewModel>(context, listen: false);

    setNotifier(NotifierState.Loading);

    await cityOps(catModel, context);

    try {
      _authenticationService.generalLogout();
    } catch (e) {
      _handleFailure(e, "login ${method}");
      logger.i("okay error");
    }

    switch (method) {
      case LoginMethod.Google:
        try {
          await _authenticationService.signInWithGoogle(isAndroid, true);
          setNotifier(NotifierState.Loaded);
          _setValuesAndNavigate(
              method: method, didLogout: false, route: RoutePaths.Home);
        } catch (error) {
          _handleFailure(error, "login  LoginMethod.Google");
          setNotifier(NotifierState.Loaded);
          Get.snackbar('Failed to login', "Try again later",
              colorText: kDarkerWhiteColor);
          logger.e('Failed to login, $error');
        }
        break;
      case LoginMethod.Facebook:
        try {
          await _authenticationService.signInWithFacebook(true);
          setNotifier(NotifierState.Loaded);
          _setValuesAndNavigate(
              method: method, didLogout: false, route: RoutePaths.Home);
        } catch (error) {
          _handleFailure(error, "login  LoginMethod.Facebook");
          setNotifier(NotifierState.Loaded);
          Get.snackbar('Failed to login', "Try again later",
              colorText: kDarkerWhiteColor);
          logger.e('Failed to login, $error');
        }
        break;
      case LoginMethod.Viber:
        try {
          setNotifier(NotifierState.Loading);
          await _authenticationService
              .signInWithViber(_preferences.getViberOtp(), true);
          _setValuesAndNavigate(
              method: LoginMethod.Viber,
              didLogout: false,
              route: RoutePaths.Home);
          setNotifier(NotifierState.Loaded);
        } catch (e) {
          _handleFailure(e, "login  LoginMethod.Viber");
          Get.snackbar('Failed to login', "Try again later",
              colorText: kDarkerWhiteColor);
          logger.e('Failed to login, $e');
          setNotifier(NotifierState.Loaded);
        }
        break;
      case LoginMethod.Telegram:
        try {
          setNotifier(NotifierState.Loading);
          await _authenticationService
              .signInWithTelegram(_preferences.getTelegramOtp(), true);
          _setValuesAndNavigate(
              method: LoginMethod.Telegram,
              didLogout: false,
              route: RoutePaths.Home);
          setNotifier(NotifierState.Loaded);
        } catch (e) {
          _handleFailure(e, "login  LoginMethod.Telegram");
          Get.snackbar('Failed to login', "Try again later",
              colorText: kDarkerWhiteColor);
          logger.e('Failed to login, $e');
          setNotifier(NotifierState.Loaded);
        }
        break;
      case LoginMethod.Apple:
        try {
          await _authenticationService.signInWithApple(true);
          setNotifier(NotifierState.Loaded);
          _setValuesAndNavigate(
              method: method, didLogout: false, route: RoutePaths.Home);
        } catch (error) {
          _handleFailure(error, "login  LoginMethod.Apple");
          setNotifier(NotifierState.Loaded);
          Get.snackbar('Failed to login', "Try again later",
              colorText: kDarkerWhiteColor);
          logger.e('Failed to login, $error');
        }
        break;
    }
    logger.i('Logged in using $method successfully');
  }

  Future cityOps(catModel, context) async {
    if (catModel.city == null) {
      await catModel.getCity();
    }
    await catModel.getCities();
    var cities = catModel.activeCities;

    if (catModel.city == null) {
      catModel.city = City.fromJson(cities[0].toJson());
    }
    await catModel.getCategories(
        city: _preferences.getCity() != null
            ? _preferences.getCity()
            : catModel.locationPermitted
                ? catModel.city.cityEn
                : catModel.activeCities[0].cityEn);
    var _appLanguage = Provider.of<LanguageProvider>(context, listen: false);
    String currentLanguage;

    switch (_appLanguage.appLocale.languageCode) {
      case 'uk':
        {
          currentLanguage = 'Ua';
          break;
        }
      case 'ru':
        {
          currentLanguage = 'Ru';
          break;
        }
      case 'en':
        {
          currentLanguage = 'En';
          break;
        }
      default:
        {
          currentLanguage = 'En';
        }
    }
    // catModel.checkSelectedCityStatus(currentLanguage, l);
  }

  Future saveOtp(Messenger messenger) async {
    Get.back();
    setNotifier(NotifierState.Loading);
    await _api.saveOtp(_generateOTP(messenger), messenger).then((value) {
      if (value != null) {
        setNotifier(NotifierState.Loaded);
      }
    }).catchError((onError) {
      _handleFailure(onError, "saveOtp");
      if (onError.code == null) {
        setNotifier(NotifierState.Loaded);
        throw Failure('Something wrong happened.');
      }
      logger.i('Error is ${onError.code}');
      if (onError.code == 409) {
        keepTryingOtp(messenger);
      } else {
        setNotifier(NotifierState.Loaded);
        throw Failure('Something wrong happened.');
      }
    });
  }

  Future keepTryingOtp(Messenger messenger) async {
    Timer.periodic(Duration(seconds: 3), (timer) async {
      await _api.saveOtp(_generateOTP(messenger), messenger).then((value) {
        logger.i('Value is $value');
        if (value != null) {
          timer.cancel();
          setNotifier(NotifierState.Loaded);
        }
      }).catchError((onError) {
        _handleFailure(onError, "keepTryingOtp");
        logger.i('Error is $onError');
        if (onError.code == 409 && saveOtpRetry < 5) {
          saveOtpRetry++;
        } else {
          timer.cancel();
          setNotifier(NotifierState.Loaded);
          throw Failure('RIP');
        }
      });
    });
  }

  int _generateOTP(Messenger messenger) {
    bool isTelegram = messenger == Messenger.TELEGRAM;
    var rng = Random();
    otp = rng.nextInt(900000) + 100000;
    if (isTelegram) {
      _preferences.setTelegramOtp(otp);
    } else {
      _preferences.setViberOtp(otp);
    }
    logger.i('OTP is $otp');
    return otp;
  }

  void logout(LoginMethod method) async {
    logger.i('Logging out using $method');
    setNotifier(NotifierState.Loading);

    switch (method) {
      case LoginMethod.Google:
        try {
          Either<Failure, bool> loggedOut;
          bool _loggedOut;
          Failure fail;
          await Task(() => _authenticationService.googleLogout())
              .attempt()
              .mapLeftToFailure()
              .run()
              .then((value) {
            loggedOut = value;
          });
          loggedOut.fold((l) => fail = l, (r) => _loggedOut = r);
          _handleFailure(fail, "logout LoginMethod.Facebook");
          if (fail == null && _loggedOut) {
            _setValuesAndNavigate(didLogout: true, route: RoutePaths.Login);
          } else {
            Get.defaultDialog(
                title: "Error",
                middleText:
                    "Please check your internet connection and try again");
          }
          setNotifier(NotifierState.Loaded);
        } catch (error) {
          print(error);
        }
        // setNotifier(NotifierState.Loaded);
        break;
      case LoginMethod.Facebook:
        try {
          Either<Failure, bool> loggedOut;
          bool _loggedOut;
          Failure fail;
          await Task(() => _authenticationService.facebookLogout())
              .attempt()
              .mapLeftToFailure()
              .run()
              .then((value) {
            loggedOut = value;
          });
          loggedOut.fold((l) => fail = l, (r) => _loggedOut = r);
          _handleFailure(fail, "logout LoginMethod.Facebook");
          if (fail == null && _loggedOut) {
            _setValuesAndNavigate(didLogout: true, route: RoutePaths.Login);
          } else {
            Get.defaultDialog(
                title: "Error",
                middleText:
                    "Please check your internet connection and try again");
          }
          setNotifier(NotifierState.Loaded);
        } catch (error) {
          print(error);
        }
        break;
      case LoginMethod.Viber:
        _api.messengerLoggedIn = false;
        try {
          Either<Failure, bool> loggedOut;
          bool _loggedOut;
          Failure fail;
          await Task(() => _authenticationService.viberLogout())
              .attempt()
              .mapLeftToFailure()
              .run()
              .then((value) {
            loggedOut = value;
          });
          loggedOut.fold((l) => fail = l, (r) => _loggedOut = r);
          _handleFailure(fail, "logout LoginMethod.Viber");
          if (fail == null && _loggedOut) {
            _setValuesAndNavigate(didLogout: true, route: RoutePaths.Login);
          } else {
            Get.defaultDialog(
                title: "Error",
                middleText:
                    "Please check your internet connection and try again");
          }
          setNotifier(NotifierState.Loaded);
        } catch (error) {
          print(error);
        }
        break;
      case LoginMethod.Telegram:
        _api.messengerLoggedIn = false;
        try {
          Either<Failure, bool> loggedOut;
          bool _loggedOut;
          Failure fail;
          await Task(() => _authenticationService.telegramLogout())
              .attempt()
              .mapLeftToFailure()
              .run()
              .then((value) {
            loggedOut = value;
          });
          loggedOut.fold((l) => fail = l, (r) => _loggedOut = r);
          _handleFailure(fail, "logout LoginMethod.Telegram");
          if (fail == null && _loggedOut) {
            _setValuesAndNavigate(didLogout: true, route: RoutePaths.Login);
          } else {
            Get.defaultDialog(
                title: "Error",
                middleText:
                    "Please check your internet connection and try again");
          }
          setNotifier(NotifierState.Loaded);
        } catch (error) {
          print(error);
        }
        break;
      case LoginMethod.Apple:
        try {
          Either<Failure, bool> loggedOut;
          bool _loggedOut;
          Failure fail;
          await Task(() => _authenticationService.appleLogout())
              .attempt()
              .mapLeftToFailure()
              .run()
              .then((value) {
            loggedOut = value;
          });
          loggedOut.fold((l) => fail = l, (r) => _loggedOut = r);
          _handleFailure(fail, "logout LoginMethod.Apple");
          if (fail == null && _loggedOut) {
            _setValuesAndNavigate(didLogout: true, route: RoutePaths.Login);
          } else {
            Get.defaultDialog(
                title: "Error",
                middleText:
                    "Please check your internet connection and try again");
          }
          setNotifier(NotifierState.Loaded);
        } catch (error) {
          print(error);
        }
        break;
    }
    logger.i('Logged out using $method');
  }

  void _setValuesAndNavigate(
      {LoginMethod method, bool didLogout, dynamic route}) {
    if (method != null) {
      _preferences.setLoginMethod(method);
    }
    _preferences.setLoggedOut(didLogout);
    Get.offNamed(route);
  }

  void _handleFailure(Failure failure, String methodName) {
    if (failure != null) {
      print('Http error: ${failure.code}, from method: $methodName');
      switch (failure.code) {
        case 400:
          break;
        case 401:
          break;
        case 403:
          break;
        case 404:
          _serverErrorPopup();
          break;
        case 409:
          break;
        case 408:
          break;
        case 500:
        case 501:
        case 502:
        case 503:
          _serverErrorPopup();
          break;
        default:
      }
    }
  }

  void _serverErrorPopup() {
    Get.dialog(
        CustomDialog(
          title: 'Sorry',
          description:
          'Something wrong happened, we\'ll fix it as soon as possible',
          images: icPopUpImageCalendar,
        ),
        barrierDismissible: false);
  }
}
