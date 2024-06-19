import 'package:book_Verse/utils/theme/custom_theme/appbar_theme.dart';
import 'package:book_Verse/utils/theme/custom_theme/bottom_sheet_theme.dart';
import 'package:book_Verse/utils/theme/custom_theme/checkbox_theme.dart';
import 'package:book_Verse/utils/theme/custom_theme/chip_theme.dart';
import 'package:book_Verse/utils/theme/custom_theme/elevated_button_theme.dart';
import 'package:book_Verse/utils/theme/custom_theme/outlined_button_theme.dart';
import 'package:book_Verse/utils/theme/custom_theme/text_field_theme.dart';
import 'package:flutter/material.dart';
import 'package:book_Verse/utils/theme/custom_theme/text_theme.dart';



class TAppTheme{
  TAppTheme._();

  /// LIGHT Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
    textTheme: TTextTheme.lightTextTheme,
    chipTheme: TChipTheme.lightChipTheme,
    elevatedButtonTheme: TElevatedButtonTheme.lightElevatedButtonTheme,
    appBarTheme: TAppBarTheme.lightAppBarTheme,
    checkboxTheme: TCheckboxTheme.lightCheckboxtheme,
    bottomSheetTheme: TBottomSheetTheme.lightBottomSheetTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.lightOutlinedButtontheme,
    inputDecorationTheme: TTextFieldTheme.lightInputDecorationTheme,


  );
  ///DARK THEME
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.black,
    textTheme: TTextTheme.darkTextTheme,
    elevatedButtonTheme: TElevatedButtonTheme.darkElevatedButtonTheme,
    chipTheme: TChipTheme.darkChipTheme,
    appBarTheme: TAppBarTheme.darkAppBarTheme,
    checkboxTheme: TCheckboxTheme.darkCheckboxtheme,
    bottomSheetTheme: TBottomSheetTheme.darkBottomSheetTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.darkOutlinedButtontheme,
    inputDecorationTheme: TTextFieldTheme.darkInputDecorationTheme,
  );
}