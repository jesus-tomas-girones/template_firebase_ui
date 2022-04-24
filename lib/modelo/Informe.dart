import 'package:file_picker/file_picker.dart';
import 'package:firebase_ui/modelo/TipoAccidente.dart';

import 'Indemnizacion.dart';
import 'Paciente.dart';

///
/// Clase que representa un informe
///
class Informe{
  DateTime fechaAccidente; // no existe long en dart
  String descripcion;
  String lugarAccidente;
  TipoAccidente tipoAccidente;
  String companyiaAseguradora;
  Paciente paciente;
  List<PlatformFile> ficherosAdjuntos = [];

  List<Indemnizacion> indemnizaciones = [];

  Informe(this.fechaAccidente,this.descripcion,this.companyiaAseguradora,this.lugarAccidente,this.paciente,this.tipoAccidente,this.ficherosAdjuntos);

  /// 
  /// Indemnizacion -> addIndemnizacion()
  /// 
  void addIndemnizacion(Indemnizacion indemnizacion){
    indemnizaciones.add(indemnizacion);
  }

  // TODO quitar
  static List<Informe> mockData(){
    return [
      Informe(DateTime.now(),"Accidente 1","Mafre","C/False 1",Paciente(1,"Paciente 1"),TipoAccidente.Deportivo,[]),
      Informe(DateTime.now(),"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus quis sapien luctus, iaculis nisi sit amet, eleifend arcu. Aenean semper arcu at massa dapibus, at ullamcorper urna aliquet. Fusce imperdiet at dui a vulputate. Proin sit amet nulla nec velit semper posuere. Nulla facilisi. Nullam congue ut purus eget pulvinar. Maecenas pharetra, dolor ut pulvinar feugiat, ligula justo tempus nibh, fringilla imperdiet libero mi ut justo. Vestibulum eu felis libero. Aenean semper, ex non malesuada cursus, ligula tellus ullamcorper risus, eget elementum leo nunc a tellus. Mauris lectus arcu, porta id finibus at, porta sed odio. Praesent rutrum id mi ut posuere. Nulla facilisis tincidunt sem, ut sollicitudin ipsum euismod vitae. Fusce dictum ut augue eget rutrum. Suspendisse nulla magna, hendrerit vel consequat eu, posuere nec ante. Sed egestas tincidunt vulputate.","Mafre","C/False 123",
        Paciente(3, "Paciente 3"),TipoAccidente.Deportivo,[]),
      Informe(DateTime.now(),"Accidente 2","Mafre","C/False 12",Paciente(2,"Paciente 2"),TipoAccidente.Deportivo,[]),
    ];
  }

}