import 'package:firebase_ui/utils/enum_helpers.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/date_time_helpers.dart';
import '../widgets/editor_lista_objetos.dart';
import 'informe.dart';
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
  bool? convivencia;

  Familiar({
      this.nombre,
      this.apellidos,
      this.parentesco,
      this.fechaNacimiento,
      this.fechaMatrimonio,
      this.incrementoDiscapacidad,
      this.dni,
      this.discapacidad = false,
      this.convivencia, });

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
    discapacidad: discapacidad,
    convivencia:convivencia
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
    convivencia = null;
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
          discapacidad: json['discapacidad'],
          convivencia: json['convivencia']);
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
      'convivencia':convivencia,
    };
    map.removeWhere((key, value) => value == null);
    map.removeWhere((key, value) => value == "null");
    return map;
  }

  double calcularImporte(Informe informe, Paciente? victima) {
    double importe = 0;
    
    DateTime? fechaAccidente = informe.fechaAccidente;
    List<Familiar> familiares = informe.familiares;

    if(parentesco!=null &&fechaAccidente!=null && victima!=null && victima.fechaNacimiento!=null){
      
      double anyosVictima = diferenciaAnyos(fechaAccidente,victima.fechaNacimiento!);

      // calculo de conyuge
      switch (parentesco) {
        case Parentesco.conyuge:
          if(fechaMatrimonio!=null){ 
            double anyosMatrimonio = diferenciaAnyos(fechaAccidente,fechaMatrimonio!);

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
            convivencia = false;
          }else{
            // +30
            importe+=40000;
            // si vivia con su hijo de mas de 30 años mas 30k
            if(convivencia!=null && convivencia!){
              importe+=30000;
            }
          }

          /*if(esParentescoUnico(this, familiares)){
            // si es padre unico +25%
            importe += redondear2Decimales(importe*(25/100));
          }*/
          break;
        case Parentesco.hijo:
          double anyosHijo = diferenciaAnyos(fechaAccidente,fechaNacimiento!);

          if(anyosHijo<=14){
            importe+=90000;
          }else if(anyosHijo>14 && anyosHijo<=20){
            importe+=80000;
          }else if(anyosHijo>20 && anyosHijo<=30){
            importe+=50000;
          }else{
            // +30
            importe+=20000;
            // si vivia con su padre con mas de 30 años +30k
            if(convivencia!=null && convivencia!){
              importe+=30000;
            }
          }

          /*if(esParentescoUnico(this, familiares)){
            // si es hijo unico +25%
            importe += redondear2Decimales(importe*(25/100));
          }*/

          break;
        case Parentesco.hermano:
          double anyoHermnao = diferenciaAnyos(fechaAccidente,fechaNacimiento!);
          if(anyoHermnao<=30){
            importe+=20000;
          }else{
            // +30
            importe+=15000;
            // si vivia con su hermano con mas de 30 años +5k
            if(convivencia!=null && convivencia!){
              importe+=5000;
            }
          }
          /*if(esParentescoUnico(this, familiares)){
            // si es hemano unico +25%
            importe += redondear2Decimales(importe*(25/100));
          }*/
          break;
        case Parentesco.abuelo:
          importe+=20000;

          if(convivencia!=null && convivencia!){
              importe+=10000;
          }

          /*if(esParentescoUnico(this, familiares)){
            // si es progenitor unico +25%
            importe += redondear2Decimales(importe*(25/100));
          }*/
          break;
        case Parentesco.nieto:
          importe+=15000;
          if(convivencia!=null && convivencia!){
              importe+=7500;
          }
          break;
        case Parentesco.allegado:
          importe+=10000;
          break;
        default:
      }
    }

    // discapacidad
    if(incrementoDiscapacidad!=null && discapacidad!=null && discapacidad!){
        
        importe += redondear2Decimales(importe*(incrementoDiscapacidad!/100));
    }

    return importe;

  }

  // comprueba si el familiar tiene parentesco unico (hermano, hijo, progenitor, etc...)
  bool esParentescoUnico(Familiar familiar, List<Familiar> familia){
    
    int cont = 0;
    for(Familiar f in familia){
      if(f.parentesco == familiar.parentesco){
        cont++;
      }
    }

    return cont==1;// es unico cuando hay un, que es él
  }
  double redondear2Decimales(double a){
     // redondear a dos decimales
      String inString = a.toStringAsFixed(2); // 
      double valor = double.parse(inString); // 
      
      return valor;

  }

}
