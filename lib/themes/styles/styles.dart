import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Styles {
  const Styles._();

  static TextStyle labelTextStyle = GoogleFonts.nunito(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );

  static TextStyle inputTextStyle = GoogleFonts.nunito(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );
  static TextStyle inputTextStyleWhite = GoogleFonts.nunito(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );

  static TextStyle hintTextStyle = GoogleFonts.nunito(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
  );

  static SizedBox verticalSpacer = const SizedBox(height: 20);

  static double generaleWidth = MediaQuery.of(Get.context!).size.width * 0.75;
  static double generaleHeight = MediaQuery.of(Get.context!).size.height * 0.9;
}
