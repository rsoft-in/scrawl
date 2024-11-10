import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:material_symbols_icons/symbols.dart';
import 'package:scrawler/desktop/desktop_app.dart';
import 'package:scrawler/helpers/constants.dart';
import 'package:scrawler/helpers/utility.dart';
import 'package:scrawler/models/users_model.dart';
import 'package:scrawler/widgets/scrawl_otp_textfield.dart';
import 'package:scrawler/widgets/scrawl_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/globals.dart' as globals;

class WebSignIn extends StatefulWidget {
  const WebSignIn({super.key});

  @override
  State<WebSignIn> createState() => _WebSignInState();
}

class _WebSignInState extends State<WebSignIn> {
  late SharedPreferences preferences;
  bool isSignUpMode = false;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();
  ScrawlOtpFieldController otpController = ScrawlOtpFieldController();

  List<User> users = [];
  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();
  String otp = '';

  Future<void> setAPIServer() async {
    try {
      String server = await rootBundle.loadString('res/apiserver');
      globals.apiServer = server;
      getPreferences();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void getPreferences() async {
    preferences = await SharedPreferences.getInstance();
    final appSignedIn = preferences.getBool("scrawler_signed_in") ?? false;
    if (appSignedIn && mounted) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DesktopApp()),
          (Route<dynamic> route) => false);
    }
  }

  Future<void> signIn() async {
    try {
      var response = await http.Client().post(
          Uri.parse("${globals.apiServer}/signin"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'username': usernameController.text,
            'password': passwordController.text
          }));
      if (response.statusCode == 200) {
        final parsed = json.decode(response.body);
        users = parsed.map<User>((json) => User.fromJson(json)).toList();
        if (mounted) {
          if (users.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid Username or Password!'),
                duration: Duration(seconds: 3),
              ),
            );
          } else {
            setState(() {
              globals.user = users[0];
              preferences.setBool('scrawler_signed_in', true);
              preferences.setString('user_id', globals.user!.userId);
              preferences.setString('user_name', globals.user!.userName);
              preferences.setString('user_email', globals.user!.userEmail);
              preferences.setBool('user_enabled', globals.user!.userEnabled);
            });
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const DesktopApp()),
                (Route<dynamic> route) => false);
          }
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> emailVerification(bool isNew) async {
    try {
      var response = await http.Client().post(
        Uri.parse('${globals.apiServer}/verifyemail'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'fullname': isNew ? fullNameController.text : 'FORGOTPASSWORD',
          'email': emailController.text,
        }),
      );
      if (mounted) {
        if (response.statusCode == 200) {
          final res = response.body.split('|');
          if (res.length == 2) {
            showSnackBar(context, res[0]);
            setState(() {
              otp = res[1];
            });
          } else {
            showSnackBar(context, 'Unable to verify Email');
          }
        } else {
          showSnackBar(context, response.body);
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        showSnackBar(context, '$e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setAPIServer();
  }

  @override
  Widget build(BuildContext context) {
    Widget signInForm = Form(
      key: _signInFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: usernameController,
            decoration: const InputDecoration(
              hintText: 'Email',
              prefixIcon: Icon(Symbols.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter Email';
              }
              return null;
            },
          ),
          kVSpace,
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Password',
              prefixIcon: Icon(Symbols.password),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter Password';
              }
              return null;
            },
          ),
          kVSpace,
          FilledButton(
            onPressed: () {
              if (_signInFormKey.currentState!.validate()) {
                signIn();
              }
            },
            child: const Text('Sign-In'),
          ),
          kVSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Don\'t have an account?'),
              kHSpace,
              TextButton(
                onPressed: () => setState(() {
                  isSignUpMode = true;
                }),
                child: const Text('Sign-Up'),
              ),
            ],
          ),
          kVSpace,
          TextButton(
            onPressed: () {
              if (usernameController.text.isEmpty) {
                showSnackBar(context, 'Enter your registered Email!');
                return;
              }
              emailVerification(false);
            },
            child: const Text('Forgot password?'),
          ),
        ],
      ),
    );

    Widget signUpForm = Form(
      key: _signUpFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: fullNameController,
            decoration: const InputDecoration(
              hintText: 'Full Name',
              prefixIcon: Icon(Symbols.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
          kVSpace,
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
              hintText: 'Email',
              prefixIcon: Icon(Symbols.email),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an Email';
              }
              if (!Utility.isEmail(value)) {
                return 'Enter a valid Email';
              }
              return null;
            },
          ),
          kVSpace,
          TextFormField(
            controller: newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Password',
              prefixIcon: Icon(Symbols.password),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a Password';
              }
              if (confirmPassController.text.isNotEmpty &&
                  confirmPassController.text != value) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          kVSpace,
          TextFormField(
            controller: confirmPassController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Confirm Password',
              prefixIcon: Icon(Symbols.password),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a Password';
              }
              if (newPasswordController.text.isNotEmpty &&
                  newPasswordController.text != value) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          kVSpace,
          FilledButton(
            onPressed: () {
              if (_signUpFormKey.currentState!.validate()) {
                // Create Account and Send OTP to Email
                emailVerification(true);
              }
            },
            child: const Text('Submit'),
          ),
          kVSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Already have an account?'),
              kHSpace,
              TextButton(
                onPressed: () => setState(() {
                  isSignUpMode = false;
                }),
                child: const Text('Sign-In'),
              ),
            ],
          ),
        ],
      ),
    );

    Widget otpForm = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Email Verification',
          style: TextStyle(fontSize: 22),
        ),
        kVSpace,
        Text(
            'An OTP has been sent to your Email address. Please enter it here for verification.'),
        ScrawlOtpTextField(otpController: otpController),
      ],
    );

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                kAppName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w200,
                ),
              ),
              kVSpace,
              otp.isEmpty ? (isSignUpMode ? signUpForm : signInForm) : otpForm,
              kVSpace,
              Text(
                '© Rennovation Software 2024',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
