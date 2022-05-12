import 'package:firebase_ui/utils/enum_helpers.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/date_time_helpers.dart';
import 'familiar.dart';
import 'secuela.dart';

enum TipoAccidente{
  Trafico, Laboral, Deportivo,  ViaPublica }

extension TipoAccidenteExtension on TipoAccidente {
  /*String get value_borrar {
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
    }*/
  String get value2 {
    try {
      return ["Trafico", "Laboral", "Deportivo", "Via publica"][this.index];
    } finally {
      return "sin valor";
    }
  }

  String get value =>
      ["Trafico", "Laboral", "Deportivo", "Via publica"][this.index];
}

///
/// Clase que representa un informe
///
@JsonSerializable(explicitToJson: true) // Por tener clase anidada
class Informe {
  @JsonKey(ignore: true)
  String? id;

  // Datos generales
  DateTime? fechaAccidente; // no existe long en dart
  String descripcion = "";
  String? lugarAccidente;
  TipoAccidente? tipoAccidente;
  String? companyiaAseguradora;
  String? idPaciente;
  // Se accede a los ficheros por subcolección de Firebase

  //Indemnizaciones por muerte
  bool hayMuerte = false;
  List<Familiar> familiares = [];
  bool embarazada = false; //La fallecida estaba embarazada
  //Indemnizaciones por lesiones temporales
  bool hayLesion = false;
  String? lesiones; // Descripción de las lesiones temporales
  int diasUci = 0; //Días de ingreso en UCI   -  muy grave
  int diasPlanta = 0; //Días de ingreso en hospital en planta  -  grave
  int diasBaja = 0; //Dias de baja laboral      -  moderado
  int diasPerjuicio = 0;

  //Indemnizaciones por secuelas
  bool haySecuela = false;
  List<Secuela> secuelas = [];

  // Se accede a los gastos en subcolección de Firebase

  Informe({
    this.fechaAccidente,
    this.descripcion = "",
    this.lugarAccidente,
    this.tipoAccidente,
    this.companyiaAseguradora,
    this.idPaciente,
    this.hayMuerte = false,
    this.familiares = const [],
    this.embarazada = false,
    this.hayLesion = false,
    this.lesiones,
    this.diasUci = 0,
    this.diasPlanta = 0,
    this.diasBaja = 0,
    this.diasPerjuicio = 0,
    this.haySecuela = false,
    this.secuelas = const [],
  });

  clone() =>
      Informe(
          fechaAccidente: fechaAccidente,
          descripcion: descripcion,
          lugarAccidente: lugarAccidente,
          companyiaAseguradora: companyiaAseguradora,
          idPaciente: idPaciente,
          tipoAccidente: tipoAccidente,
          hayMuerte: hayMuerte,
          familiares: familiares,
          embarazada: embarazada,
          hayLesion: hayLesion,
          lesiones: lesiones,
          diasUci: diasUci,
          diasPlanta: diasPlanta,
          diasBaja: diasBaja,
          diasPerjuicio: diasPerjuicio,
          haySecuela: haySecuela,
          secuelas: secuelas
      )..id = id;

  // esto seria el equivalente de hacer un setId despues de hacer la instancia, no se pone en el constructor para evitar problemas

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Informe{fechaAccidente: $fechaAccidente, descripcion: $descripcion, tipoAccidente: $tipoAccidente}';

  @override
  bool operator ==(Object other) => // NO se compara el id.
  identical(this, other) ||
      other is Informe &&
          runtimeType == other.runtimeType &&
          fechaAccidente == other.fechaAccidente &&
          descripcion == other.descripcion &&
          lugarAccidente == other.lugarAccidente &&
          idPaciente == other.idPaciente &&
          tipoAccidente == other.tipoAccidente &&
          hayMuerte == other.hayMuerte &&
          familiares == other.familiares &&
          embarazada == other.embarazada &&
          hayLesion == other.hayLesion &&
          lesiones == other.lesiones &&
          diasUci == other.diasUci &&
          diasPlanta == other.diasPlanta &&
          diasBaja == other.diasBaja &&
          diasPerjuicio == other.diasPerjuicio &&
          haySecuela == other.haySecuela &&
          secuelas == other.secuelas;

  factory Informe.fromJson(Map<String, dynamic> json) {
    try {
      return Informe(
          fechaAccidente: json['fecha_accidente'] == null
              ? null
              : timestampToDateTime(json['fecha_accidente'] as Timestamp),
          descripcion: json['descripcion'],
          companyiaAseguradora: json['aseguradora'],
          lugarAccidente: json['lugar_accidente'],
          idPaciente: json["paciente"],
          tipoAccidente: enumfromString(
              TipoAccidente.values, json["tipo_accidente"]),
          hayMuerte: json['hayMuerte'] ?? false,
          familiares: json['familiares'] ?? <Familiar>[],
          embarazada: json['embarazada'] ?? false,
          hayLesion: json['hayLesion'] ?? false,
          lesiones: json['lesiones'],
          diasUci: json['diasUci'] ?? 0,
          diasPlanta: json['diasPlanta'] ?? 0,
          diasBaja: json['diasBaja'] ?? 0,
          diasPerjuicio: json['diasPerjuicio'] ?? 0,
          haySecuela: json['haySecuela'] ?? false,
          secuelas: json['secuelas'] ?? <Secuela>[]
      );
    } catch (e) {
      print("Error en Informe.fromJson");
      print(e);
      return Informe();
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
        'fecha_accidente': dateTimeToTimestamp(fechaAccidente),
        'descripcion': descripcion,
        'aseguradora': companyiaAseguradora,
        'lugar_accidente': lugarAccidente,
        'paciente': idPaciente,
        'tipo_accidente': tipoAccidente.toString(),
        'hayMuerte': hayMuerte,
        'familiares': familiares,
        'embarazada': embarazada,
        'hayLesion': hayLesion,
        'lesiones': lesiones,
        'diasUci': diasUci,
        'diasPlanta': diasPlanta,
        'diasBaja': diasBaja,
        'diasPerjuicio': diasPerjuicio,
        'haySecuela': haySecuela,
        'secuelas': secuelas
      };
    map.removeWhere((key, value) => value == null);
    map.removeWhere((key, value) => value == "null");
    return map;
  }
}