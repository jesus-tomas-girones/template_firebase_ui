import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
///
///
/// Clase que visualiza una imagen o pdf desde la web
///
class HttpVisualizadorFichero extends StatelessWidget{
  
  final String url;
  final String titulo;
  final String extension;

  const HttpVisualizadorFichero({Key? key, 
    required this.url, 
    required this.titulo,
    required this.extension,
  }) : super(key: key);

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(titulo),
      ),
      body: extension == "pdf"
        ? SfPdfViewer.network(url,)
        : Center(child: Image.network(url)),
    );
  }

    
}