import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'resources.dart';

class AppTextStyles {
  TextStyle poppins({
    Color? color,
    double? fs,
    FontWeight? fw,
  }) {
    return GoogleFonts.poppins(
      fontSize: fs,
      color: color ?? R.colors.offWhiteColor,
      fontWeight: fw,
    );
  }
  
  TextStyle montserrat({
    Color? color,
    double? fs,
    FontWeight? fw,
  }) {
    return GoogleFonts.montserrat(
      fontSize: fs,
      color: color ?? R.colors.blackText,
      fontWeight: fw,
    );
  }

  TextStyle rubik({
    Color? color,
    double? fs,
    FontWeight? fw,
  }) {
    return GoogleFonts.rubik(
      fontSize: fs,
      color: color ?? R.colors.blackText,
      fontWeight: fw,
    );
  }

 
}
