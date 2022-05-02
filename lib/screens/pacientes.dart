import 'dart:async';
import 'package:firebase_ui/screens/paciente_edit.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import '../model/paciente.dart';
import '../api/api.dart';
import '../app.dart';
import '../widgets/campos_formulario.dart';

class PacientesPage extends StatefulWidget {
  const PacientesPage({Key? key}) : super(key: key);

  @override
  _PacientesPageState createState() => _PacientesPageState();
}

class _PacientesPageState extends State<PacientesPage> {
  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context);
    return PacienteList(
      api: appState.api!.pacientes,
    );
  }
}

class PacienteList extends StatefulWidget {
  final Api<Paciente> api;

  const PacienteList({
    Key? key,
    required this.api,
  }) : super(key: key);

  @override
  _PacienteListState createState() => _PacienteListState();
}

class _PacienteListState extends State<PacienteList> {
  @override
  Widget build(BuildContext context) {
    return _listarPacientesDesdeConsumer();
  }


  Widget _listarPacientesDesdeConsumer(){
    return Consumer<PacienteState>(
      builder: (context, pacientesState, child){
        if(pacientesState.pacientes != null && pacientesState.pacientes!.isEmpty){
          // no hay pacientes
          return const Center(
                child: Text("No hay pacientes. Añade uno."),
          );
        }
        return ListView.separated(
          separatorBuilder: ((context, index) => const Divider()),
          itemCount: pacientesState.pacientes?.length ?? 0,
          itemBuilder: ((context, index) {
            return PacienteTile(
                  paciente: pacientesState.pacientes![index],
            );
          })
        );
    });
  } 

  
  Widget _listarPacientesDesdeFirebase(){
    return FutureBuilder<List<Paciente>>(
      future: widget.api.list(),
      builder: (context, futureSnapshot) {
        if (!futureSnapshot.hasData) {
          return buildLoading();
        }
        return StreamBuilder<List<Paciente>>(
          initialData: futureSnapshot.data,
          stream: widget.api.subscribe(),
          builder: (context, snapshot) {
            
            if (!snapshot.hasData) {
              return buildLoading();
            } else if (snapshot.data!.isEmpty) {
              return const Center(
                child: Text("No hay pacientes. Añade uno."),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return PacienteTile(
                  paciente: snapshot.data![index],
                );
              },
            );
          },
        );
      },
    );
  } 

}



class PacienteTile extends StatelessWidget {
  final Paciente? paciente;

  const PacienteTile({
    this.paciente,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context, listen: false).api;
    return ListTile(
      onTap: () {
        Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PacienteEditPage(
                        pacienteApi: appState!.pacientes, paciente: paciente)),
              );
      },
      title: Text(
        (paciente!.nombre ?? "") + ' ' + (paciente!.apellidos ?? ""),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(paciente!.fechaNacimiento == null
          ? "<fecha desconocida>"
          : intl.DateFormat('dd/MM/yyyy').format(paciente!.fechaNacimiento!))
    );
  }
}
