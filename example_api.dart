typedef Future<T> FutureGenerator<T>();

class Api {
  static final logger = getLogger('ApiProvider');
  static const String viberDeepLink =
      "viber://pa?chatURI=orange_testbot&context=/login-";
  static const String telegramDeepLink =
      "https://telegram.me/DevOrangeBot?start=OTP-";
  static BaseOptions options = BaseOptions(
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
  );

  final dio = Dio(options);
  final cookieJar = CookieJar();
  Preferences _preferences;

  PersistCookieJar persistentCookies;
  bool messengerLoggedIn = false;
  bool isTelegram;
  String endpoint;
  AppConfig config;
  StompClient client;

  Api() {
    config = locator<AppConfig>();
    endpoint = config.apiUrl;
    _preferences = locator<Preferences>();
  }

  Future startSocket() async {
    logger.i("Starting socket listener");

    client = StompClient(
      config: StompConfig.SockJS(
        url: 'https://backend-dev.skedq.com/socket',
        onConnect: onConnect,
      ),
    );

    client.activate();

    return Future.delayed(Duration(seconds: 2));
  }

  dynamic onConnect(StompClient client, StompFrame frame) {
    logger.i("Connected!");
    client.subscribe(
        destination: '/ws/login',
        callback: (StompFrame frame) {
          logger.i('socket connection result ${frame.body}');
          logger.i('telegram otp: ${_preferences.getTelegramOtp()}');
          logger.i('viber otp: ${_preferences.getViberOtp()}');
          logger.i(
              'my login?: ${(frame.body == _preferences.getTelegramOtp().toString() || frame.body == _preferences.getViberOtp().toString())}');
          if (frame.body == _preferences.getTelegramOtp().toString() ||
              frame.body == _preferences.getViberOtp().toString()) {
            messengerLoggedIn = true;
          }
        });
  }

  Future<ResponseModel> getSchedule(int fromDay, int toDay, int serviceId,
      {int customDuration, int workerId, int timestamp}) async {
    logger.i("Getting schedule");
    ResponseModel responseModel;
    CalendarDto calendarDto = CalendarDto();
    calendarDto.dateFromMillis = fromDay;
    calendarDto.dateToMillis = toDay;
    calendarDto.serviceId = serviceId;
    if (timestamp != null) {
      calendarDto.selectedDateTimeMillis = timestamp;
    }
    if (workerId != null) {
      calendarDto.serviceProviderId = workerId;
    }

    log("here's what im passing ${jsonEncode(calendarDto)}");

    try {
      var response = await dio.post('$endpoint/booking/calendar/build',
          data: jsonEncode(calendarDto));
      responseModel = ResponseModel.fromJson(response.data);
      BookingCalendarResponse.fromJson(responseModel.data);
    } on DioError catch (e) {
      logger.e("This error is $e");
      throw Failure(e.message, code: e.response.statusCode);
    } catch (e) {
      logger.e('unknown error: $e');
      throw Failure("Something happened.. try again later");
    }
    return responseModel;
  }

  Future<ResponseModel> confirmBooking(ConfirmBooking confirmBooking) async {
    ResponseModel responseModel;
    try {
      var response = await dio.post('$endpoint/booking/book',
          data: jsonEncode(confirmBooking.toJson()));
      logger.i("Booking response: ${response.data}");
      ConfirmBookingResponse.fromJson(responseModel.data);
    } on DioError catch (e) {
      logger.e(responseModel.error.description);
      throw Failure(e.message, code: e.response.statusCode);
    } catch (e) {
      logger.e('unknown error here?: $e');
      throw Failure("Something happened.. try again later");
    }
    return responseModel;
  }

  Future logout() async {
    logger.i("logging out...");
    try {
      await dio.post('$endpoint/logout');
      persistentCookies = await cookie;
      dio.interceptors.add(CookieManager(persistentCookies));
      persistentCookies.deleteAll();
      dio.interceptors.clear();
      dio.clear();
    } on DioError catch (e) {
      throw Failure(e.message, code: e.response.statusCode);
    } catch (e) {
      logger.e('unknown error: $e');
      throw Failure("Something happened.. try again later");
    }
  }

  Future<User> loginUser(String method, String json) async {
    logger.i("logging in to $endpoint/login/$method");
    persistentCookies = await cookie;
    dio.interceptors.add(CookieManager(persistentCookies));
    try {
      await dio.post(
        '$endpoint/login/$method',
        data: json,
      );
    } on DioError catch (e) {
      throw Failure(e.message, code: e.response.statusCode);
    } catch (e) {
      logger.e('unknown error: $e');
      throw Failure("Something happened.. try again later");
    }
    return await getUser();
  }

  Future<User> linkUser(String method, String json) async {
    logger.i("logging in to $endpoint/login/$method");
    persistentCookies = await cookie;
    dio.interceptors.add(CookieManager(persistentCookies));
    try {
      await dio.post(
        '$endpoint/link/$method',
        data: json,
      );
    } on DioError catch (e) {
      throw Failure(e.message, code: e.response.statusCode);
    } catch (e) {
      logger.e('unknown error: $e');
      throw Failure("Something happened.. try again later");
    }
    return await getUser();
  }

  Future<User> unlink(String method) async {
    logger.i('Unlinking.....');
    try {
      await dio.post('$endpoint/unlink?loginSource=${method}');
    } on DioError catch (e) {
      throw Failure(e.message, code: e.response.statusCode);
    } catch (e) {
      logger.e('unknown error: $e');
      throw Failure("Something happened.. try again later");
    }
    return await getUser();
  }

  Future<User> authenticateViberLogin(int otp) async {
    logger.i("Authenticating viber login with backend...");
    MessengerDto messengerDto = MessengerDto();
    setupMessengerDto(messengerDto, Messenger.VIBER.toShortString(),
        ActionType.LOGIN.toShortString(), otp);
    try {
      persistentCookies = await cookie;
      dio.interceptors.add(CookieManager(persistentCookies));
      await dio.post("$endpoint/login/viber", data: jsonEncode(messengerDto));
    } on DioError catch (e) {
      throw Failure(e.message, code: e.response.statusCode);
    } catch (e) {
      logger.e('unknown error: $e');
      throw Failure("Something happened.. try again later");
    }
    return await getUser();
  }

  Future<User> linkViberLogin(int otp) async {
    logger.i("Linking viber  with backend...");
    MessengerDto messengerDto = MessengerDto();
    setupMessengerDto(messengerDto, Messenger.VIBER.toShortString(),
        ActionType.ACCOUNT_LINKING.toShortString(), otp);
    try {
      persistentCookies = await cookie;
      dio.interceptors.add(CookieManager(persistentCookies));
      await dio.post("$endpoint/link/viber", data: jsonEncode(messengerDto));
    } on DioError catch (e) {
      throw Failure(e.message, code: e.response.statusCode);
    } catch (e) {
      logger.e('unknown error: $e');
      throw Failure("Something happened.. try again later");
    }
    return await getUser();
  }

  Future<User> authenticateTelegramLogin(int otp) async {
    logger.i("Authenticating telegram login with backend...");
    MessengerDto messengerDto = MessengerDto();
    setupMessengerDto(messengerDto, Messenger.TELEGRAM.toShortString(),
        ActionType.LOGIN.toShortString(), otp);
    try {
      persistentCookies = await cookie;
      dio.interceptors.add(CookieManager(persistentCookies));
      await dio.post("$endpoint/login/telegram/otp",
          data: jsonEncode(messengerDto));
    } on DioError catch (e) {
      throw Failure(e.message, code: e.response.statusCode);
    } catch (e) {
      logger.e('unknown error: $e');
      throw Failure("Something happened.. try again later");
    }
    return await getUser();
  }

  Future<User> linkingTelegramLogin(int otp) async {
    logger.i("Authenticating telegram login with backend...");
    MessengerDto messengerDto = MessengerDto();
    setupMessengerDto(messengerDto, Messenger.TELEGRAM.toShortString(),
        ActionType.LOGIN.toShortString(), otp);
    try {
      persistentCookies = await cookie;
      dio.interceptors.add(CookieManager(persistentCookies));
      await dio.post("$endpoint/link/telegram/otp",
          data: jsonEncode(messengerDto));
    } on DioError catch (e) {
      throw Failure(e.message, code: e.response.statusCode);
    } catch (e) {
      logger.e('unknown error: $e');
      throw Failure("Something happened.. try again later");
    }
    return await getUser();
  }

  Future<User> getUser() async {
    logger.i("Getting user profile..");
    if (persistentCookies == null) {
      persistentCookies = await cookie;
    }
    dio.interceptors.add(CookieManager(persistentCookies));
    ResponseModel responseModel;
    User user;
    try {
      var response = await dio.get('$endpoint/users/profile');
      responseModel = ResponseModel.fromJson(response.data);
      user = User.fromJson(responseModel.data);
    } on DioError catch (e) {
      throw Failure(e.message, code: e.response.statusCode);
    } catch (e) {
      logger.e('unknown error: $e');
      throw Failure("Something happened.. try again later");
    }
//   await getEventsUser();
//   await getFavoritesUser();
    return user;
  }

  void setupMessengerDto(
      MessengerDto messengerDto, String messenger, String actionType, otp) {
    messengerDto.messenger = messenger;
    messengerDto.otpActionType = actionType;
    messengerDto.password = otp.toString();
  }

  Future<User> changeUserInfo(String fullName, String phoneNumber) async {
    logger.i("Changes profile info......");
    try {
      await dio.post('$endpoint/users/info', data: {
        "fullName": fullName,
        "phoneNumber": phoneNumber,
        "description": ""
      });
    } on DioError catch (e) {
      throw Failure(e.message, code: e.response.statusCode);
    } catch (e) {
      print('unknown error: $e');
      throw Failure("Something happened.. try again later");
    }
    return await getUser();
  }

  Future<User> deleteContactInfo(String messenger) async {
    logger.i("Deleted contact info......");
    try {
      await dio.delete('$endpoint/contact-info', data: {
        "messenger": messenger,
      });
    } on DioError catch (e) {
      throw Failure(e.message, code: e.response.statusCode);
    } catch (e) {
      print('unknown error: $e');
      throw Failure("Something happened.. try again later");
    }
    return await getUser();
  }

  Future<SearchResultDto> searching(String query, int offset) async {
    logger.i("Searching ......");
    SearchResultDto searchResult;
    ResponseModel responseModel;
    SearchRequestDto searchRequestDto = SearchRequestDto();
    searchRequestDto.searchRequest = query;
    searchRequestDto.city = _preferences.getCity();
    searchRequestDto.offset = offset;
    searchRequestDto.authType = "MOBILE";
    searchRequestDto.size = 5;
    try {
      var response = await dio.post('$endpoint/search',
          data: jsonEncode(searchRequestDto));
      responseModel = ResponseModel.fromJson(response.data);
      searchResult = SearchResultDto.fromJson(responseModel.data);
    } on DioError catch (e) {
      throw Failure(e.message, code: e.response.statusCode);
    } catch (e) {
      print('unknown error: $e');
      throw Failure("Something happened.. try again later");
    }
    return searchResult;
  }

  Future<User> contactInfo(String link, String messenger) async {
    log('Contact Info link ......');
    try {
      await dio.post('$endpoint/contact-info/add',
          data: {"link": link, "messenger": messenger});
    } on DioError catch (e) {
      throw Failure(e.message, code: e.response.statusCode);
    } catch (e) {
      print('unknown error: $e');
      throw Failure("Something happened.. try again later");
    }
    return await getUser();
  }

  Future<User> uploadImage(File file) async {
    log('Contact Info link ......');
    String fileName = file.path.split('/').last;
    logger.i('file name $fileName');
    FormData data = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });
    try {
      var response =
          await dio.post('$endpoint/users/avatar/upload', data: data);
      logger.i("status code is ${response.statusCode}");
    } on DioError catch (e) {
      logger.e("wtf ${e.response.statusCode}");
      throw Failure(e.message, code: e.response.statusCode);
    } catch (e) {
      print('unknown error: $e');
      throw Failure("Something happened.. try again later");
    }
    return await getUser();
  }

  Future<List<City>> getActiveCities() async {
    logger.i("Getting active cities...");
    ResponseModel responseModel;
    List<City> activeCities;
    try {
      var response = await dio.get('$endpoint/category/active-cities');
      responseModel = ResponseModel.fromJson(response.data);
      activeCities = List<City>();
      responseModel.data.forEach((v) {
        activeCities.add(City.fromJson(v));
      });
    } on DioError catch (e) {
      throw Failure(e.message, code: e.response.statusCode);
    } catch (e) {
      logger.e('Unknown error: $e');
      throw Failure("Something happened.. try again later");
    }
    return activeCities;
  }

  Future<Categories> getCategoriesByCityName({String city}) async {
    logger.i("Getting categories...");
    ResponseModel responseModel;
    Categories categories;
    try {
      var response = await dio.get(
        '$endpoint/category/${city != null ? 'active-categories/$city' : 'all'}',
      );
      responseModel = ResponseModel.fromJson(response.data);
      categories = Categories.fromJson(responseModel.data);
    } on DioError catch (e) {
      throw Failure(e.message, code: e.response.statusCode);
    } catch (e) {
      logger.e('unknown error: $e');
      throw Failure("Something happened.. try again later");
    }
    return categories;
  }

  Future<Categories> getCategoriesByCoordinates(double lat, double lon) async {
    logger.i("Getting categories by coordinate...");
    ResponseModel responseModel;
    Categories categories;
    try {
      var response = await dio.post(
          '$endpoint/category/active-categories/coordinate',
          data: {"lat": lat, "lon": lon});
      responseModel = ResponseModel.fromJson(response.data);
      categories = Categories.fromJson(responseModel.data);
      logger.i('${categories.mainCategories}');
    } on DioError catch (e) {
      throw Failure(e.message, code: e.response.statusCode);
    } catch (e) {
      logger.e('unknown error: $e');
      throw Failure("Something happened.. try again later");
    }
    return categories;
  }

  Future<City> getCityByCoordinates(double lat, double lon) async {
    logger.i("Getting city by coordinate...");
    ResponseModel responseModel;
    City city;
    try {
      var response = await dio.post('$endpoint/category/city/coordinate',
          data: {"lat": lat, "lon": lon});
      responseModel = ResponseModel.fromJson(response.data);
      city = City.fromJson(responseModel.data);
      logger.i('City by coordinates ${city.cityEn}');
    } on DioError catch (e) {
      throw Failure(e.message, code: e.response.statusCode);
    } catch (e) {
      logger.e('unknown error: $e');
      throw Failure("Something happened.. try again later");
    }
    return city;
  }

  Future<AllUserEvents> getUserEvents() async {
    logger.i("Getting user events...");
    AllUserEvents userEvents;
    ResponseModel responseModel;
    try {
      var response = await dio.get(
        '$endpoint/events/user/all',
      );
      responseModel = ResponseModel.fromJson(response.data);
      userEvents = AllUserEvents.fromJson(responseModel.data);
    } on DioError catch (e) {
      throw Failure(e.message, code: e.response.statusCode);
    } catch (e) {
      logger.e('unknown error: $e');
      throw Failure("Something happened.. try again later");
    }
    return userEvents;
  }

  Future<AllUserFavorites> getUserFavorites() async {
    AllUserFavorites favoriteUser;
    ResponseModel responseModel;
    try {
      var response = await dio.get(
        '$endpoint/favorite/user',
      );
      responseModel = ResponseModel.fromJson(response.data);
      favoriteUser = AllUserFavorites.fromJson(responseModel.data);
      return favoriteUser;
    } on DioError catch (e) {
      throw Failure(e.message, code: e.response.statusCode);
    } catch (e) {
      logger.e('unknown error: $e');
      throw Failure("Something happened.. try again later");
    }
    return favoriteUser;
  }

  Future<Business> getBusiness(String id) async {
    Business business;
    ResponseModel responseModel;
    try {
      print('$endpoint/business/tid/$id');
      var response = await dio.get(
        '$endpoint/business/tid/$id',
      );

      responseModel = ResponseModel.fromJson(response.data);
      business = Business.fromJson(responseModel.data);
      // return business;
    } on DioError catch (e) {
      logger.e("business api $e");
      throw Failure(e.message, code: e.response.statusCode);
    } catch (e) {
      logger.e('unknown error: $e');
      throw Failure("Something happened.. try again later");
    }
    return business;
  }

  Future<List<Ratings>> getBusinessRatings(int id) async {
    logger.i("Getting business ratings");
    List<Ratings> ratings;
    ResponseModel responseModel;
    try {
      var response = await dio.get(
        '$endpoint/rating/business/id/$id',
      );
      responseModel = ResponseModel.fromJson(response.data);
      ratings = List<Ratings>();
      responseModel.data.forEach((v) {
        ratings.add(Ratings.fromJson(v));
      });
    } on DioError catch (e) {
      throw Failure(e.message, code: e.response.statusCode);
    } catch (e) {
      logger.e('unknown error: $e');
      throw Failure("Something happened.. try again later");
    }
    return ratings;
  }

  Future saveOtp(int otp, Messenger messenger) async {
    logger.i('Saving OTP $otp');
    messengerLoggedIn = false;
    isTelegram = messenger == Messenger.TELEGRAM;
    ResponseModel responseModel;
    try {
      MessengerDto messengerDto = MessengerDto();
      setupMessengerDto(messengerDto, messenger.toShortString(),
          ActionType.LOGIN.toShortString(), otp);

      var response = await dio.post(
        '$endpoint/login/save-otp',
        data: jsonEncode(messengerDto),
      );
      responseModel = ResponseModel.fromJson(response.data);
      _launchURL(otp, messenger == Messenger.TELEGRAM);
    } on DioError catch (e) {
      throw Failure(e.message, code: e.response.statusCode);
    } catch (e) {
      logger.e('unknown error: $e');
      throw Failure('Something happened.. try again later');
    }
    return responseModel;
  }

  Future _launchURL(int otp, bool isTelegram) async {
    final url =
        '${isTelegram ? '$telegramDeepLink$otp' : '$viberDeepLink$otp'}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
