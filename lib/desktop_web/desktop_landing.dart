import 'package:flutter/material.dart';
import 'package:scrawler/desktop_web/desktop_app_screen.dart';
import 'package:scrawler/desktop_web/desktop_sign_in.dart';
import 'package:scrawler/helpers/globals.dart' as globals;
import 'package:scrawler/models/users_model.dart';
import 'package:scrawler/providers/api_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DesktopLanding extends StatefulWidget {
  const DesktopLanding({super.key});

  @override
  State<DesktopLanding> createState() => _DesktopLandingState();
}

class _DesktopLandingState extends State<DesktopLanding> {
  late SharedPreferences prefs;
  bool isSignedIn = false;

  getPreferences(context) async {
    prefs = await SharedPreferences.getInstance();
    isSignedIn = prefs.getBool('is_signed_in') ?? false;
    globals.apiKey = await ApiProvider.fetchAPIKey();
    globals.apiServer = await ApiProvider.fetchAPIServer();
    User user = User.empty();
    user.userId = prefs.getString('user_id') ?? '';
    user.userEmail = prefs.getString('user_email') ?? '';
    user.userName = prefs.getString('user_name') ?? '';
    user.userOtp = prefs.getString('user_otp') ?? '';
    user.userPwd = prefs.getString('user_pwd') ?? '';
    user.userEnabled = prefs.getBool('user_enabled') ?? false;
    globals.user = user;
    if (!isSignedIn) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => const DesktopSignIn()),
          (route) => false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => const DesktopApp()),
          (route) => false);
    }
  }

  @override
  void initState() {
    super.initState();
    getPreferences(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}
