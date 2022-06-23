import 'package:firebase_ui/utils/enum_helpers.dart';
import 'package:firebase_ui/utils/numero_helper.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/date_time_helpers.dart';
import 'familiar.dart';
import 'gasto.dart';
import 'paciente.dart';
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

// embarazo con perdida de feto
enum Embarazo {
  no, mas12Semanas, menosO12Semanas
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
  Embarazo embarazo = Embarazo.no; //Si la fallecida estaba embarazada con perdida de feto, el cónyuge cobra un plus en función de las semanas
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


  // Gastos
  List<Gasto> gastos = [];

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
    this.embarazo = Embarazo.no,
    this.hayLesion = false,
    this.lesiones,
    this.diasUci = 0,
    this.diasPlanta = 0,
    this.diasBaja = 0,
    this.diasPerjuicio = 0,
    this.lucroCesante = 0,
    this.haySecuela = false,
    this.secuelas = const [],
    this.gastos = const []
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
          embarazo: embarazo,
          hayLesion: hayLesion,
          lesiones: lesiones,
          diasUci: diasUci,
          diasPlanta: diasPlanta,
          diasBaja: diasBaja,
          diasPerjuicio: diasPerjuicio,
          lucroCesante : lucroCesante,
          haySecuela: haySecuela,
          secuelas: secuelas,
          gastos: gastos
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
  double calcularImporteIndemnizacionesMuerte(Paciente? victima){
    double importe = 0;
    if(victima!=null){
      for(Familiar f in familiares){
        importe+= f.calcularIndemnizacion(this, victima);
      }
    }

    if(embarazo==Embarazo.mas12Semanas){
      importe+=30000;
    }else if(embarazo == Embarazo.menosO12Semanas){
      importe+=15000;
    }

    return importe;
  }

  double calcularTotalGastos() {
    double importe = 0;
      for(Gasto g in gastos){
        importe+= g.importe;
      }
    
    return importe;
  }

  /*double obtenerImporteTotalIndemnizacion(){
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
  }*/

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
          embarazo == other.embarazo &&
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
          tipoAccidente: enumfromString(TipoAccidente.values, json["tipo_accidente"]),
          hayMuerte: json['hayMuerte'] ?? false,
          familiares: json['familiares']!=null ? (json['familiares'] as List).map((item) => Familiar.fromJson(item)).toList() : <Familiar>[],
          embarazo:  enumfromString(Embarazo.values, json["embarazo"]),
          hayLesion: json['hayLesion'] ?? false,
          lesiones: json['lesiones'],
          diasUci: json['diasUci'] ?? 0,
          diasPlanta: json['diasPlanta'] ?? 0,
          diasBaja: json['diasBaja'] ?? 0,
          lucroCesante: json['lucroCesante ']??0,
          diasPerjuicio: json['diasPerjuicio'] ?? 0,
          haySecuela: json['haySecuela'] ?? false,
          secuelas: json['secuelas']!=null ? (json['secuelas'] as List).map((item) => Secuela.fromJson(item)).toList() : <Secuela>[],
          gastos: json['gastos']!=null ? (json['gastos'] as List).map((item) => Gasto.fromJson(item)).toList() : <Gasto>[],
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
        'embarazo': embarazo.toString(),
        'hayLesion': hayLesion,
        'lesiones': lesiones,
        'diasUci': diasUci,
        'lucroCesante ': lucroCesante,
        'diasPlanta': diasPlanta,
        'diasBaja': diasBaja,
        'diasPerjuicio': diasPerjuicio,
        'haySecuela': haySecuela,
        'secuelas': secuelas.map((i) => i.toJson()).toList(),
        'gastos': gastos.map((i)=>i.toJson()).toList()
      };
    map.removeWhere((key, value) => value == null);
//    map.removeWhere((key, value) => value == []);
    map.removeWhere((key, value) => value == "null");
    print(map);
    return map;
  }

  ///
  /// Funcion que ordena una lista de informes por el nombre de sus pacientes
  ///
  static ordenarPorPaciente(List<Informe>? data,List<Paciente>? pacientes) {
    

    if(data == null){
      return null;
    }

    data.sort((i1,i2){
      Paciente? p1 = Paciente.findPacienteById(pacientes, i1.idPaciente);
      Paciente? p2 = Paciente.findPacienteById(pacientes, i2.idPaciente);
      

      if( p1==null && p2==null){
        return 0;
      }
      if(p1==null){
        return 1;
      }
      if(p2 ==null){
        return -1;
      }
      
      return p1.nombre!.compareTo(p2.nombre!);

    });

  }

}