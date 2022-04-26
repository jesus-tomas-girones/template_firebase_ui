///
/// Pantalla que lista los informes creados por el usuario y que le permite crear
/// nuevos y acceder a ellos
///

import 'dart:async';

import 'package:firebase_ui/modelo/Paciente.dart';
import 'package:firebase_ui/modelo/TipoAccidente.dart';
import 'package:firebase_ui/screens/informe_detalles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import '../api/api.dart';
import '../app.dart';
import '../modelo/Informe.dart';
import '../widgets/dialogs.dart';

class InformesPage extends StatefulWidget {
  const InformesPage({Key? key}) : super(key: key);

  @override
  _InformesPageState createState() => _InformesPageState();
}

class _InformesPageState extends State<InformesPage> {
  // TODO la lista de informes debe estar asociada a un usuario (obtener de BD)
   final List<Informe> _informes = Informe.mockData();
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
  Widget _buildEmptyInformesPage(){
    return const Center(
      child: Text("No hay informes. Añade uno"),
    );
  }
}

class InformeList extends StatefulWidget {

  final InformeApi api;

  const InformeList({
    Key? key,
    required this.api,
  }): super(key: key);

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
            }else if(snapshot.data!.isEmpty){
              // no hay datos
              return const Center(child: Text("Aun no hay informes creados"),);
            }

            return ListView.builder(
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
    var appState = Provider.of<AppState>(context,listen: false).api;
    return ListTile(
      title: Text(intl.DateFormat('dd/MM/yyyy h:mm a').format(informe!.fechaAccidente)),
      subtitle: Text(informe!.descripcion, maxLines: 3, overflow: TextOverflow.ellipsis,),
      
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                   // TODO los pacientes deben estar asociados al usuario, obtener de BD
                    builder: (context) => InformeDetallePage(
                      informeApi: appState!.informes,
                      informe: informe,
                      pacientes: Paciente.mockListaPacientes(),)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              var shouldDelete = await (showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete entry?'),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    TextButton(
                      child: const Text('Delete'),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              ) as FutureOr<bool>);
              if (shouldDelete) {
                /*await Provider.of<AppState>(context, listen: false)
                    .api!
                    .entries
                    .delete(category!.id!, entry!.id!);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Entry deleted'),
                  ),
                );*/
              }
            },
          ),
        ],
      ),
    );
  }
}
