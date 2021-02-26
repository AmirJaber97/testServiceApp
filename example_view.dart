class LoginView extends StatefulWidget {
  final LoginMethod lastLoginMethod;

  const LoginView({Key key, this.lastLoginMethod}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with WidgetsBindingObserver {
  Logger logger = getLogger('LoginView');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        logger.i(
            'Resuming app, logged in using messenger? ${locator<Api>().messengerLoggedIn}');
        if (locator<Api>().messengerLoggedIn) {
          locator<LoginViewModel>().login(
              locator<Api>().isTelegram
                  ? LoginMethod.Telegram
                  : LoginMethod.Viber,
              context);
        }
        break;
      case AppLifecycleState.inactive:
        logger.i('App inactive');
        break;
      case AppLifecycleState.paused:
        logger.i('App paused');
        break;
      case AppLifecycleState.detached:
        logger.i('App detached');
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 360, height: 640);
    var l = AppLocalizations.of(context);

    return BaseWidget<LoginViewModel>(
        viewModel: LoginViewModel(),
        onViewModelReady: (viewModel) {
          viewModel.init(widget.lastLoginMethod, context);
        },
        builder: (_, model, __) {
          if (model.state == NotifierState.Loading ||
              locator<LoginViewModel>().state == NotifierState.Loading) {
            return Center(
              child: SpinKitRotatingCircle(
                color: kSecondaryColor,
                size: 50.h,
              ),
            );
          } else {
            return Stack(
              children: <Widget>[
                Container(
                  color: kBlackColor,
                  height: double.infinity,
                  width: double.infinity,
                  child: Opacity(
                    opacity: 0.5,
                    child: CachedNetworkImage(
                      imageUrl: icMainFullBg,
                      placeholder: (context, url) => Image.asset(
                        icMainBg,
                        fit: BoxFit.cover,
                        height: double.infinity,
                      ),
                      fit: BoxFit.cover,
                      height: double.infinity,
                    ),
                  ),
                ),
                Scaffold(
                  backgroundColor: Colors.transparent,
                  body: NetworkStatusBasedWidget(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(25.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    SvgPicture.asset(
                                      icMainLogo,
                                      height: 70.h,
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    buildSubHeader(l),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  FadeIn(
                                      0.5,
                                      buildButton(
                                          icLoginGoogle,
                                          l.translate(
                                              AppStrings.loginGoogleBtn),
                                          kGoogleBtnColor,
                                          () async => model.login(
                                              LoginMethod.Google, context))),
                                  FadeIn(
                                      1,
                                      buildButton(
                                          icLoginFacebook,
                                          l.translate(
                                              AppStrings.loginFacebookBtn),
                                          kFacebookBtnColor,
                                          () async => model.login(
                                              LoginMethod.Facebook, context))),
                                  FadeIn(
                                      1.5,
                                      buildButton(
                                          icLoginTelegram,
                                          l.translate(
                                              AppStrings.loginTelegramBtn),
                                          kTelegramBtnColor,
                                          () => showLoginPopup(
                                              Messenger.TELEGRAM, model, l))),
                                  FadeIn(
                                      2,
                                      buildButton(
                                          icLoginViber,
                                          l.translate(AppStrings.loginViberBtn),
                                          kViberBtnColor,
                                          () => showLoginPopup(
                                              Messenger.VIBER, model, l))),
                                  FadeIn(
                                      2.5,
                                      buildButton(
                                          icLoginApple,
                                          l.translate(AppStrings.loginAppleBtn),
                                          kBlackColor,
                                          () async => model.login(
                                              LoginMethod.Apple, context))),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        });
  }

  Widget buildSubHeader(l) {
    return Center(
        child: Text(
      l.translate(AppStrings.subTitle),
      style: text(13.sp, fw: semiBold, color: kWhiteColor),
      softWrap: true,
      textAlign: TextAlign.center,
    ));
  }

  Future showLoginPopup(Messenger messenger, LoginViewModel model, l) {
    bool isTelegram = messenger == Messenger.TELEGRAM;
    return Get.dialog(CustomDialog(
        title: 'Приєднатись через \n${isTelegram ? 'Telegram' : 'Viber'}',
        description:
            'Для входу через ${isTelegram ? 'Telegram' : 'Viber'} перейдіть в месенджер та натисніть ${isTelegram ? '"Start"' : '"Start"'}',
        images: icPopUpImagePhoneLogin,
        loginWindow: true,
        messenger: messenger,
        loginAction: () => model.saveOtp(messenger),
        l: l));
  }
}
