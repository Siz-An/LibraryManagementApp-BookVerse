
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get_storage/get_storage.dart';
import 'app.dart';
import 'data/authentication/repository/authentication_repo.dart';
import 'firebase_options.dart';

Future<void> main() async {
/// -----> Widgets Binding
  final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
///-----> GetX local storage
  await GetStorage.init();

  ///---> Await Splash Screen until Other item Load
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  ///----> Initialize firebase & firebase Auth repo
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform).then(
      (FirebaseApp value) => Get.put(AuthenticationRepository())
  );
  runApp(const App());
}


