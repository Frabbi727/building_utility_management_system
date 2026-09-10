import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTextStyles {
  static TextStyle get headlineLarge => GoogleFonts.inter(
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
  );
}
