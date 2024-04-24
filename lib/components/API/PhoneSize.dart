import 'package:flutter/material.dart';

class PhoneSize{
  final BuildContext context;

  PhoneSize(this.context);

  // Helper function to adapt font size based on device size
double adaptFontSize(double fontSize) {
  final textScaleFactor = MediaQuery.of(context).textScaleFactor;
  return fontSize * textScaleFactor;
}

// Helper function to adapt spacing based on device size (optional)
double adaptHeight(double height) {
  final screenHeight = MediaQuery.of(context).size.height;
  // Adjust calculation as needed (e.g., percentage of screen height)
  return height *0.001* screenHeight; // Adjust multiplier for desired adaptation
}
}