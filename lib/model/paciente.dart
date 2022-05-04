import 'package:firebase_ui/utils/enum_helpers.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/date_time_helpers.dart';

enum Sexo{
  hombre, mujer
}
enum NivelFormacion {
  analfabeto, primaria, bachillerato, formacionProfesional, graduadoUniversitario, doctorado
}
enum SituacionLaboral {
  activo, desempleado, jubilado, estudiante, hogar, otros
}

@JsonSerializable()
class Paciente {
  @JsonKey(ignore: true)
  String? id;
  String? nombre;
  String? apellidos;
  DateTime? fechaNacimiento;
  Sexo? sexo;
  String? domicilio;
  String? telefono;
  String? dni;
  String? nuss; //número seguridad social
  NivelFormacion? nivelFormacion;
  String? antecedentesMedicos;
  SituacionLaboral? situacionLaboral;
  String? ocupacion;
  String? empresa;

  Paciente({
    this.nombre,
    this.apellidos,
    this.fechaNacimiento,
    this.sexo,
    this.domicilio,
    this.telefono,
    this.dni,
    this.nuss,
    this.nivelFormacion,
    this.antecedentesMedicos,
    this.situacionLaboral,
    this.ocupacion,
    this.empresa,
  });

  clone() => Paciente(  //TODO Explicar por que no se copia el id. No lo entiendo
    nombre: nombre,
    apellidos: apellidos,
    fechaNacimiento: fechaNacimiento,
    sexo: sexo,
    domicilio: domicilio,
    telefono: telefono,
    dni: dni,
    nuss: nuss,
    nivelFormacion: nivelFormacion,
    antecedentesMedicos: antecedentesMedicos,
    situacionLaboral: situacionLaboral,
    ocupacion: ocupacion,
    empresa: empresa,
  );

  @override
  bool operator ==(Object other) =>   // NO se compara el id.
      identical(this, other) ||
      other is Paciente &&
          runtimeType == other.runtimeType &&
          nombre == other.nombre &&
          apellidos == other.apellidos &&
          fechaNacimiento == other.fechaNacimiento &&
          sexo == other.sexo &&
          domicilio == other.domicilio &&
          telefono == other.telefono &&
          dni == other.dni &&
          nuss == other.nuss &&
          nivelFormacion == other.nivelFormacion &&
          antecedentesMedicos == other.antecedentesMedicos &&
          situacionLaboral == other.situacionLaboral &&
          ocupacion == other.ocupacion &&
          empresa == other.empresa;

  @override
  String toString() => (nombre ?? "") + " " + (apellidos ?? "");


  factory Paciente.fromJson(Map<String, dynamic> json){
    try{
      return  Paciente(
        nombre: json['nombre'],
        apellidos: json['apellidos'],
        fechaNacimiento: json['fecha_nacimiento'] == null ? null :
        timestampToDateTime(json['fecha_nacimiento'] as Timestamp),
        sexo: enumfromString(Sexo.values, json['sexo']),
        domicilio: json['domicilio'],
        telefono: json['telefono'],
        dni: json['dni'],
        nuss: json['nuss'],
        nivelFormacion: json['nivel_formacion'],
        antecedentesMedicos: json['antecedentes_medicos'],
        situacionLaboral: json['situacion_laboral'],
        ocupacion: json['ocupacion'],
        empresa: json['empresa'],
      );
    }catch(e){
      print("Error on paciente");
      print(e);
      return Paciente();
    }

  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'nombre': nombre,
      'apellidos': apellidos,
      'fecha_nacimiento': fechaNacimiento == null ? null : dateTimeToTimestamp(fechaNacimiento!),
      'sexo': sexo.toString(),
      'domicilio': domicilio,
      'telefono': telefono,
      'dni': dni,
      'nuss': nuss,
      'nivel_formacion': nivelFormacion.toString(),
      'antecedentes_medicos': antecedentesMedicos,
      'situacion_laboral': situacionLaboral.toString(),
      'ocupacion': ocupacion,
      'empresa': empresa,
    };
    map.removeWhere((key, value) => value==null);
    map.removeWhere((key, value) => value=="null");
    return map;
  }


  //TODO: Quitar hasta el final
  static List<Paciente> mockListaPacientes() {
    Paciente p = Paciente(
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
          empresa: "1")..id = "1";
    Paciente p2 = Paciente(
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
          empresa: "1")..id = "2";
    Paciente p3 = Paciente(
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
          empresa: "1")..id = "3";
    return [
      p,
      p2,
      p3,
      p3..id = "4",
      p3..id = "5",
      p3..id = "6",
      p3..id = "7",
      p3..id = "8",
      p3..id = "9",
      p3..id = "10",
      p3..id = "11",
      p3..id = "12",
      p3..id = "13",
      p3..id = "14",
      p3..id = "15",
      p3..id = "16",
      p3..id = "17",
      p3..id = "18",
      p3..id = "19",
    ];
  }

  ///
  /// Funcion que devuelve el paciente con el ese id asociado
  ///
  static Paciente? findPacienteById(List<Paciente>? pacientes, id) {
    if (pacientes != null) {
      for (Paciente p in pacientes) {
        if (p.id == id) {
          return p;
        }
      }
    }
    return null;
  }
}

/*Paciente _$PacienteFromJson(Map<String, dynamic> json) =>
  //dynamic getIfExist(String s) => json[s] == null ? null : json[s];

  Paciente(
    nombre: json['nombre'],
    apellidos: json['apellidos'],
    fechaNacimiento: json['fecha_nacimiento'] == null ? null :
             timestampToDateTime(json['fecha_nacimiento'] as Timestamp),
    sexo: json['sexo'],
    domicilio: json['domicilio'],
    telefono: json['telefono'],
    dni: json['dni'],
    nuss: json['nuss'],
    nivelFormacion: json['nivel_formacion'],
    antecedentesMedicos: json['antecedentes_medicos'],
    situacionLaboral: json['situacion_laboral'],
    ocupacion: json['ocupacion'],
    empresa: json['empresa'],
  );

Map<String, dynamic> _$PacienteToJson(Paciente instance) {
  Map<String, dynamic> map = {
    'nombre': instance.nombre,
    'apellidos': instance.apellidos,
    'fecha_nacimiento': instance.fechaNacimiento == null ? null :
        dateTimeToTimestamp(instance.fechaNacimiento!),
    'sexo': instance.sexo.toString(),
    'domicilio': instance.domicilio,
    'telefono': instance.telefono,
    'dni': instance.dni,
    'nuss': instance.nuss,
    'nivel_formacion': instance.nivelFormacion.toString(),
    'antecedentes_medicos': instance.antecedentesMedicos,
    'situacion_laboral': instance.situacionLaboral.toString(),
    'ocupacion': instance.ocupacion,
    'empresa': instance.empresa,
  };
  map.removeWhere((key, value) => value==null);
  map.removeWhere((key, value) => value=="null");
  return map;
}

Map<String, dynamic> __$PacienteToJson(Paciente instance) => <String, dynamic>{
      //String? putIf(String s) => s == null ? null : s;

      'nombre': instance.nombre,
      'apellidos': instance.apellidos,
      'fecha_nacimiento':
          dateTimeToTimestamp(instance.fechaNacimiento ?? DateTime.now()),
      'sexo': instance.sexo.toString(),
      'domicilio': instance.domicilio,
      'telefono': instance.telefono,
      'dni': instance.dni,
      'nuss': instance.nuss,
      'nivel_formacion': instance.nivelFormacion.toString(),
      'antecedentes_medicos': instance.antecedentesMedicos,
      'situacion_laboral': instance.situacionLaboral.toString(),
      'ocupacion': instance.ocupacion,
      'empresa': instance.empresa,
    };*/
