import 'package:firebase_ui/utils/enum_helpers.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/date_time_helpers.dart';
import '../widgets/editor_lista_objetos.dart';

enum Parentesco { 
  
  hijo, padre, conyuge, parejaHecho, divorciado

  //String toString() => "a"
}

extension ParentescoExtension on Parentesco {

  
  String get name =>
      ["Hijo", "Padre", "Conyuge", "Pareja de hecho","Divorciado"][this.index];
}


@JsonSerializable()
class Familiar implements ClonableVaciable {
  String? nombre;
  String? apellidos;
  Parentesco? parentesco;
  DateTime? fechaNacimiento;
  String? dni;
  bool? discapacidad = false;

  Familiar({
      this.nombre,
      this.apellidos,
      this.parentesco,
      this.fechaNacimiento,
      this.dni,
      this.discapacidad = false });

  @override
  String toString(){
    return {nombre, apellidos, parentesco, fechaNacimiento,
      dni, discapacidad}.toString();
  }


  clone() => Familiar(
    nombre: nombre,
    apellidos: apellidos,
    parentesco: parentesco,
    fechaNacimiento: fechaNacimiento,
    dni: dni,
    discapacidad: discapacidad
  );

 
  vaciar() {
    nombre = null;
    apellidos = null;
    parentesco = null;
    fechaNacimiento = null;
    dni = null;
    discapacidad = null;
  }

  factory Familiar.fromJson(Map<String, dynamic> json) {
    try {
      return Familiar(
          nombre: json['nombre'],
          apellidos: json['apellidos'],
          parentesco: enumfromString(Parentesco.values, json['parentesco']),
          fechaNacimiento: json['fecha_nacimiento'] == null
              ? null
              : timestampToDateTime(json['fecha_nacimiento'] as Timestamp),
          dni: json['dni'],
          discapacidad: json['discapacidad']);
    } catch (e) {
      print("Error en Paciente.fromJson");
      print(e);
      return Familiar();
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'nombre': nombre,
      'apellidos': apellidos,
      'parentesco': parentesco.toString(),
      'fecha_nacimiento': fechaNacimiento == null ? null : dateTimeToTimestamp(
          fechaNacimiento!),
      'dni': dni,
      'discapacidad': discapacidad,
    };
    map.removeWhere((key, value) => value == null);
    map.removeWhere((key, value) => value == "null");
    return map;
  }

}
