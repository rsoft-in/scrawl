import 'package:flutter/material.dart';
import 'package:scrawler/helpers/globals.dart' as globals;

class ColorPaletteButton extends StatelessWidget {
  final Function onTap;
  final Color color;
  final bool isSelected;

  const ColorPaletteButton(
      {super.key,
      required this.onTap,
      required this.color,
      required this.isSelected});

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = (globals.themeMode == ThemeMode.dark ||
        (brightness == Brightness.dark &&
            globals.themeMode == ThemeMode.system));
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(
                color: darkModeOn ? Colors.white12 : Colors.black26)),
        child: isSelected ? const Icon(Icons.check) : Container(),
      ),
      onTap: () => onTap(),
    );
  }
}
