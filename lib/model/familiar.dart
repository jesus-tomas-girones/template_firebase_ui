import 'package:firebase_ui/utils/enum_helpers.dart';
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

  Familiar(this.nombre, this.apellidos, this.parentesco, this.fechaNacimiento,
      this.dni, this.discapacidad);

  //TODO terinarclase
}

