import 'package:file_picker/file_picker.dart';
import 'package:firebase_ui/modelo/TipoAccidente.dart';

import 'Indemnizacion.dart';
import 'Paciente.dart';

///
/// Clase que representa un informe
///
class Infrome{
  int fechaAccidenteMilis; // no existe long en dart
  String descripcion;
  String lugarAccidente;
  TipoAccidente tipoAccidente;
  String companyiaAseguradora;
  Paciente paciente;
  List<PlatformFile> ficherosAdjuntos = [];

  List<Indemnizacion> indemnizaciones = [];

  Infrome(this.fechaAccidenteMilis,this.descripcion,this.companyiaAseguradora,this.lugarAccidente,this.paciente,this.tipoAccidente,this.ficherosAdjuntos);

  /// 
  /// Indemnizacion -> addIndemnizacion()
  /// 
  void addIndemnizacion(Indemnizacion indemnizacion){
    indemnizaciones.add(indemnizacion);
  }
}