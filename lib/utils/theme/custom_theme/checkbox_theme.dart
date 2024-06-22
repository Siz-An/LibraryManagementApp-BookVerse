import 'package:flutter/material.dart';

class TCheckboxTheme{
  TCheckboxTheme._();
  /// Customizable Light Text Theme
static CheckboxThemeData lightCheckboxtheme = CheckboxThemeData(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  checkColor: WidgetStateProperty.resolveWith((states){
    if (states.contains(WidgetState.selected)){
      return Colors.white;
  }
    else {
      return Colors.black;
  }
  }),
  fillColor: WidgetStateProperty.resolveWith((states){
    if (states.contains(WidgetState.selected)){
      return Colors.blue;
    }
    else {
      return Colors.transparent;
    }
  }
  ));

  /// Customizable Light Text Theme
  static CheckboxThemeData darkCheckboxtheme = CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      checkColor: WidgetStateProperty.resolveWith((states){
        if (states.contains(WidgetState.selected)){
          return Colors.white;
        }
        else {
          return Colors.black;
        }
      }),
      fillColor: WidgetStateProperty.resolveWith((states){
        if (states.contains(WidgetState.selected)){
          return Colors.blue;
        }
        else {
          return Colors.transparent;
        }
      }
      ));
}