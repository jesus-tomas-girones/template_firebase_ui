import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
///
/// Clase que visualiza una imagen o pdf desde la web
///
class VisorFicheroHttp extends StatelessWidget{
  
  final String url;
  final String titulo;
  final String extension;

  const VisorFicheroHttp({Key? key,
    required this.url, 
    required this.titulo,
    required this.extension,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(titulo),
      ),
      body:
        ['jpg','jpeg','gif','png'].contains(extension)
        ? Center(child: Image.network(url))
        : extension == "pdf"
           ? SfPdfViewer.network(url)
           : const Center(child: Text("Visualización no disponible. Descarga el fichero para verlo."))
    );
  }
    
}

class VisorFicheroLocal extends StatelessWidget{

  final String path;
  final String titulo;
  final String extension;

  const VisorFicheroLocal({Key? key,
    required this.path,
    required this.titulo,
    required this.extension,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Visualizando: " +path);
    File file = File(path);
    print("Fichero: " +file.toString());
    return Scaffold(
//      backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(titulo),
        ),
        body:
        ['jpg','jpeg','gif','png'].contains(extension)
            ? Center(child: Image.file(File(path)))
            : extension == "pdf"
            ? SfPdfViewer.file(file)
            : const Center(child: Text("Visualización no disponible. Descarga el fichero para verlo."))
    );
  }

}