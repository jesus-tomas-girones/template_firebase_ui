import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<AppState>(
        create: (_) => AppState(null, null),
      ),
      ChangeNotifierProvider<PacienteState >(
        create: (_) => PacienteState() ,
      ),
    ],
    child: const App(),
  ));
}

