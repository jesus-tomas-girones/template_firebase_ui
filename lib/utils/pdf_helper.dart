// Clase para generar ficheros pdf y guardarlos en local
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as x;
import 'dart:developer';
import 'package:path_provider/path_provider.dart';

import '../model/informe.dart';

class PDFHelper{


  ///
  /// Funcion que formatea un [Informe] a una estructura de pdf
  /// 
  /// args:
  ///   Objeto informe
  /// 
  /// returns:
  ///   Documento pdf
  ///
  ///
  Future<pw.Document>  generar_pdf_de_informe(Informe informe) async{
    final pdf = pw.Document();
    // cargar una fuente que permita unicode
    final font = await rootBundle.load("assets/fonts/OpenSans-Regular.ttf");
    final ttf = pw.Font.ttf(font);

    pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            // TODO crear estructura del pdf informe
            return pw.Padding(
              padding: const pw.EdgeInsets.all(16),
              child: pw.Column(
                children: [
                  pw.Text("Informe", style: pw.TextStyle(font: ttf, fontSize: 30)),
                  pw.Divider(),
                  pw.Text(informe.titulo, style: pw.TextStyle(font: ttf, fontSize: 30)),
                ],
              )
            );
          }));

    return pdf;
  }

  ///
  ///
  /// Funcion que guarda un documento en pdf
  /// args:
  ///   nombre del documento
  ///   documento a guardar
  /// 
  /// return:
  ///   el path donde se guardo
  ///
  Future<String> guardar_pdf(String nombre_documento,pw.Document documento) async{
    // EN ANDROID SI SE GUARDA PERO NO NOTIFICA, lo guarda en una carpeta 
    // /android/data/com.example.firebase_ui/files
    // TODO ver como cambiarlo a descargas
    
    if (!kIsWeb) {
        if (Platform.isIOS ||
            Platform.isAndroid ||
            Platform.isMacOS) {
          
          bool status = await Permission.storage.isGranted;
          if (!status) await Permission.storage.request();
        }

      }

       String path = "";
      if(kIsWeb){
        final data = await documento.save();
      
        MimeType type = MimeType.PDF;
        path = await FileSaver.instance.saveFile(
            nombre_documento,
            data,
            "pdf",
            mimeType: type);
      }else if(Platform.isAndroid){
         // TODO no se si en IOS funcionaria
        final directory = await getApplicationDocumentsDirectory();
        path = directory.path;
        var file = File('$path/$nombre_documento.pdf');
        file.writeAsBytes(await documento.save());
        
      }else{
        // TODO como guardar en otras plataformas 
      }
      

       

      return path;
  }

}