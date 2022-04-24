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
    return Column(
      children: [
        Expanded(
          child: _informes.isEmpty 
              ? _buildEmptyInformesPage()
              // TODO cambiar a obtenerlo de la BD
              :  ListView.separated(
                  
                  separatorBuilder: (context, index) => 
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(color: Colors.black, thickness: 0.2,),),
                  
                  itemBuilder: (context, index) {
                    return InformeTile(
                      informe: _informes[index],
                    );
                  },

                  itemCount: _informes.length,
              )
                  
        ),
      ],
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

class EntriesList extends StatefulWidget {
  final Category? category;
  final EntryApi api;

  EntriesList({
    this.category,
    required this.api,
  }) : super(key: ValueKey(category?.id));

  @override
  _EntriesListState createState() => _EntriesListState();
}

class _EntriesListState extends State<EntriesList> {
  @override
  Widget build(BuildContext context) {
    if (widget.category == null) {
      return _buildLoadingIndicator();
    }

    return FutureBuilder<List<Entry>>(
      future: widget.api.list(widget.category!.id!),
      builder: (context, futureSnapshot) {
        if (!futureSnapshot.hasData) {
          return _buildLoadingIndicator();
        }
        return StreamBuilder<List<Entry>>(
          initialData: futureSnapshot.data,
          stream: widget.api.subscribe(widget.category!.id!),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return _buildLoadingIndicator();
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return EntryTile(
                  category: widget.category,
                  entry: snapshot.data![index],
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

class EntryTile extends StatelessWidget {
  final Category? category;
  final Entry? entry;

  const EntryTile({
    this.category,
    this.entry,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(entry!.value.toString()),
      subtitle: Text(intl.DateFormat('MM/dd/yy h:mm a').format(entry!.time)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            child: const Text('Edit'),
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (context) {
                  return EditEntryDialog(category: category, entry: entry);
                },
              );
            },
          ),
          TextButton(
            child: const Text('Delete'),
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
                await Provider.of<AppState>(context, listen: false)
                    .api!
                    .entries
                    .delete(category!.id!, entry!.id!);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Entry deleted'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
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
    return ListTile(
      title: Text(intl.DateFormat('dd/MM/yyyy h:mm a').format(informe!.fechaAccidente)),
      subtitle: Text(informe!.descripcion, maxLines: 3, overflow: TextOverflow.ellipsis,),
      
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO tratar el resultado de editar el informe
              var seGuardoLaEdicion = Navigator.push(
                context,
                MaterialPageRoute(
                   // TODO los pacientes deben estar asociados al usuario, obtener de BD
                    builder: (context) => InformeDetallePage(informe: informe,pacientes: Paciente.mockListaPacientes(),)),
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
