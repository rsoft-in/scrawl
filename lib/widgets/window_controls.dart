import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:bnotes/helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:bnotes/helpers/globals.dart' as globals;
import 'package:yaru_icons/yaru_icons.dart';

class WindowControls extends StatelessWidget {
  const WindowControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = (globals.themeMode == ThemeMode.dark ||
        (brightness == Brightness.dark &&
            globals.themeMode == ThemeMode.system));
    return Row(
      children: [
        InkWell(
          child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: darkModeOn ? kDarkSecondary : kLightSelected,
                  border: Border.all(
                      color: darkModeOn ? kDarkStroke : kLightStroke),
                  borderRadius: BorderRadius.circular(20)),
              child: const Icon(
                YaruIcons.window_minimize,
                size: 14,
              )),
          onTap: () => appWindow.minimize(),
        ),
        kHSpace,
        InkWell(
          child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: darkModeOn ? kDarkSecondary : kLightSelected,
                  border: Border.all(
                      color: darkModeOn ? kDarkStroke : kLightStroke),
                  borderRadius: BorderRadius.circular(20)),
              child: const Icon(
                YaruIcons.window_maximize,
                size: 14,
              )),
          onTap: () => appWindow.maximizeOrRestore(),
        ),
        kHSpace,
        InkWell(
          child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: darkModeOn ? kDarkSecondary : kLightSelected,
                  border: Border.all(
                      color: darkModeOn ? kDarkStroke : kLightStroke),
                  borderRadius: BorderRadius.circular(20)),
              child: const Icon(
                YaruIcons.window_close,
                size: 14,
              )),
          onTap: () => appWindow.close(),
        ),
      ],
    );
  }
}