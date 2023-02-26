import 'package:bnotes/common/constants.dart';
import 'package:bnotes/common/language.dart';
import 'package:bnotes/common/theme.dart';
import 'package:bnotes/common/utility.dart';
import 'package:bnotes/desktop/desktop_app.dart';
import 'package:bnotes/desktop/pages/desktop_sign_in.dart';
import 'package:bnotes/desktop/pages/desktop_sign_up.dart';
import 'package:bnotes/mobile/pages/app.dart';
import 'package:bnotes/mobile/pages/app_lock_page.dart';
import 'package:bnotes/mobile/pages/introduction_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_platform/universal_platform.dart';

import 'helpers/globals.dart' as globals;
import 'mobile/pages/biometric_page.dart';

late SharedPreferences prefs;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (UniversalPlatform.isDesktop) {
    // doWhenWindowReady(() {
    //   final initialSize = Size(1000, 650);
    //   appWindow.minSize = initialSize;
    //   appWindow.size = initialSize;
    //   appWindow.alignment = Alignment.center;
    //   appWindow.show();
    //   appWindow.title = "scrawl";
    // });
  }
  runApp(Phoenix(
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode themeMode = ThemeMode.system;
  int themeID = 3;

  @override
  void initState() {
    getprefs();

    // Load Language Resource into Memory
    Language.readJson();

    super.initState();
  }

  getprefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.getInt('themeMode') != null) {
        switch (prefs.getInt('themeMode')) {
          case 0:
            themeMode = ThemeMode.light;
            break;
          case 1:
            themeMode = ThemeMode.dark;
            break;
          case 2:
            themeMode = ThemeMode.system;
            break;
          default:
            themeMode = ThemeMode.light;
            break;
        }
      } else {
        themeMode = ThemeMode.system;
        prefs.setInt('themeMode', 2);
      }
      globals.themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: theme(),
      darkTheme: themeDark(),
      routes: {
        '/': (context) => const DesktopApp(),
        '/dsignin': (context) => const DesktopSignIn(),
        '/dsignup': (context) => const DesktopSignUp(),
        '/mobilestart': (context) => const StartPage()
      },
      initialRoute:
          UniversalPlatform.isDesktopOrWeb || kIsWeb ? '/' : '/mobilestart',
    );
  }
}

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  bool isAppUnlocked = false;
  bool isPinRequired = false;
  bool useBiometric = false;
  bool newUser = true;

  getPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      isAppUnlocked = prefs.getBool("is_app_unlocked") ?? false;
      isPinRequired = prefs.getBool("is_pin_required") ?? false;
      useBiometric = prefs.getBool('use_biometric') ?? false;
      newUser = prefs.getBool('newUser') ?? true;

      if (isPinRequired) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  const AppLockPage(appLockState: AppLockState.confirm),
            ),
            (Route<dynamic> route) => false);
      } else if (useBiometric) {
        confirmBiometrics();
      } else {
        if (newUser) {
          // for Mobile Users
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (BuildContext context) => const IntroductionPage(),
              ),
              (Route<dynamic> route) => false);
        } else {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (BuildContext context) => const ScrawlApp()),
              (Route<dynamic> route) => false);
        }
      }
    });
    if (mounted) {
      setState(() {});
    }
  }

  void confirmBiometrics() async {
    bool res = await Navigator.of(context).push(CupertinoPageRoute(
        builder: (BuildContext context) => const BiometricPage()));
    if (res) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) => const ScrawlApp(),
          ),
          (Route<dynamic> route) => false);
    }
  }

  @override
  void initState() {
    super.initState();
    getPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}
