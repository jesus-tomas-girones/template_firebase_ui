import 'package:file_picker/file_picker.dart';
import 'package:firebase_ui/api/api.dart';
import 'package:firebase_ui/modelo/TipoAccidente.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Indemnizacion.dart';
import 'Paciente.dart';
import '../api/api.dart';
///
/// Clase que representa un informe
///
@JsonSerializable()
class Informe{

  @JsonKey(ignore: true)
  String? id;

  DateTime fechaAccidente; // no existe long en dart
  String descripcion;
  String lugarAccidente;
  TipoAccidente tipoAccidente;
  String companyiaAseguradora;
  Paciente paciente;
  List<PlatformFile> ficherosAdjuntos = [];

  List<Indemnizacion> indemnizaciones = [];

  Informe(this.fechaAccidente,this.descripcion,this.companyiaAseguradora,this.lugarAccidente,this.paciente,this.tipoAccidente,
    this.ficherosAdjuntos,this.indemnizaciones);


  factory Informe.fromJson(Map<String, dynamic> json) =>
      _$InformeFromJson(json);
  Map<String, dynamic> toJson() => _$InformeToJson(this);

  // TODO quitar
  static List<Informe> mockData(){
    return [
      Informe(DateTime.now(),"Accidente 1","Mafre","C/False 1",Paciente(1,"Paciente 1"),TipoAccidente.Deportivo,[],[]),
      Informe(DateTime.now(),"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus quis sapien luctus, iaculis nisi sit amet, eleifend arcu. Aenean semper arcu at massa dapibus, at ullamcorper urna aliquet. Fusce imperdiet at dui a vulputate. Proin sit amet nulla nec velit semper posuere. Nulla facilisi. Nullam congue ut purus eget pulvinar. Maecenas pharetra, dolor ut pulvinar feugiat, ligula justo tempus nibh, fringilla imperdiet libero mi ut justo. Vestibulum eu felis libero. Aenean semper, ex non malesuada cursus, ligula tellus ullamcorper risus, eget elementum leo nunc a tellus. Mauris lectus arcu, porta id finibus at, porta sed odio. Praesent rutrum id mi ut posuere. Nulla facilisis tincidunt sem, ut sollicitudin ipsum euismod vitae. Fusce dictum ut augue eget rutrum. Suspendisse nulla magna, hendrerit vel consequat eu, posuere nec ante. Sed egestas tincidunt vulputate.","Mafre","C/False 123",
        Paciente(3, "Paciente 3"),TipoAccidente.Deportivo,[],[]),
      Informe(DateTime.now(),"Accidente 2","Mafre","C/False 12",Paciente(2,"Paciente 2"),TipoAccidente.Deportivo,[],[]),
    ];
  }

  static Timestamp _dateTimeToTimestamp(DateTime dateTime) {
    return Timestamp.fromMillisecondsSinceEpoch(
        dateTime.millisecondsSinceEpoch);
  }

  static DateTime _timestampToDateTime(Timestamp timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(
        timestamp.millisecondsSinceEpoch);
  }


  @override
  operator ==(Object other) => other is Informe && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

Informe _$InformeFromJson(Map<String, dynamic> json) {
  return Informe(
    Informe._timestampToDateTime(json['fecha_accidente'] as Timestamp),
    json['descripcion'] as String,
    json['aseguradora'] as String,
    json['lugar_accidente'] as String,
    Paciente(1,""),// TODO cambiar a pacientefrom json
    TipoAccidente.Deportivo,//TODO averiguar como de string a enum
    [],// TODO cambiar a ficherosAdjuntos from firestore o similar, se guardara la url de firestore????
    [],// TODO obtener las indemnizaciones
  );
}

Map<String, dynamic> _$InformeToJson(Informe instance) => <String, dynamic>{
      'fecha_accidente': Informe._dateTimeToTimestamp(instance.fechaAccidente),
      'descripcion': instance.descripcion,
      'aseguradora': instance.companyiaAseguradora,
      'lugar_accidente': instance.lugarAccidente,
      'paciente': instance.paciente.id,
      'tipo_accidente': instance.tipoAccidente.toString(),
      'ficheros_adjuntos': "aqui ira el listado de url a firestore",//TODO cambiar ficheros adjuntos
      'indemnizaciones':instance.indemnizaciones
};