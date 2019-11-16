import 'package:flutter/material.dart';
import 'package:qrcode_example/ui/activities/home.dart';
import 'package:qrcode_example/utils/colors_palette.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primaryColor: ColorsPalette.primaryColor,
      cursorColor: ColorsPalette.primaryColor
    ),
    home: Home(title: 'QR Code Example',),
  ));
}