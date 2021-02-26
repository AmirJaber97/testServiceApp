import 'action.dart';
import 'state.dart';

Effect<StartState> buildEffect() {
  return combineEffects(<Object, Effect<StartState>>{
    StartAction.action: _onAction,
    StartAction.onStart: _onStart,
    Lifecycle.initState: _onInit,
    Lifecycle.dispose: _onDispose,
    Lifecycle.build: _onBuild,
  });
}


void _onAction(Action action, Context<StartState> ctx) {}

/// Set [Locale] to the last choosen language before rendering the view.
/// if token is good, go to home, but if token is bad, or if there is
/// no token around, go to login
void _onInit(Action action, Context<StartState> ctx) async {
  _setLocale();
  ctx.state.pageController = PageController();
  ctx.state.sloganOpacity  = 0.0;
}

void _onBuild(Action action, Context<StartState> ctx) async {
  ctx.dispatch(StartActionCreator.setSloganOpacity());
}

/// Route the user to login or to main screen.
/// after 1 second, the splash screen will dispatch the [_onStart] effect.
void _onStart(Action action, Context<StartState> ctx) async {
  String jwtToken;
  /// sometimes we want to see how login works, so we clean the jwt token
  if (Environment.forceLogin()) await Persistor.write('jwt_token', '');
  /// retrieve and setup the token from secure storage
  await Persistor.read('jwt_token').then((t) => jwtToken = t);
  bool isValid = JWTUtils?.validate(jwtToken) ?? false;
  if (isValid) {
    Client.token = jwtToken;
    await _pushToMainPage(ctx.context);
  }
    else Navigator.of(ctx.context).pushNamed('login_page');
}

void _onDispose(Action action, Context<StartState> ctx) {
  ctx.state.pageController.dispose();
}

Future _pushToMainPage(BuildContext context) async {
  await Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            return Routes.routes.buildPage('main_page', {
              'pages': List<Widget>.unmodifiable([
                Routes.routes.buildPage('visit_page', null),
                Routes.routes.buildPage('report_page', null),
                Routes.routes.buildPage('conversation_page', null),
                Routes.routes.buildPage('profile_page', null)
              ])
            });
          },
          settings: RouteSettings(name: 'main_page')
  ));
}

/// Set locale from Persistance, and if not found, load 'english'
void _setLocale() async {
  String loc;
  await Persistor.read('locale').then((r) => loc = r);
  Locale locale = Locale(loc ?? 'de');
  GlobalStore.store.dispatch(GlobalActionCreator.changeLocale(locale));
}
