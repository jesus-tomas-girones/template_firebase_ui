import 'package:firebase_ui/model/paciente.dart';
import 'package:firebase_ui/screens/informes.dart';
import 'package:firebase_ui/screens/paciente_edit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../widgets/third_party/adaptive_scaffold.dart';
import 'informe_edit/informe_edit.dart';
import 'pacientes.dart';
import 'user_profile.dart';
import 'user_profile_ui.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _pageIndex = 0;


  
  @override
  Widget build(BuildContext context) {
    //print(widget.photoUrl);
    // TODO valorar si hay otra solucion mejor
    return _buildBody();
  }

  Widget _buildBody(){
    return AdaptiveScaffold(
      title: const Text('Template con Firebase'),
      actions: [
        // Poner un row para que salgan centrados
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UserProfileScreen()),
              );
            },
            child: Consumer<AppState>(builder: (context, appState, child) {
              String? url = appState.user!.photoURL;
              String name = appState.user!.displayName ?? "Anónimo";
              if (url == null) {
                return Tooltip(message: name, child: const CircleAvatar(child: Icon(Icons.person)),);
              } else {
                return Tooltip(message: name, child: CircleAvatar(backgroundImage: NetworkImage(url)));
              }
            }),
          ),
        ),
      ],
      currentIndex: _pageIndex,
      destinations: const [
        AdaptiveScaffoldDestination(title: 'Informes', icon: Icons.dashboard),
        AdaptiveScaffoldDestination(title: 'Pacientes', icon: Icons.person),
        AdaptiveScaffoldDestination(title: 'Settings', icon: Icons.settings),
      ],
      body: _pageAtIndex(_pageIndex),
      onNavigationIndexChange: (newIndex) {
        setState(() {
          _pageIndex = newIndex;
        });
      },
      floatingActionButton:
          _hasFloatingActionButton ? _buildFab(context) : null,
    );
  }

  bool get _hasFloatingActionButton {
    if (_pageIndex == 2) return false;
    return true;
  }

  FloatingActionButton _buildFab(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () => _handleFabPressed(),
    );
  }

  void _handleFabPressed() {
    var api = Provider.of<AppState>(context, listen:false).api;
    if (_pageIndex == 0) {
      List<Paciente>? pacientes = Provider.of<AppState>(context,listen: false).pacientes;
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => InformeEditPage(
              informeApi: api!.informes,
              pacienteApi: api.pacientes,
              informe: null,
              pacientes: pacientes,)),
      );
      return;
    }
    if (_pageIndex == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PacienteEditPage(
              pacienteApi: api!.pacientes,
              paciente: null)
        ),
      );
      return;
    }
  }

  static Widget _pageAtIndex(int index) {
    if (index == 0) {
      return const InformesPage();
    }
    if (index == 1) {
      return const PacientesPage();
    }
    return const UserProfileUiScreen();
  }
}
