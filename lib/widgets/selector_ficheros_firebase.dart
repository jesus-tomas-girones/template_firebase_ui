import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../utils/firestore_utils.dart';
import 'visor_fichero_http.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

///
/// Clase que lista ficheros referenciados en una coleccion de firebase
/// y permite añadir y borrar
///
class SelectorFicherosFirebase extends StatefulWidget{
  
  final String firebaseColecion;
  final String storageRef;
  final String titulo;
  final String textoNoFicheros;
  final double padding;

  const SelectorFicherosFirebase({Key? key, 
    required this.firebaseColecion, 
    required this.storageRef,
    required this.titulo,
    required this.textoNoFicheros,
    this.padding = 16
  }) : super(key: key);

  @override
  _SelectorFicherosFirebaseState createState() => _SelectorFicherosFirebaseState();
  
}

class _SelectorFicherosFirebaseState extends State<SelectorFicherosFirebase>{
  
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection(widget.firebaseColecion).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        // cargando || no hay datos 
        if(!snapshot.hasData || _isLoading){
          return const Center(
            child: Padding(padding: EdgeInsets.all(64),child: Center(child:CircularProgressIndicator()),),
          );
        }
        // hay datos o no esta cargando
        return Column(
          children: [
            // TITULO
            Padding(
              padding: EdgeInsets.fromLTRB(widget.padding, widget.padding, widget.padding, 0),
              child:  Row(
                children: [
                    Text(widget.titulo),
                    const SizedBox(width: 16,),
                    ElevatedButton(
                      child: const Text("Añadir ficheros"),
                      onPressed: _addFicheros, 
                    ),
                ],
              ),
            ),
          
          // CUERPO
          snapshot.data!.docs.isEmpty 
            ? Padding(padding: const EdgeInsets.all(64),child: Center(child:Text(widget.textoNoFicheros)),)
            : ListView.builder(
              padding: EdgeInsets.fromLTRB(widget.padding, widget.padding, widget.padding, widget.padding),
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(), // se necesita para poder poner un list view dentro de otro
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index){
                DocumentSnapshot doc = snapshot.data!.docs[index];
                
                return  _buildListaFicherosSubidosItem(doc);
                
              }
            )
          ]
        );
    });
  }
 
  ///
  /// Callbcak del file picker
  ///
  void _addFicheros() async{
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        onFileLoading: (FilePickerStatus status) => {},
        allowedExtensions: ['*']
   //     allowedExtensions: ['jpg', 'jpeg', 'gif', 'png','pdf', 'doc', 'docx',
   //       'xls', 'xlsm', 'ppt', 'pptx' 'txt', 'csv', ]
    );

    if (result != null) {
      _setLoading(true);
      for(PlatformFile file in result.files){
        String url = await uploadFile(file,widget.storageRef+file.name);
        FirebaseFirestore.instance.collection(widget.firebaseColecion).add({
          "url":url,
          "nombre":file.name
        });
      }

      _setLoading(false);
    }
  }
  
  ///
  /// Callbcak borrar fichero
  ///
  void _borrarFichero(urlStorage,idColeccion) async{
      _setLoading(true);
      // borrar de firestore
      await FirebaseFirestore.instance.collection(widget.firebaseColecion).doc(idColeccion).delete();
      // borrar de storage
      await deleteFile(urlStorage);
      _setLoading(false);
  }

  Widget _buildListaFicherosSubidosItem(DocumentSnapshot<Object?> doc){
    // para controlar el nombre del fichero (por ejmplo el 60% de la pantalla)
    double screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: ()  {
        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
          return VisorFicheroHttp(
            url: doc["url"], 
            titulo: doc["nombre"],
            extension: doc["nombre"].toString().split(".")[1]);
        }));
      },
      child: Card(
          elevation: 5,
          shadowColor: Colors.black,
          color: Colors.greenAccent[100],
          // Dos rows para que el icono de la foto y el nombre salgan al lado y el eliminar a la otra punta
          child: Row(
//            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Expanded( child: Row(
                  children: [
                    const SizedBox(width: 8),
                    const Icon(Icons.image), //TODO Poner icono diferente según extensión.
                    const SizedBox(width: 8),
                    LimitedBox(maxWidth: screenWidth*0.6,child: Text(doc["nombre"], overflow: TextOverflow.ellipsis, softWrap: false,),)
                  ]
              )),
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () async {
                   //Solo funciona en Web
                    if (await canLaunchUrlString(doc["url"]))
                       await launchUrlString(doc["url"]);
                    else throw "Could not launch url";
                },
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: (){
                  setState(() {
                    _borrarFichero(doc["url"],doc.id);
                  });
                },
              ),
            ],
        ),
      ),
    );
  }

  void _setLoading(bool v){
    setState(() {
      _isLoading = v;
    });
  }

}
