
import 'package:book_Verse/bindings/general_binding.dart';
import 'package:book_Verse/utils/constants/colors.dart';
import 'package:book_Verse/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      initialBinding: GeneralBinding(),
      ///--> Show Loader or circular Progress meanWhile Authentication Repository is deciding to show relevant screen
      home: const Scaffold(
        backgroundColor: TColors.primaryColor, body: Center(child: CircularProgressIndicator(color: Colors.white,),),
      ),
    );
  }

}