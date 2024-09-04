import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scrawler/desktop_web/desktop_sign_in.dart';
import 'package:scrawler/helpers/adaptive.dart';
import 'package:scrawler/helpers/constants.dart';
import 'package:scrawler/helpers/globals.dart' as globals;
import 'package:scrawler/providers/user_api_provider.dart';
import 'package:scrawler/widgets/scrawl_snackbar.dart';

class DesktopForgotPassword extends StatefulWidget {
  final String email;
  const DesktopForgotPassword({super.key, required this.email});

  @override
  State<DesktopForgotPassword> createState() => _DesktopForgotPasswordState();
}

class _DesktopForgotPasswordState extends State<DesktopForgotPassword> {
  bool isDesktop = false;
  final _formKey = GlobalKey<FormState>();
  bool otpVerified = false;
  final loginWidth = 400.0;

  TextEditingController otpController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  void verifyOtp() async {
    if (otpController.text.isEmpty) return;
    Map<String, String> post = {
      'postdata': jsonEncode({
        'api_key': globals.apiKey,
        'email': widget.email,
        'otp': otpController.text,
        'type': 'fpwd'
      })
    };
    showSnackBar(context, 'Verifying OTP...');
    final result = await UserApiProvider.verifyRecoveryOtp(post);
    if (result['error'].toString().isEmpty) {
      setState(() {
        otpVerified = true;
      });
    } else {
      if (mounted) {
        showSnackBar(context, result['error']);
      }
    }
  }

  void updatePassword() async {
    if (newPasswordController.text.compareTo(confirmPasswordController.text) !=
        0) {
      showSnackBar(context, 'Password mismatch!');
      return;
    }
    Map<String, String> post = {
      'postdata': jsonEncode({
        'api_key': globals.apiKey,
        'user_email': widget.email,
        'user_pwd': newPasswordController.text
      })
    };
    final result = await UserApiProvider.updatePassword(post);
    if (result['error'].toString().isEmpty) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DesktopSignIn()),
            (route) => false);
      }
    } else {
      if (mounted) {
        showSnackBar(context, result['error']);
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isDesktop = isDisplayDesktop(context);

    Widget loginContent = SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Visibility(
                visible: kIsWeb,
                child: Text(
                  kAppName,
                  style: TextStyle(fontSize: 36.0, fontWeight: FontWeight.w200),
                ),
              ),
              const Visibility(visible: kIsWeb, child: kVSpace),
              const Text(
                'Forgot Password',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              const SizedBox(
                height: 25.0,
              ),
              Visibility(
                visible: !otpVerified,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 25.0, top: 10.0),
                  child: TextFormField(
                    controller: otpController,
                    decoration: const InputDecoration(
                      hintText: 'Enter OTP here',
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: !otpVerified,
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => verifyOtp(),
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: otpVerified,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 25.0, top: 10.0),
                  child: TextFormField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Enter New Password',
                      suffixIcon: Icon(Icons.password_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                    onFieldSubmitted: (value) {},
                  ),
                ),
              ),
              Visibility(
                visible: otpVerified,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 25.0, top: 10.0),
                  child: TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Confirm Password',
                      suffixIcon: Icon(Icons.password_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                    onFieldSubmitted: (value) {},
                  ),
                ),
              ),
              Visibility(
                visible: otpVerified,
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            updatePassword();
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
      ),
    );
    return kIsWeb
        ? Scaffold(
            resizeToAvoidBottomInset: false,
            body: Row(
              children: [
                if (isDesktop)
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
                      width: loginWidth,
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 50),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(width: 2)),
                          child: loginContent),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Container(),
              // child: MoveWindow(
              //   child: Container(
              //     // color: Colors.amber,
              //     padding: const EdgeInsets.symmetric(horizontal: 10),
              //     child: Visibility(
              //       visible: !UniversalPlatform.isMacOS,
              //       child: Row(
              //         crossAxisAlignment: CrossAxisAlignment.center,
              //         mainAxisAlignment: MainAxisAlignment.end,
              //         children: [
              //           InkWell(
              //             borderRadius: BorderRadius.circular(15),
              //             child: Container(
              //                 padding: const EdgeInsets.all(8),
              //                 decoration: BoxDecoration(
              //                     color: darkModeOn
              //                         ? kDarkSecondary
              //                         : kLightSelected,
              //                     border: Border.all(
              //                         color: darkModeOn
              //                             ? kDarkStroke
              //                             : kLightStroke),
              //                     borderRadius: BorderRadius.circular(20)),
              //                 child: const Icon(
              //                   YaruIcons.window_minimize,
              //                   size: 14,
              //                 )),
              //             onTap: () => appWindow.minimize(),
              //           ),
              //           kHSpace,
              //           InkWell(
              //             borderRadius: BorderRadius.circular(15),
              //             child: Container(
              //                 padding: const EdgeInsets.all(8),
              //                 decoration: BoxDecoration(
              //                     color: darkModeOn
              //                         ? kDarkSecondary
              //                         : kLightSelected,
              //                     border: Border.all(
              //                         color: darkModeOn
              //                             ? kDarkStroke
              //                             : kLightStroke),
              //                     borderRadius: BorderRadius.circular(20)),
              //                 child: const Icon(
              //                   Icons.close_outlined,
              //                   size: 14,
              //                 )),
              //             onTap: () => appWindow.close(),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
            ),
            body: Container(
              // padding: const EdgeInsets.symmetric(vertical: 10),
              margin: const EdgeInsets.only(top: 56),
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  Image.asset(
                    'images/scrawler-desktop.png',
                    // fit: BoxFit.fitHeight,
                    width: 50,
                    height: 50,
                  ),
                  kVSpace,
                  const Text(
                    kAppName,
                    style:
                        TextStyle(fontSize: 36.0, fontWeight: FontWeight.w200),
                  ),
                ],
              ),
            ),
            bottomSheet: Container(
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(width: 2))),
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 70, vertical: 30),
                  child: loginContent),
            ),
          );
  }
}
