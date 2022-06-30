// Clase para generar ficheros pdf y guardarlos en local
import 'package:firebase_ui/model/gasto.dart';
import 'package:firebase_ui/utils/numero_helper.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as x;
import 'dart:developer';
import 'package:path_provider/path_provider.dart';

import '../model/informe.dart';
import '../model/paciente.dart';
import '../model/secuela.dart';

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
  Future< Document>  generar_pdf_de_informe(Informe informe, Paciente? paciente) async{
    final pdf =  Document(pageMode: PdfPageMode.outlines,);
    // cargar una fuente que permita unicode
    final font = await rootBundle.load("assets/fonts/OpenSans-Regular.ttf");
    final ttf =  Font.ttf(font);

    final  TextStyle tituloStyle =  TextStyle(font: ttf, fontSize: 30);
    final  TextStyle cabeceraStyle =  TextStyle(fontBold: ttf,fontSize: 24,);
    final  TextStyle textoStyle =  TextStyle(font: ttf,);

    // el widget de pdf trata cada widget como un bloque, por tanto si uno es muy grande y no cabe en una hoja
    // pone un espacio en blanco, para que en el caso de descripciones largas las separe en varias hojas, habra que separarlo
    // en diferentes variables para poder poner diferentes widgets
    List<String> descripcionSeparado = [];
    if(informe.descripcion!=null && informe.descripcion!="") {
        descripcionSeparado = _separarTextoLargo(informe.descripcion!);
    }

    final bool hayIntervenciones = informe.gastos.any((element) => element.tipoGasto == TipoGasto.Cirugia);
    final bool hayOtrosGastos = informe.gastos.any((element) => element.tipoGasto != TipoGasto.Cirugia);
   
    pdf.addPage( 
      MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: ( Context context) {
            return  <Widget> [ 
              Column(
                crossAxisAlignment:  CrossAxisAlignment.start,
                children: [
                  // =======================================================================
                  // Cabecera y paciente
                  // =======================================================================
                   Text("Informe médico: "+informe.titulo, style: tituloStyle),
                   Divider(),
                   SizedBox(height: 16),
                  _pdfPaciente(paciente, cabeceraStyle,textoStyle),
                  
                  
                  // =======================================================================
                  // descripcion
                  // =======================================================================
                  if(informe.descripcion!=null && informe.descripcion!="") 
                    Column(children: [
                      SizedBox(height: 16),
                      Text("Descricpión del informe",style: cabeceraStyle),
                      SizedBox(height: 8),
                    ]),
                    
                  if(informe.descripcion!=null && informe.descripcion!="") 
                    for(int i=0;i<descripcionSeparado.length;i++)
                      Text(descripcionSeparado[i],style: textoStyle,textAlign: TextAlign.justify),
                  

                  // =======================================================================
                  // muerte TODO pdf muerte
                  // =======================================================================
                  if(!informe.hayMuerte) _pdfMuerte(informe),

                  // =======================================================================
                  // lesiones
                  // =======================================================================
                  if(!informe.hayMuerte && informe.hayLesion) 
                  // titulo
                    Column(
                          children: [
                            SizedBox(height: 16),
                            Text("Lesiones", style: cabeceraStyle),
                            SizedBox(height: 8),
                          ]
                        ),
                  // lesiones
                    if(!informe.hayMuerte && informe.hayLesion) 
                      Wrap(
                        children: [
                           Text(informe.lesiones??"",style: textoStyle,textAlign: TextAlign.justify),
                          Container(height: 16),
                        ]
                      ),
                    //perjucio báscio
                    if(!informe.hayMuerte && informe.hayLesion) 
                      Wrap(
                        children: [
                          Text("El perjuicio personal básico consiste en el daño moral común -dolor, sufrimiento, malestar- que padece cualquier persona que resulte herida, desde el momento del accidente hasta la finalización del proceso curativo o hasta la estabilización de la lesión y su conversión en secuela (art. 136)", style: textoStyle,textAlign: TextAlign.justify),
                          Container(height: 8),
                          Text("Perjuicio Personal Básico por lesión temporal: "+informe.diasPerjuicio.toString()+" días", style: textoStyle),
                          Container(height: 16),
                        ]
                      ),
                    // perjucio personal particular
                    if(!informe.hayMuerte && informe.hayLesion) 
                    Wrap(
                      children: [
                        
                        Text("Perjuicio Personal Particular por pérdida temporal de la calidad de vida. Tiene como objetivo compensar el impedimento o limitación que las lesiones o su tratamiento suponen para la autonomía o desarrollo personal del afectado en sus actividades diarias", style: textoStyle,textAlign: TextAlign.justify),
                        Container(height: 8),
                        Text("Perjuicio Personal Particular Muy Grave: "+informe.diasUci.toString()+" días", style: textoStyle),
                        Container(height: 8),
                        Text("Perjuicio Personal Particular Grave: "+informe.diasPlanta.toString()+" días", style: textoStyle),
                        Container(height: 8),
                        Text("Perjuicio Personal Particular Moderado: "+informe.diasBaja.toString()+" días", style: textoStyle),
                        Container(height: 16),
                      
                      ]
                    ),
                  // total importe
                    if(!informe.hayMuerte && informe.hayLesion) 
                      Text("Importe total por las lesiones: "+formatoMoneda(informe.calcularImporteIndemnizacionesLesiones().round())+" €", style: textoStyle),
                    
                    
                  // =======================================================================
                  // secuelas 
                  // =======================================================================
                  if(!informe.hayMuerte &&informe.haySecuela) 
                    Column(
                      children: [
                        SizedBox(height: 16),
                        Text("Secuelas", style: cabeceraStyle),
                        SizedBox(height: 8),
                      ]
                    ),
                  if(!informe.hayMuerte &&informe.haySecuela) 
                    for(int i=0;i<informe.secuelas.length;i++)
                      Wrap(
                        children: [
                          Text(informe.secuelas[i].descripcion??"",style: textoStyle),
                          Divider(),
                          SizedBox(height: 8),
                          Table(  
                            columnWidths: {
                              0: const FlexColumnWidth(8),
                              1: const FlexColumnWidth(1),
                            },
                            border: TableBorder.all(),
                            // el segundo bucle es el de los table row, que contiene que secuela es y que puntos tiene
                            children: _buildTableRowsSecuelas(informe.secuelas[i],textoStyle),
                          ),
                          Container(height: 16),
                        ]
                      ),
                  if(!informe.hayMuerte &&informe.haySecuela) 
                    Wrap(
                      children: [
                        Text("Total puntos por secuelas: "+informe.calcularPuntosSecuelas().toString(), style: textoStyle),
                        Container(height: 16)
                      ]
                    ),
                

                  // =======================================================================
                  // Intervenciones
                  // =======================================================================
                  if(hayIntervenciones)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Intervenciones", style: cabeceraStyle),
                        Text("El lesionado que debe someterse a intervenciones quirúrgicas durante el proceso de curación, sufre un plus de perjuicio resarcible. La fijación de la cuantía dependerá de las características de la operación, su complejidad técnica y el tipo de anestesia.",textAlign: TextAlign.justify,style: textoStyle)
                      ]
                    ),
                  if(hayIntervenciones)
                    Table(  
                            columnWidths: {
                              0: const FlexColumnWidth(.5),
                              1: const FlexColumnWidth(.3),
                              2: const FlexColumnWidth(.2),
                            },
                            border: TableBorder.all(),
                            // el segundo bucle es el de los table row, que contiene que secuela es y que puntos tiene
                            children: _buildTableRowsIntervenciones(informe.gastos.where((element) => element.tipoGasto == TipoGasto.Cirugia).toList(),textoStyle),
                          ),
                  // =======================================================================
                  // Otros gastos
                  // =======================================================================
                  if(hayOtrosGastos)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16),
                        Text("Otros gastos", style: cabeceraStyle),
                        SizedBox(height: 8),
                       ]
                    ),
                  if(hayOtrosGastos)
                    Table(  
                            columnWidths: {
                              0: const FlexColumnWidth(8),
                              2: const FlexColumnWidth(2),
                            },
                            border: TableBorder.all(),
                            // el segundo bucle es el de los table row, que contiene que secuela es y que puntos tiene
                            children: _buildTableRowsGastos(informe.gastos.where((element) => element.tipoGasto != TipoGasto.Cirugia).toList(),textoStyle),
                          ),
                  // =======================================================================
                  // Ficheros adjuntos
                  // =======================================================================

                ],
              )
            ];
          },
          
        ),
    );

    return pdf;
  }

  

  Widget _pdfPaciente(Paciente? paciente, TextStyle cabeceraStyle, TextStyle textoStyle) {
    if(paciente!=null){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Paciente", style:cabeceraStyle),
          SizedBox(height: 8),
          // nombre y apellidos
          if(paciente.nombre !=null) Row(children: [Text("Nombre y apellidos: ",style: textoStyle),Text(paciente.nombre!+" ",style: textoStyle),Text(paciente.apellidos??"",style: textoStyle),]), 
          // fecha nacimiento (split(" ")[0] para quitar la hora)
          if(paciente.fechaNacimiento !=null) Row(children: [Text("Fecha de nacimiento: ",style: textoStyle),Text(paciente.fechaNacimiento.toString().split(" ")[0],style: textoStyle),]),
          // TODO no poner to string en los enums
          if(paciente.sexo !=null) Row(children: [Text("Sexo: ",style: textoStyle),Text(paciente.sexo.toString(),style: textoStyle),]),
          if(paciente.domicilio !=null) Row(children: [Text("Domicilio: ",style: textoStyle),Text(paciente.domicilio!,style: textoStyle),]),
          if(paciente.telefono !=null && paciente.telefono!="") Row(children: [Text("Teléfono: ",style: textoStyle),Text(paciente.telefono!,style: textoStyle),]),
          if(paciente.dni !=null) Row(children: [Text("DNI: ",style: textoStyle),Text(paciente.dni!,style: textoStyle),]),
          if(paciente.nuss !=null) Row(children: [Text("NUSS: ",style: textoStyle),Text(paciente.nuss!,style: textoStyle),]),
          if(paciente.ocupacion !=null) Row(children: [Text("Ocupación: ",style: textoStyle),Text(paciente.ocupacion!,style: textoStyle),]),
          if(paciente.empresa !=null) Row(children: [Text("Empresa: ",style: textoStyle),Text(paciente.empresa!,style: textoStyle),]),
          SizedBox(height: 8),
          if(paciente.antecedentesMedicos !=null) Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Antecedentes médicos ",style: textoStyle),Text(paciente.antecedentesMedicos!,style: textoStyle),]),
          


        ]
      );
    }else{
      return  Center();
    }
    
  }

  Widget _pdfMuerte(Informe informe) {
    return Center();
  }

  Widget _pdfLesiones(Informe informe) {
    return Center();
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
  Future<String> guardar_pdf(String nombre_documento, Document documento) async{
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
        final directory = await getExternalStorageDirectory();
        path = directory!.path;
        var file = File('$path/$nombre_documento.pdf');
        file.writeAsBytes(await documento.save(),flush: true);
        
      }else{
        // TODO como guardar en otras plataformas 
      }
      

       

      return path;
  }

  // 
  // Funcion para separar un String muy largo en varios dentro de un string
  //
  List<String> _separarTextoLargo(String descripcion) {
    // separar primero por las frases, despues juntar frases cortas en parrafos 
    List<String> descripcionSeparado = descripcion.split("\n");
    
   
    for(int i = 0; i<descripcionSeparado.length;i++){
      if(descripcionSeparado[i].length>2000){
        List<String> temp = descripcionSeparado[i].split(".");
      
        descripcionSeparado[i] = "";
        descripcionSeparado.insertAll(i, temp.map((e) => e+"."));// añadirle el punto que se le ha quitado con el replace
      }
    }
    return descripcionSeparado;
  }


  ///
  /// Montar los table rows dada una secuela
  ///
  List<TableRow> _buildTableRowsSecuelas(Secuela secuela, TextStyle textoStyle) {
    
      List<TableRow> tableRows = [];
      // hay diferentes tablas con sus titulos
        for(int j=0;j<secuela.secuelas.length;j++){
          // añadir cabecera
          if(j==0){
            tableRows.add(TableRow(
              verticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                Padding(padding: const EdgeInsets.all(8),child: Text("Secuela",style: textoStyle)),
                Padding(padding: const EdgeInsets.all(8), child: Text("Puntos",style: textoStyle))
              ]
            ));
          }
          // contenido
          tableRows.add(TableRow(
            verticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              Padding(padding: const EdgeInsets.all(8),child: Text(secuela.secuelas[j].secuela!)),
              Padding(padding: const EdgeInsets.all(8), child: Text(secuela.secuelas[j].puntos.toString(),textAlign: TextAlign.center))
            ]
          ));


        }
          return tableRows;
  }
  

   ///
  /// Montar los table rows dada una lista de intervenciones quirurigicas
  ///
  List<TableRow> _buildTableRowsIntervenciones(List<Gasto> intervenciones, TextStyle textoStyle) {
    
      List<TableRow> tableRows = [];
      // hay diferentes tablas con sus titulos
        for(int j=0;j<intervenciones.length;j++){
          // añadir cabecera
          if(j==0){
            tableRows.add(TableRow(
              verticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                Padding(padding: const EdgeInsets.all(8),child: Text("Intervención",style: textoStyle)),
                Padding(padding: const EdgeInsets.all(8), child: Text("Grupo quirúrgico",style: textoStyle)),
                Padding(padding: const EdgeInsets.all(8), child: Text("Indemnización",style: textoStyle)),
              ]
            ));
          }
          // contenido
          tableRows.add(TableRow(
            verticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              Padding(padding: const EdgeInsets.all(8),child: Text(intervenciones[j].descripcion,style: textoStyle)),
              Padding(padding: const EdgeInsets.all(8), child: Text(intervenciones[j].especialidad.toString()+"-"+intervenciones[j].grado.toString(),style: textoStyle)),
              Padding(padding: const EdgeInsets.all(8), child: Text(formatoMoneda(intervenciones[j].importe.round())+" €",style: textoStyle,textAlign: TextAlign.center))
            ]
          ));


        }
          return tableRows;
  }
  

   ///
  /// Montar los table rows dada una lista de intervenciones quirurigicas
  ///
  List<TableRow> _buildTableRowsGastos(List<Gasto> gastos, TextStyle textoStyle) {
    
      List<TableRow> tableRows = [];
      // hay diferentes tablas con sus titulos
        for(int j=0;j<gastos.length;j++){
          // añadir cabecera
          if(j==0){
            tableRows.add(TableRow(
              verticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                Padding(padding: const EdgeInsets.all(8),child: Text("Gasto",style: textoStyle)),
                Padding(padding: const EdgeInsets.all(8), child: Text("Importe",style: textoStyle)),
              ]
            ));
          }
          // contenido
          tableRows.add(TableRow(
            verticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              Padding(padding: const EdgeInsets.all(8),child: Text(gastos[j].descripcion,style: textoStyle)),
              Padding(padding: const EdgeInsets.all(8), child: Text(formatoMoneda(gastos[j].importe.round())+" €",style: textoStyle,textAlign: TextAlign.center))
            ]
          ));


        }
          return tableRows;
  }
 

}