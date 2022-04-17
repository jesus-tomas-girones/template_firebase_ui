import 'package:flutter/material.dart';
import 'api/api.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'api/firebase.dart';
import 'screens/home.dart';
import 'screens/user_sign_in.dart';

class AppState extends ChangeNotifier {
  // The global state the app.
  User? user; // User es del paquete Firebase
  DashboardApi? api; //TODO: Revisar, No esta claro si hay que dejarlo.

  AppState(this.user, this.api);

  void updateAndNotify(User? newUser, DashboardApi? newApi) {
    user = newUser; // actualizamos campos
    api = newApi;
    notifyListeners(); //notificamos a los widgets para que se repinten
  }
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Template con Firebase',
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.all(24),
            ),
            backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
        //TODO: Mirar que es StreamBuilder<User?>
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            // User is not signed in
            return const UserSignInScreen();
          } else {
            // Render your application if authenticated
            var _user = snapshot.data!;
            Provider.of<AppState>(context, listen: false).updateAndNotify(_user,
                FirebaseDashboardApi(FirebaseFirestore.instance, _user.uid));
            return const HomePage();
          }
        },
      );
}
