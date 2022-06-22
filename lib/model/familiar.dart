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
enum ElOtroProgenitor { // Se aplica solo a hijos
  vive, muereEnElAccidente, yaMurio
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
  bool? discapacidad = false;
  double? incrementoDiscapacidad; // % de aumento (25%-75%) según el grado de discapacidad del familiar
  String? dni;
  bool? convivencia;
  ElOtroProgenitor? elOtroProgenitor = ElOtroProgenitor.vive;
  double? perjuicioExcepcional; // % de aumento (0%-25%) asignado de forma discrecional
  String? justificacionPerjuicioExcepcional; //explicación del aumento anterior

  double? multiplicadorLucroCesante; // .... Pasar a informe
  double? anyosLucroCesante; // ....  Pasar a informe


  Familiar({
      this.nombre,
      this.apellidos,
      this.parentesco,
      this.fechaNacimiento,
      this.fechaMatrimonio,
      this.incrementoDiscapacidad,
      this.dni,
      this.discapacidad = false,
      this.convivencia,
      this.elOtroProgenitor,
      this.perjuicioExcepcional,
      this.justificacionPerjuicioExcepcional
  });

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
    convivencia:convivencia,
    elOtroProgenitor: elOtroProgenitor,
    perjuicioExcepcional: perjuicioExcepcional,
    justificacionPerjuicioExcepcional: justificacionPerjuicioExcepcional
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
    elOtroProgenitor = null;
    perjuicioExcepcional = null;
    justificacionPerjuicioExcepcional = null;
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
          convivencia: json['convivencia'],
          elOtroProgenitor: enumfromString(ElOtroProgenitor.values, json['el_otro_progenitor']),
          perjuicioExcepcional: json['perjuicio_excepcional'],
          justificacionPerjuicioExcepcional: json['justificacion_perjuicio_excepcional']);
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
      'el_otro_progenitor':elOtroProgenitor.toString(),
      'perjuicio_excepcional':perjuicioExcepcional,
      'justificacion_perjuicio_excepcional':justificacionPerjuicioExcepcional
    };
    map.removeWhere((key, value) => value == null);
    map.removeWhere((key, value) => value == "null");
    return map;
  }

  //Se obtiene a parrir del documento "Manual para la aplicación de la Ley 35 version8.pptm"
  // https://drive.google.com/file/d/15wsEBHEt8LAMtAQONim3MIM13NgqsqLb/view?usp=sharing
  // desde la transparencia "Indemnizaciones por causa de muerte:"
  // hasta ""
  // el código sigue el mismo orden que las transparencias

  double calcularIndemnizacion(Informe informe, Paciente? victima ) {

    double importe = 0;
    DateTime? fechaAccidente = informe.fechaAccidente;
    List<Familiar> familiares = informe.familiares;
    // parametros necesarios para el calculo del importe
    if (parentesco == null || fechaAccidente == null || victima == null || victima.fechaNacimiento == null ||
        ([Parentesco.hijo,Parentesco.hermano].contains(parentesco) && fechaNacimiento == null) || // el hijo o el hermano necesitan fecha de nacimiento
        (Parentesco.conyuge == parentesco && fechaMatrimonio == null)) // el conyuge necesita fecha de matrimonio
    {
      return 0;
    }

    double anyosVictima = diferenciaAnyos(fechaAccidente, victima.fechaNacimiento!);
    double anyosFamiliar = 0;
    if(([Parentesco.hijo,Parentesco.hermano].contains(parentesco) && fechaNacimiento == null)){
      anyosFamiliar = diferenciaAnyos(fechaAccidente, fechaNacimiento!);
    }


    switch (parentesco) {
      case Parentesco.conyuge: // Transparencia: Cónyuge viudo
          if (fechaMatrimonio != null) {
            double anyosMatrimonio = diferenciaAnyos(
                fechaAccidente, fechaMatrimonio!);
            if (anyosVictima < 67) {
              importe = 90000;
            } else if (anyosVictima >= 67 && anyosVictima < 80) {
              importe = 70000;
            } else { // +80
              importe = 50000;
            }
            if (anyosMatrimonio > 15) {
              // por cada año y fraccionesde mas de 15 de matrimonio 1000 euros 
              importe += 1000 * (anyosMatrimonio - 15);
            }
          }
          break;
        case Parentesco.padre: // Transparencia: Los ascendientes
          if (anyosVictima <= 30) importe = 70000;
          else                    importe = 40000;
          break;
      case Parentesco.abuelo: // Transparencia: Los ascendientes
        importe = 20000;
        break;
      case Parentesco.hijo: // Transparencia: Los descendientes
          if (anyosFamiliar <= 14) {
            importe = 90000;
          } else if (anyosFamiliar > 14 && anyosFamiliar <= 20) {
            importe = 80000;
          } else if (anyosFamiliar > 20 && anyosFamiliar <= 30) {
            importe = 50000;
          } else {  // +30
            importe = 20000;
          }
          break;
      case Parentesco.nieto: // Transparencia: Los descendientes
        importe = 15000;
        break;
      case Parentesco.hermano: // Transparencia: Los hermanos
          if (anyosFamiliar <= 30) {
            importe = 20000;
          } else { // +30
            importe = 15000;
          }
          break;
        case Parentesco.allegado: // Transparencia: Los allegados
          importe = 10000;
          break;
        default:
    }
    // Transparencia: La discapacidad física, intelectual o sensorial del perjudicado
    if(incrementoDiscapacidad!=null && discapacidad!=null && discapacidad!
        && (incrementoDiscapacidad!>=25 && incrementoDiscapacidad!<=75)){
      importe += (incrementoDiscapacidad!/100)*importe;
    }
    // Transparencia: Convivencia
    if (convivencia != null && convivencia!) {
      switch (parentesco) {
        case Parentesco.padre:
          if (anyosVictima > 30) { // El hijo fallecido ha de tener más de 30 años
            importe += 30000;
          }
          break;
        case Parentesco.abuelo: // Transparencia: Los ascendientes
          importe += 10000;
          break;
        case Parentesco.hijo: // Transparencia: Los descendientes
          importe += 30000;
          break;
        case Parentesco.nieto: // Transparencia: Los descendientes
          importe += 7500;
          break;
        case Parentesco.hermano: // Transparencia: Los hermanos
          if (anyosFamiliar > 30) { // El hermano ha de tener más de 30 años
            importe += 5000;
          }
          break;
        default:
      }
    }
    // Transparencia: El duelo en soledad
    // si es hijo, padre o hemano unico +25%
    if ([Parentesco.hijo,Parentesco.padre,Parentesco.hermano].contains(parentesco)) {
      if (esParentescoUnico(this, familiares)) {
        importe += 0.25*importe;
      }
    }
    // si es el último familiar +25%
    if (familiares.length == 1) {
      importe += 0.25*importe;
    }
    // Transparencia: Fallecimiento de progenitor
    if (parentesco == Parentesco.hijo) {
      //Progenitor único
      if (elOtroProgenitor == ElOtroProgenitor.yaMurio)
        if (anyosFamiliar<=20) importe += 0.5*importe;
        else                   importe += 0.25*importe;
      //Fallecimiento de ambos progenitores
      if (elOtroProgenitor == ElOtroProgenitor.muereEnElAccidente)
        if (anyosFamiliar<=20) importe += 0.75*importe;
        else                   importe += 0.35*importe;
    }

    // Transparencia: Fallecimiento del hijo único
    if (parentesco == Parentesco.padre && esHijoUnico(familiares)) {
      importe += 0.25*importe;
    }

    // Transparencia: Fallecimiento víctima embarazada con pérdida de feto.
    if (parentesco == Parentesco.conyuge) {
      if (informe.embarazo== Embarazo.menosO12Semanas)  importe += 15000;
      if (informe.embarazo == Embarazo.mas12Semanas)    importe += 30000;
    }

    // Transparencia: Perjuicio excepcional

    if (perjuicioExcepcional != null && perjuicioExcepcional!<=25) {
      importe += (perjuicioExcepcional!/100)*importe;
    }
    // Transparencia: Daño emergente
       // "Cada perjudicado tiene derecho a percibir, sin necesidad de justificación, 400 euros"
       importe += 400;
       // "Por encima de los 400 euros los gastos también son compensados si el
       // perjudicado justifica debidamente su necesidad"
       // Estos gastos se añaden en la pestaña de gastos

    // Transparencia: Lucro Cesante
       // Habra que mirarlo
       // TODO: Calcular Lucro Cesante

    return importe; //NO hace falta  redondear2Decimales(importe);
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

  // comprueba si el familiar tiene parentesco unico (hermano, hijo, progenitor, etc...)
  bool esHijoUnico(List<Familiar> familia){
    for(Familiar f in familia){
      if(f.parentesco == Parentesco.hermano){
        return false; //Tiene un hermano
      }
    }
    return true; // es hijo unico
  }

  double redondear2Decimales(double a){
     // redondear a dos decimales
      String inString = a.toStringAsFixed(2); // 
      double valor = double.parse(inString); //
      return valor;
  }

}
