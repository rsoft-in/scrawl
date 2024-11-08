import 'package:flutter/material.dart';
import 'package:scrawler/helpers/utility.dart';

ScreenSize getScreenSize(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width <= 480) {
    return ScreenSize.small;
  } else if (width > 480 && width <= 768) {
    return ScreenSize.medium;
  } else {
    return ScreenSize.large;
  }
}
