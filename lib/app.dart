import 'package:firebase_ui/model/paciente.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'api/api.dart';
import 'api/api_firebase.dart';
import 'screens/home.dart';
import 'screens/user_sign_in.dart';

class AppState extends ChangeNotifier {
  // The global state the app.
  User? user; // User es del paquete Firebase
  DashboardApi? api;

  AppState(this.user, this.api);

  void updateUserAndNotify(User? newUser) {
    user = newUser; // actualizamos campos
    notifyListeners(); //notificamos a los widgets para que se repinten
  }

  void updateApiAndNotify( DashboardApi? newApi){
    api = newApi;
    notifyListeners();
  }
}

class PacienteState extends ChangeNotifier{
  List<Paciente>? pacientes;

  void updatePacientesAndNotify(List<Paciente>? newPacientes) {
    pacientes = newPacientes; // actualizamos campos
    notifyListeners(); //notificamos a los widgets para que se repinten
  }

  void addPacienteAndNotify(Paciente? paciente) {
    if(paciente!=null && pacientes!=null){
      pacientes!.add(paciente); 
      notifyListeners(); //notificamos a los widgets para que se repinten
    }
   
  }

  void removePacienteAndNotify(Paciente? paciente) {
    if(paciente!=null && pacientes!=null){
      pacientes!.remove(paciente); 
      notifyListeners(); //notificamos a los widgets para que se repinten
    }
  }

  void updatePacienteAndNotify(Paciente oldPaciente, Paciente nuevoPaciente) {
    if(pacientes!=null){
      pacientes!.remove(oldPaciente); 
      pacientes!.add(nuevoPaciente); 
      notifyListeners(); //notificamos a los widgets para que se repinten
    }
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
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        //'/second': (context) => Page2(),
        //'/third': (context) => Page3(),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            // User is not signed in
            return const UserSignInScreen();
          } else {
            // Render your application if authenticated
            var _user = snapshot.data!;
            Provider.of<AppState>(context, listen: false).updateUserAndNotify(_user);
            Provider.of<AppState>(context, listen: false).updateApiAndNotify(FirebaseDashboardApi(FirebaseFirestore.instance, _user.uid));
            return const HomePage();
          }
        },
      );
}
