import 'package:firebase_ui/utils/enum_helpers.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/date_time_helpers.dart';
import 'familiar.dart';
import 'secuela.dart';

enum TipoAccidente{
  Trafico, Laboral, Deportivo,  ViaPublica, Incapacidad }

extension TipoAccidenteExtension on TipoAccidente {
  String get value2 {
    try {
      return ["Trafico", "Laboral", "Deportivo", "Via publica","Incapacidad sobrevenida"][this.index];
    } finally {
      return "sin valor";
    }
  }

  String get value =>
      ["Trafico", "Laboral", "Deportivo", "Via publica","Incapacidad sobrevenida"][this.index];
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
  String titulo = "";
  String? descripcion = "";
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
  double lucroCesante = 0;

  //Indemnizaciones por secuelas
  bool haySecuela = false;
  List<Secuela> secuelas = [];

  //Parámetros de cálculo económico
  double _diasUciEuros = 100;
  double _diasPlantaEuros = 75; //Días de ingreso en hospital en planta  -  grave
  double _diasBajaEuros = 52; //Dias de baja laboral      -  moderado
  double _diasPerjuicioEuros = 30;


  // Se accede a los gastos en subcolección de Firebase

  Informe({
    this.fechaAccidente,
    this.descripcion = "",
    this.titulo = "",
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
    this.lucroCesante = 0,
    this.haySecuela = false,
    this.secuelas = const [],
  });

  clone() =>
      Informe(
          fechaAccidente: fechaAccidente,
          descripcion: descripcion,
          titulo: titulo,
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
          lucroCesante : lucroCesante,
          haySecuela: haySecuela,
          secuelas: secuelas
      )..id = id;// esto seria el equivalente de hacer un setId despues de hacer la instancia, no se pone en el constructor para evitar problemas

  /// 
  /// Calcula el importe de la indemnizacion de las secuelas
  ///
  double calcularPuntosSecuelas(){
 
      double puntos = 0;
      for(Secuela s in secuelas){
        for(SecuelaTipo st in s.secuelas){

          puntos+=st.puntos;

        }
      }

      return puntos;
  
  }

  /// 
  /// Calcula el importe de la indemnizacion de las lesiones temporales
  ///
  double calcularImporteIndemnizacionesLesiones(){
    return  diasBaja*_diasBajaEuros+
            diasPerjuicio*_diasPerjuicioEuros+
            diasPlanta*_diasPlantaEuros+
            diasUci*_diasUciEuros+
            lucroCesante;
  }

  /// 
  /// Calcula el importe de la indemnizacion de la muerte
  ///
  double calcularImporteIndemnizacionesMuerte(){
    double importe = 0;
    for(Familiar f in familiares){
      //importe+= f.calcularImporte(fechaAccidente!, paciente);
    }
    return importe;
  }

  double obtenerImporteTotalIndemnizacion(){
    if(hayMuerte){
      return calcularImporteIndemnizacionesMuerte();
    }

    double importe = 0;

    if(hayLesion){
      importe+= calcularImporteIndemnizacionesLesiones();
    }

    if(haySecuela){
      importe+= calcularPuntosSecuelas();
    }

    return importe;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Informe{fechaAccidente: $fechaAccidente, titulo: $titulo, tipoAccidente: $tipoAccidente}';

  @override
  bool operator ==(Object other) => // NO se compara el id.
  identical(this, other) ||
      other is Informe &&
          runtimeType == other.runtimeType &&
          fechaAccidente == other.fechaAccidente &&
          descripcion == other.descripcion &&
          titulo == other.titulo &&
          lucroCesante  == other.lucroCesante &&
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
          titulo: json['titulo'],
          descripcion: json['descripcion'],
          companyiaAseguradora: json['aseguradora'],
          lugarAccidente: json['lugar_accidente'],
          idPaciente: json["paciente"],
          tipoAccidente: enumfromString(
              TipoAccidente.values, json["tipo_accidente"]),
          hayMuerte: json['hayMuerte'] ?? false,
          familiares: json['familiares']!=null ? (json['familiares'] as List).map((item) => Familiar.fromJson(item)).toList() : <Familiar>[],
          embarazada: json['embarazada'] ?? false,
          hayLesion: json['hayLesion'] ?? false,
          lesiones: json['lesiones'],
          diasUci: json['diasUci'] ?? 0,
          diasPlanta: json['diasPlanta'] ?? 0,
          diasBaja: json['diasBaja'] ?? 0,
          lucroCesante: json['lucroCesante ']??0,
          diasPerjuicio: json['diasPerjuicio'] ?? 0,
          haySecuela: json['haySecuela'] ?? false,
          secuelas: json['secuelas']!=null ? (json['secuelas'] as List).map((item) => Secuela.fromJson(item)).toList() : <Secuela>[],
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
        'titulo': titulo,
        'descripcion': descripcion,
        'aseguradora': companyiaAseguradora,
        'lugar_accidente': lugarAccidente,
        'paciente': idPaciente,
        'tipo_accidente': tipoAccidente.toString(),
        'hayMuerte': hayMuerte,
        'familiares': familiares.map((i) => i.toJson()).toList(),
        'embarazada': embarazada,
        'hayLesion': hayLesion,
        'lesiones': lesiones,
        'diasUci': diasUci,
        'lucroCesante ': lucroCesante,
        'diasPlanta': diasPlanta,
        'diasBaja': diasBaja,
        'diasPerjuicio': diasPerjuicio,
        'haySecuela': haySecuela,
        'secuelas': secuelas.map((i) => i.toJson()).toList()
      };
    map.removeWhere((key, value) => value == null);
//    map.removeWhere((key, value) => value == []);
    map.removeWhere((key, value) => value == "null");
    print(map);
    return map;
  }
}