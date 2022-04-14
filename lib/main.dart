import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'api/api.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

//import 'app_vieja.dart';
import 'auth/firebase.dart';
import 'firebase_options.dart';
import 'screens/home.dart';
import 'screens/user_profile.dart';
import 'screens/user_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ChangeNotifierProvider(
    create: (context) => AppState(null, null),
    child: const App(),
  ));
}

