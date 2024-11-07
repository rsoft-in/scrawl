import 'package:flutter/material.dart';
import 'package:scrawler/helpers/constants.dart';
import 'package:universal_platform/universal_platform.dart';

ThemeData theme(BuildContext context, Color appColor) {
  return ThemeData(
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: appColor,
      dynamicSchemeVariant: DynamicSchemeVariant.content,
    ),
    splashFactory: NoSplash.splashFactory,
    listTileTheme: listTileThemeData(),
    elevatedButtonTheme: elevatedButtonThemeData(),
    filledButtonTheme: filledButtonThemeData(),
    outlinedButtonTheme: outlinedButtonThemeData(context),
    textButtonTheme: textButtonThemeData(),
    dialogTheme: dialogTheme(),
    dropdownMenuTheme: dropdownMenuThemeData(),
    popupMenuTheme: popupMenuThemeData(),
    inputDecorationTheme: inputDecorationTheme(),
    searchBarTheme: _searchBarThemeData(context),
    searchViewTheme: searchViewThemeData(),
    tabBarTheme: tabBarTheme(context),
  );
}

ThemeData themeDark(BuildContext context, Color appColor) {
  return ThemeData(
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: appColor,
      brightness: Brightness.dark,
      dynamicSchemeVariant: DynamicSchemeVariant.content,
    ),
    splashFactory: NoSplash.splashFactory,
    listTileTheme: listTileThemeData(),
    elevatedButtonTheme: elevatedButtonThemeData(),
    filledButtonTheme: filledButtonThemeData(),
    outlinedButtonTheme: outlinedButtonThemeData(context),
    textButtonTheme: textButtonThemeData(),
    dialogTheme: dialogTheme(),
    dropdownMenuTheme: dropdownMenuThemeData(),
    popupMenuTheme: popupMenuThemeData(),
    inputDecorationTheme: inputDecorationTheme(),
    searchBarTheme: _searchBarThemeData(context),
    searchViewTheme: searchViewThemeData(),
    tabBarTheme: tabBarTheme(context),
  );
}

// ListTile
ListTileThemeData listTileThemeData() {
  return ListTileThemeData(
    dense: UniversalPlatform.isDesktopOrWeb ? true : false,
  );
}

// ElevatedButton
ElevatedButtonThemeData elevatedButtonThemeData() {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kGlobalBorderRadius),
      ),
    ),
  );
}

// FilledButton
FilledButtonThemeData filledButtonThemeData() {
  return FilledButtonThemeData(
    style: FilledButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kGlobalBorderRadius),
      ),
    ),
  );
}

// OutlinedButton
OutlinedButtonThemeData outlinedButtonThemeData(BuildContext context) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kGlobalBorderRadius),
          side:
              BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
    ),
  );
}

// TextButton
TextButtonThemeData textButtonThemeData() {
  return TextButtonThemeData(
    style: TextButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kGlobalBorderRadius),
      ),
    ),
  );
}

// DialogTheme
DialogTheme dialogTheme() {
  return DialogTheme(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kGlobalBorderRadius)),
  );
}

// DropdownMenu
DropdownMenuThemeData dropdownMenuThemeData() {
  return DropdownMenuThemeData(
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kGlobalBorderRadius),
      ),
    ),
  );
}

// PopupMenu
PopupMenuThemeData popupMenuThemeData() {
  return PopupMenuThemeData(
    position: PopupMenuPosition.under,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(kGlobalBorderRadius),
    ),
    menuPadding: const EdgeInsets.all(0),
  );
}

InputDecorationTheme inputDecorationTheme() {
  return InputDecorationTheme(
    filled: true,
    floatingLabelBehavior: FloatingLabelBehavior.never,
    isDense: true,
    hintStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
    counterStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
    labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
    helperStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(25),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(width: 2),
      borderRadius: BorderRadius.circular(25),
    ),
  );
}

SearchBarThemeData _searchBarThemeData(BuildContext context) {
  return SearchBarThemeData(
    padding: const WidgetStatePropertyAll<EdgeInsets>(
      EdgeInsets.symmetric(horizontal: 16.0),
    ),
    constraints: const BoxConstraints(maxHeight: 50, minHeight: 40),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kGlobalBorderRadius)),
    ),
    elevation: const WidgetStatePropertyAll(0),
    // side: WidgetStatePropertyAll(
    //   BorderSide(
    //     width: 1.5,
    //     color: Theme.of(context).colorScheme.outlineVariant,
    //   ),
    // ),
    // backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
  );
}

SearchViewThemeData searchViewThemeData() {
  return SearchViewThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(kGlobalBorderRadius),
    ),
    side: BorderSide.none,
  );
}

TabBarTheme tabBarTheme(BuildContext context) {
  return TabBarTheme(
    indicator: BoxDecoration(
      color: Theme.of(context).colorScheme.surface.withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
    ),
    indicatorSize: TabBarIndicatorSize.tab,
    dividerHeight: 0,
    tabAlignment: TabAlignment.start,
  );
}
