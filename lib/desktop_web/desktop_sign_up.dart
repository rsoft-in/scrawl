import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scrawler/helpers/adaptive.dart';
import 'package:scrawler/helpers/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/constants.dart';
import '../helpers/globals.dart' as globals;
import '../helpers/string_values.dart';
import '../providers/user_api_provider.dart';
import '../widgets/scrawl_otp_textfield.dart';
import '../widgets/scrawl_snackbar.dart';
import 'desktop_app_screen.dart';
import 'desktop_sign_in.dart';

class DesktopSignUp extends StatefulWidget {
  const DesktopSignUp({super.key});

  @override
  State<DesktopSignUp> createState() => _DesktopSignUpState();
}

class _DesktopSignUpState extends State<DesktopSignUp> {
  ScreenSize screenSize = ScreenSize.large;
  late SharedPreferences prefs;
  double signupWidth = 400;

  TextEditingController emailController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();
  ScrawlOtpFieldController otpController = ScrawlOtpFieldController();

  int showIndex = 0;
  bool isBusy = false;
  String otp = '';
  bool otpSent = false;
  bool showSkipButton = false;

  final _signUpFormKey = GlobalKey<FormState>();

  void signUp() async {
    Map<String, String> post = {
      'postdata': jsonEncode({
        'api_key': globals.apiKey,
        'email': emailController.text,
        'name': fullNameController.text,
        'pwd': passwordController.text
      })
    };
    setState(() {
      isBusy = true;
    });
    UserApiProvider.sendVerification(post).then((value) {
      if (value['status']) {
        otpSent = true;
        showIndex++;
        setState(() {});
      } else {
        showSnackBar(context, value['error']);
      }
    });
  }

  void otpVerification() async {
    Map<String, String> post = {
      'postdata': jsonEncode({
        'api_key': globals.apiKey,
        'email': emailController.text,
        'otp': otp,
      })
    };
    setState(() {
      isBusy = true;
    });
    UserApiProvider.verifyOtp(post).then((value) async {
      if (value['user'] != null) {
        prefs = await SharedPreferences.getInstance();
        prefs.setBool('is_signed_in', true);
        globals.user = value['user'];
        prefs.setString('user_id', globals.user!.userId);
        prefs.setString('user_email', globals.user!.userEmail);
        prefs.setString('user_name', globals.user!.userName);
        prefs.setString('user_otp', globals.user!.userOtp);
        prefs.setString('user_pwd', globals.user!.userPwd);
        prefs.setBool('user_enabled', globals.user!.userEnabled);
        setState(() {});
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (BuildContext context) => const DesktopApp()),
              (route) => false);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(value['error']),
          duration: const Duration(seconds: 2),
        ));
      }
    });
  }

  @override
  void initState() {
    // doWhenWindowReady(() {
    //   const initialSize = Size(450, 720);
    //   appWindow.minSize = initialSize;
    //   appWindow.size = initialSize;
    //   appWindow.alignment = Alignment.center;
    //   appWindow.show();
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = getScreenSize(context);
    Widget signUpItems = Form(
      key: _signUpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: Text(
              kLabels['join_the_family']!,
              style: const TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
          kVSpace,
          TextFormField(
            controller: emailController,
            onChanged: (value) {
              showSkipButton =
                  value.isNotEmpty && RegExp(kEmailRegEx).hasMatch(value);
              setState(() {});
            },
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return kLabels['please_enter_text'];
              }
              if (!RegExp(kEmailRegEx).hasMatch(value)) {
                return kLabels['invalid_email'];
              }
              return null;
            },
          ),
          Visibility(
            visible: showSkipButton,
            child: Container(
              padding: kGlobalOuterPadding,
              alignment: Alignment.center,
              child: TextButton(
                child: Text(kLabels['have_otp']!),
                onPressed: () {
                  setState(() {
                    showIndex = 1;
                    otpSent = true;
                  });
                },
              ),
            ),
          ),
          kVSpace,
          TextFormField(
            controller: fullNameController,
            decoration: const InputDecoration(labelText: 'Fullname'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return kLabels['please_enter_text'];
              }
              return null;
            },
          ),
          kVSpace,
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return kLabels['please_enter_text'];
              }
              return null;
            },
          ),
          kVSpace,
          TextFormField(
            controller: confirmPassController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirm Password'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return kLabels['please_enter_text'];
              }
              if (value != passwordController.text) {
                return kLabels['password_mismatch'];
              }
              return null;
            },
          ),
          kVSpace,
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  child: Text(kLabels['continue']!),
                  onPressed: () {
                    if (_signUpFormKey.currentState!.validate()) {
                      signUp();
                    } else {
                      return;
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
    Widget otpItems =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 15.0),
        child: Text(
          kLabels['verify_email']!,
          style: const TextStyle(
            fontSize: 18.0,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 25.0),
        child: Text(
          kLabels['otp_sent_to_email']!,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Text(
          kLabels['otp']!,
          style: const TextStyle(
            fontSize: 18.0,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: Row(
          children: [
            Expanded(
                child: ScrawlOtpTextField(
                    length: 6,
                    otpController: otpController,
                    onChanged: (pin) {
                      otp = pin;
                      setState(() {});
                    },
                    onCompleted: (pin) {
                      otp = pin;
                      setState(() {});
                    })),
          ],
        ),
      ),
      Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(5),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 2),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.all(7),
              child: const Icon(Icons.arrow_back),
            ),
            onTap: () {
              setState(() {
                showIndex = 0;
                otpSent = false;
              });
            },
          ),
          kHSpace,
          Expanded(
            child: FilledButton(
              onPressed: otp.length == 6
                  ? () {
                      otpVerification();
                    }
                  : null,
              child: Text(kLabels['continue']!),
            ),
          ),
        ],
      ),
    ]);
    Widget signupContent = SingleChildScrollView(
      child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              kAppName,
              style: TextStyle(fontSize: 36.0, fontWeight: FontWeight.w200),
            ),
            kVSpace,
            if (showIndex == 0) signUpItems,
            if (showIndex == 1 && otpSent) otpItems,
            const SizedBox(
              height: 40.0,
            ),
            Container(
              alignment: Alignment.center,
              child: RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: kLabels['already_have_account'],
                  ),
                  TextSpan(
                      text: kLabels['login'],
                      style: const TextStyle(
                        color: kLinkColor,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const DesktopSignIn()),
                              (route) => false);
                        }),
                ]),
              ),
            ),
          ]),
    );
    return screenSize == ScreenSize.large
        ? Scaffold(
            backgroundColor: kPrimaryColor.withOpacity(0.2),
            resizeToAvoidBottomInset: false,
            body: Row(
              children: [
                Expanded(
                  child: Center(
                    child: SvgPicture.asset(
                      'images/welcome.svg',
                      width: 300,
                      height: 300,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: signupWidth,
                      child: Card(
                        child: Padding(
                          padding: kGlobalOuterPadding * 3,
                          child: signupContent,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Scaffold(
            backgroundColor: kPrimaryColor.withOpacity(0.2),
            bottomSheet:
                Padding(padding: kGlobalOuterPadding * 3, child: signupContent),
          );
  }
}
