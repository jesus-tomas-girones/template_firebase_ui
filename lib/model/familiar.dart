import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/date_time_helpers.dart';

enum Parentesco { hijo, padre, conyuge, parejaHecho, divorciado }

@JsonSerializable()
class Familiar {
  String? nombre;
  String? apellidos;
  Parentesco? parentesco;
  DateTime? fechaNacimiento;
  String? dni;
  bool discapacidad = false;

  Familiar({
      this.nombre,
      this.apellidos,
      this.parentesco,
      this.fechaNacimiento,
      this.dni,
      this.discapacidad = false });

  // clone() =>
  // operator ==    ¿Hace falta?

  factory Familiar.fromJson(Map<String, dynamic> json) {
    try {
      return Familiar(
          nombre: json['nombre'],
          apellidos: json['apellidos'],
          parentesco: json['parentesco'],
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
