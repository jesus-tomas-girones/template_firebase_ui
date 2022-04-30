import 'dart:async';
import 'package:firebase_ui/model/paciente.dart';
import 'package:firebase_ui/screens/informe_edit.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import '../api/api.dart';
import '../app.dart';
import '../model/informe.dart';
import '../widgets/campos_formulario.dart';
import 'informe_detalles.dart';

///
/// Pantalla que lista los informes creados por el usuario y que le permite crear
/// nuevos y acceder a ellos
///

class InformesPage extends StatefulWidget {
  const InformesPage({Key? key}) : super(key: key);

  @override
  _InformesPageState createState() => _InformesPageState();
}

class _InformesPageState extends State<InformesPage> {
  // TODO la lista de informes debe estar asociada a un usuario (obtener de BD)
  //  final List<Informe> _informes = Informe.mockData();
  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context);
    return InformeList(
      api: appState.api!.informes,
    );
  }

  ///
  /// Funcion que devuelve un widget para representar que no hay informes
  ///
  /*Widget _buildEmptyInformesPage() {
    return const Center(
      child: Text("No hay informes. Añade uno"),
    );
  }*/
}

class InformeList extends StatefulWidget {
  final Api<Informe> api;

  const InformeList({
    Key? key,
    required this.api,
  }) : super(key: key);

  @override
  _InformeListState createState() => _InformeListState();
}

class _InformeListState extends State<InformeList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Informe>>(
      future: widget.api.list(),
      builder: (context, futureSnapshot) {
        if (!futureSnapshot.hasData) {
          return _buildLoadingIndicator();
        }
        return StreamBuilder<List<Informe>>(
          initialData: futureSnapshot.data,
          stream: widget.api.subscribe(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return _buildLoadingIndicator();
            } else if (snapshot.data!.isEmpty) {
              // no hay datos
              return const Center(
                child: Text("Aun no hay informes creados"),
              );
            }

            return ListView.separated(
              separatorBuilder: ((context, index) => const Divider()),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return InformeTile(
                  informe: snapshot.data![index],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }
}

class InformeTile extends StatelessWidget {
  final Informe? informe;

  const InformeTile({
    this.informe,
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
                    // TODO los pacientes deben estar asociados al usuario, obtener de BD
                    builder: (context) => InformeDetallePage(
                          informeApi: appState!.informes,
                          informe: informe,
                          pacientes: Paciente.mockListaPacientes(),
                        )),
              );
      },
      title: Text(
          intl.DateFormat('dd/MM/yyyy h:mm a').format(informe!.fechaAccidente)),
      subtitle: Text(
        informe!.descripcion,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
        
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => showDialogSeguro(
              context: context,
              title: '¿Borrar informe?',
              ok: 'BORRAR',
              onAccept: () =>  appState!.informes.delete(informe!.id!),
            ),
          ),
        ],
      ),
    );
  }
}
