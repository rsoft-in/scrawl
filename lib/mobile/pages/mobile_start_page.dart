import 'package:flutter/material.dart';
import 'package:scrawler/mobile/pages/mobile_home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../helpers/constants.dart';

class MobileStartPage extends StatefulWidget {
  const MobileStartPage({super.key});

  @override
  State<MobileStartPage> createState() => _MobileStartPageState();
}

class _MobileStartPageState extends State<MobileStartPage> {
  late SharedPreferences prefs;
  bool isVerifiedUser = false;
  bool isUserSignedIn = false;

  getPref(context) async {
    prefs = await SharedPreferences.getInstance();
    isVerifiedUser = prefs.getBool("is_verified_user") ?? false;
    isUserSignedIn = prefs.getBool("is_used_signedin") ?? false;
    if (isVerifiedUser || UniversalPlatform.isWeb) {
      if (isUserSignedIn) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MobileHomePage()),
            (route) => false);
      }
      // else {
      //   Navigator.pushAndRemoveUntil(
      //       context,
      //       MaterialPageRoute(builder: (context) => const MobileSignIn()),
      //       (route) => false);
      // }
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MobileHomePage()),
          (route) => false);
    }
  }

  @override
  void initState() {
    getPref(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.asset(
                    'images/scrawler.png',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Visibility(
        visible: isVerifiedUser,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Center(
                child: Text(
                  kAppName,
                  style: TextStyle(fontSize: 22),
                ),
              ),
            ),
            SizedBox(
              width: 200,
              child: FilledButton(onPressed: () {}, child: const Text('Login')),
            ),
            kVSpace,
          ],
        ),
      ),
    );
  }
}
