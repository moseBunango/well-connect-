import 'package:flutter/material.dart';

class ScreenUi {
final BuildContext context;

  static const double baseWidth = 360.0;
  static const double baseHeight = 640.0;

ScreenUi(this.context);

    double screenWidth() {
    return MediaQuery.of(context).size.width;
  }

  double screenHeight() {
    return MediaQuery.of(context).size.height;
  }

  double widthScaleFactor() {
    return screenWidth() / baseWidth;
  }

  double heightScaleFactor() {
    return screenHeight() / baseHeight;
  }

  double scaleWidth(double width) {
    return width * widthScaleFactor();
  }

  double scaleHeight(double height) {
    return height * heightScaleFactor();
  }

  double scaleFontSize(double fontSize) {
    return fontSize * widthScaleFactor();
  }
}
