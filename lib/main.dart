import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'data/authentication/repository/authentication/admin_auth_repo.dart';
import 'data/authentication/repository/authentication/authentication_repo.dart';
import 'features/home/screens/user/mark/provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Widgets Binding
  final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage
  await GetStorage.init();
  print("GetStorage initialized");

  // Await Splash Screen until other items load
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Firebase initialized");

  // Initialize UserAuthenticationRepository and AdminAuthenticationRepository

  Get.put(AdminAuthenticationRepository());
  Get.put(AuthenticationRepository());






  // Setup MultiProvider for SearchHistory and Bookmarks
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
      ],
      child: const App(),
    ),
  );
}
