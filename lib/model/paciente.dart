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

  clone() =>
      Paciente(
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
      )
        ..id = id;

  @override
  bool operator == (Object other) => // NO se compara el id.
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
    try {
      return Paciente(
        nombre: json['nombre'],
        apellidos: json['apellidos'],
        fechaNacimiento: json['fecha_nacimiento'] == null
            ? null
            : timestampToDateTime(json['fecha_nacimiento'] as Timestamp),
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
    } catch (e) {
      print("Error en Paciente.fromJson");
      print(e);
      return Paciente();
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'nombre': nombre,
      'apellidos': apellidos,
      'fecha_nacimiento': fechaNacimiento == null ? null : dateTimeToTimestamp(
          fechaNacimiento!),
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
    map.removeWhere((key, value) => value == null);
    map.removeWhere((key, value) => value == "null");
    return map;
  }

  // Funcion que devuelve el paciente con el ese id asociado
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
