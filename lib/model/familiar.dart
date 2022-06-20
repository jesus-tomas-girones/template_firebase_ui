import 'package:firebase_ui/utils/enum_helpers.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/date_time_helpers.dart';
import '../widgets/editor_lista_objetos.dart';
import 'paciente.dart';

enum Parentesco { 
  hijo, padre, conyuge, nieto, abuelo,hermano,allegado
}

extension ParentescoExtension on Parentesco {
  String get name =>
      ["Hijo", "Padre", "Conyuge", "Nieto","Abuelo","Hermnao","Allegado"][this.index];
}

@JsonSerializable()
class Familiar implements ClonableVaciable {
  
  String? nombre;
  String? apellidos;
  Parentesco? parentesco;
  DateTime? fechaNacimiento;
  DateTime? fechaMatrimonio;
  double? incrementoDiscapacidad;
  String? dni;
  bool? discapacidad = false;

  Familiar({
      this.nombre,
      this.apellidos,
      this.parentesco,
      this.fechaNacimiento,
      this.fechaMatrimonio,
      this.incrementoDiscapacidad,
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
    fechaMatrimonio: fechaMatrimonio,
    incrementoDiscapacidad: incrementoDiscapacidad,
    dni: dni,
    discapacidad: discapacidad
  );

  vaciar() {
    nombre = null;
    apellidos = null;
    parentesco = null;
    fechaNacimiento = null;
    fechaMatrimonio = null;
    incrementoDiscapacidad = null;
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
          fechaMatrimonio: json['fecha_matrimonio'] == null
              ? null
              : timestampToDateTime(json['fecha_matrimonio'] as Timestamp),
          dni: json['dni'],
          incrementoDiscapacidad: json['incrementoDiscapacidad'],
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
      'fecha_matrimonio': fechaMatrimonio == null ? null : dateTimeToTimestamp(
          fechaMatrimonio!),
      'dni': dni,
      'incrementoDiscapacidad':incrementoDiscapacidad,
      'discapacidad': discapacidad,
    };
    map.removeWhere((key, value) => value == null);
    map.removeWhere((key, value) => value == "null");
    return map;
  }

  double calcularImporte(DateTime? fechaAccidente, Paciente? victima) {
    double importe = 0;
    double milisecondsToYears = 31536000000;

    if(fechaAccidente!=null && victima!=null && victima.fechaNacimiento!=null){
      
      double anyosVictima = (fechaAccidente.difference(victima.fechaNacimiento!)).inMilliseconds/milisecondsToYears;

      // calculo de conyuge
      switch (parentesco) {
        case Parentesco.conyuge:
          if(fechaMatrimonio!=null){ 
            double anyosMatrimonio = (fechaAccidente.difference(fechaMatrimonio!)).inMilliseconds/milisecondsToYears;

            if(anyosVictima < 67){
              importe+=90000;
            }else if(anyosVictima>=67 && anyosVictima<80){
              importe+=70000;
            }else{
              // +80
              importe+=50000;
            }

            if(anyosMatrimonio > 15){
              // por cada año y fraccionesde mas de 15 de matrimonio 1000 euros 
              double anyosDeMasMatrimonio =  anyosMatrimonio - 15;
              importe+= redondear2Decimales(1000*anyosDeMasMatrimonio);
            }
          }
          break;
        case Parentesco.padre:
          if(anyosVictima<=30){
            importe+=70000;
          }else{
            // +30
            importe+=40000;
          }
          break;
        case Parentesco.abuelo:
          importe+=20000;
          break;
        case Parentesco.nieto:
          importe+=15000;
          break;
        default:
      }
    }


    if(incrementoDiscapacidad!=null && discapacidad!=null && discapacidad!){
        
        importe += redondear2Decimales(importe*(incrementoDiscapacidad!/100));
    }

    return importe;

  }

  double redondear2Decimales(double a){
     // redondear a dos decimales
      String inString = a.toStringAsFixed(2); // 
      double valor = double.parse(inString); // 
      
      return valor;

  }

}
