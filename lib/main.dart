import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'api/bookmark/bookMark_Provider.dart';
import 'api/models/search_history.dart';
import 'app.dart';
import 'data/authentication/repository/authentication_repo.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Widgets Binding
  final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage
  await GetStorage.init();

  // Await Splash Screen until Other items Load
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize Firebase & Firebase Auth repo
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform).then(
          (FirebaseApp value) => Get.put(AuthenticationRepository())
  );

  // Setup MultiProvider for SearchHistory and Bookmarks
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SearchHistory()),
        ChangeNotifierProvider(create: (_) => Bookmarks()), // Add Bookmarks provider
      ],
      child: const App(),
    ),
  );
}
