import 'package:flutter/material.dart';

class ResponsiveUtil {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Get proportional width based on screen size
  static double propWidth(BuildContext context, double percentage) =>
      MediaQuery.of(context).size.width * percentage;

  /// Get proportional height based on screen size
  static double propHeight(BuildContext context, double percentage) =>
      MediaQuery.of(context).size.height * percentage;
}
