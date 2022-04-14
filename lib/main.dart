import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'api/api.dart';
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
    child: App(),
  ));
}

/// The global state the app.
class AppState extends ChangeNotifier {
  User? user; // User es del paquete Firebase
  DashboardApi? api; //TODO: Revisar, No esta claro si hay que dejarlo.

  AppState(this.user, this.api);

  void updateAndNotify(User? newUser, DashboardApi? newApi) {
    user = newUser;  // actualizamos campos
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
  Widget build(BuildContext context) =>
      Consumer<AppState>(builder: (context, appState, child) {//TODO: Revisar
        return StreamBuilder<User?>( //TODO: Mirar que es StreamBuilder<User?>
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              // User is not signed in
              return const UserSignInScreen();
            } else {
              // Render your application if authenticated
              var _user = snapshot.data!;
              appState.updateAndNotify(_user, null);
              return const HomePage(
                  onSignOut: _handleSignOut); //UserProfileScreen();
            }
          },
        );
      });

/*  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(    //DODO: Mirar que es StreamBuilder<User?>
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) { // User is not signed in
          return const UserSignInScreen();
        }        // Render your application if authenticated
        var _user = snapshot.data;
        //AppState.updateAndNotify(_user, null);
        return const HomePage(onSignOut: _handleSignOut); //UserProfileScreen();
      },
    );
  }*/

}

Future _handleSignOut() async {
  //TODO: Quitarlo. Mejor hacer un signout directa
  FirebaseAuth.instance.signOut();
}
