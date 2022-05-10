import 'package:file_picker/file_picker.dart';
import 'package:firebase_ui/api/api.dart';
import 'package:firebase_ui/utils/enum_helpers.dart';
import 'package:flutter/foundation.dart';
//import 'package:firebase_ui/model/TipoAccidente.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/date_time_helpers.dart';
import 'indemnizacion.dart';
import 'paciente.dart';
import '../api/api.dart';


enum TipoAccidente{
  Trafico, Laboral, Deportivo,  ViaPublica,
  
}
extension TipoAccidenteExtension on TipoAccidente {
  String get value {
    switch (this) {
      case TipoAccidente.Trafico:
        return "Trafico";
      case TipoAccidente.Laboral:
        return "Laboral";
      case TipoAccidente.Deportivo:
        return "Deportivo";
      case TipoAccidente.ViaPublica:
        return "Via publica";
      default:
        return "sin valor";
    }
  }
}

///
/// Clase que representa un informe
///
@JsonSerializable()
class Informe{

  @JsonKey(ignore: true)
  String? id;

  DateTime? fechaAccidente; // no existe long en dart
  String descripcion;
  String? lugarAccidente;
  TipoAccidente? tipoAccidente;
  String? companyiaAseguradora;
  String? idPaciente;
  //List<String>? ficherosAdjuntos = [];
  List<Indemnizacion>? indemnizaciones = [];

  Informe({this.fechaAccidente,this.descripcion = "",this.companyiaAseguradora,this.lugarAccidente,this.idPaciente,this.tipoAccidente,
    /*this.ficherosAdjuntos,*/this.indemnizaciones});
  
  clone()=> Informe(
    fechaAccidente: fechaAccidente,
    descripcion: descripcion,
    companyiaAseguradora: companyiaAseguradora,
    lugarAccidente: lugarAccidente,
    idPaciente: idPaciente,
    tipoAccidente: tipoAccidente,
    //ficherosAdjuntos: ficherosAdjuntos,
    indemnizaciones: indemnizaciones
  )..id = id; // esto seria el equivalente de hacer un setId despues de hacer la instancia, no se pone en el constructor para evitar problemas

 
  factory Informe.fromJson(Map<String, dynamic> json) =>
      _$InformeFromJson(json);
  Map<String, dynamic> toJson() => _$InformeToJson(this);

  // TODO quitar
  static List<Informe> mockData(){
    return [
      /*Informe(DateTime.now(),"Accidente 1","Mafre","C/False 1",

          Paciente(
              nombre: "Paciente 1",
              apellidos: "apell",
              fechaNacimiento: DateTime.now(),
              sexo: Sexo.hombre,
              domicilio: "1",
              telefono: "tel 1",
              dni: "dni 1",
              nuss: "nuss 1",
              nivelFormacion: NivelFormacion.analfabeto,
              antecedentesMedicos: "1",
              situacionLaboral: SituacionLaboral.activo,
              ocupacion: "1",
              empresa: "1"),
          TipoAccidente.Deportivo,[],[]),
      Informe(DateTime.now(),"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus quis sapien luctus, iaculis nisi sit amet, eleifend arcu. Aenean semper arcu at massa dapibus, at ullamcorper urna aliquet. Fusce imperdiet at dui a vulputate. Proin sit amet nulla nec velit semper posuere. Nulla facilisi. Nullam congue ut purus eget pulvinar. Maecenas pharetra, dolor ut pulvinar feugiat, ligula justo tempus nibh, fringilla imperdiet libero mi ut justo. Vestibulum eu felis libero. Aenean semper, ex non malesuada cursus, ligula tellus ullamcorper risus, eget elementum leo nunc a tellus. Mauris lectus arcu, porta id finibus at, porta sed odio. Praesent rutrum id mi ut posuere. Nulla facilisis tincidunt sem, ut sollicitudin ipsum euismod vitae. Fusce dictum ut augue eget rutrum. Suspendisse nulla magna, hendrerit vel consequat eu, posuere nec ante. Sed egestas tincidunt vulputate.","Mafre","C/False 123",
          Paciente(
              nombre: "Paciente 2",
              apellidos: "apell",
              fechaNacimiento: DateTime.now(),
              sexo: Sexo.hombre,
              domicilio: "1",
              telefono: "tel 1",
              dni: "dni 1",
              nuss: "nuss 1",
              nivelFormacion: NivelFormacion.analfabeto,
              antecedentesMedicos: "1",
              situacionLaboral: SituacionLaboral.activo,
              ocupacion: "1",
              empresa: "1"),
          TipoAccidente.Deportivo,[],[]),
      Informe(DateTime.now(),"Accidente 2","Mafre","C/False 12",
          Paciente(
              nombre: "Paciente 3",
              apellidos: "apell",
              fechaNacimiento: DateTime.now(),
              sexo: Sexo.hombre,
              domicilio: "1",
              telefono: "tel 1",
              dni: "dni 1",
              nuss: "nuss 1",
              nivelFormacion: NivelFormacion.analfabeto,
              antecedentesMedicos: "1",
              situacionLaboral: SituacionLaboral.activo,
              ocupacion: "1",
              empresa: "1"),
          TipoAccidente.Deportivo,[],[]),*/
    ];
  }

  @override
  int get hashCode => id.hashCode;


     @override
  bool operator ==(Object other) =>   // NO se compara el id.
      identical(this, other) ||
      other is Informe &&
          runtimeType == other.runtimeType &&
          fechaAccidente == other.fechaAccidente &&
          descripcion == other.descripcion &&
          lugarAccidente == other.lugarAccidente &&
          idPaciente == other.idPaciente &&
          tipoAccidente == other.tipoAccidente &&
          //ficherosAdjuntos == other.ficherosAdjuntos &&
          indemnizaciones == other.indemnizaciones;

 
}

Informe _$InformeFromJson(Map<String, dynamic> json) {
    return Informe(
      //Informe._timestampToDateTime(json['fecha_accidente'] as Timestamp),
      fechaAccidente: json['fecha_accidente'] == null ? null : timestampToDateTime(json['fecha_accidente'] as Timestamp),
      descripcion: json['descripcion'],
      companyiaAseguradora:json['aseguradora'],
      lugarAccidente: json['lugar_accidente'],
      idPaciente: json["paciente"],
      tipoAccidente: enumfromString(TipoAccidente.values, json["tipo_accidente"]),
      //ficherosAdjuntos: json["ficheros_adjuntos"] != null ? (json['ficheros_adjuntos'] as List).map((item) => item as String).toList() : [],
      indemnizaciones: [],// TODO obtener las indemnizaciones
    );
  
}

Map<String, dynamic> _$InformeToJson(Informe instance) => <String, dynamic>{
      //'fecha_accidente': Informe._dateTimeToTimestamp(instance.fechaAccidente),
      'fecha_accidente': dateTimeToTimestamp(instance.fechaAccidente),
      'descripcion': instance.descripcion,
      'aseguradora': instance.companyiaAseguradora,
      'lugar_accidente': instance.lugarAccidente,
      'paciente': instance.idPaciente,
      'tipo_accidente': instance.tipoAccidente.toString(),
      //'ficheros_adjuntos': instance.ficherosAdjuntos,
      'indemnizaciones':instance.indemnizaciones
};