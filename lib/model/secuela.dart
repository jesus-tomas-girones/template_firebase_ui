import 'package:firebase_ui/utils/enum_helpers.dart';
import 'package:json_annotation/json_annotation.dart';

import '../widgets/editor_lista_objetos.dart';

/// Una secula tiene una descrpción y un listado de tipos de secuela
/// Un tipo de secuela tiene - especialidad, secuela, nivel y puntos asignados por el médico
/// La siguiente tabla recoge las especialidades, secuelas, niveles y rango de puntos que se pueden asignar

const SECUELAS = {
  // los rangos indican [minimo, maximo]
  "oftalmologia": {
    "perdida de visión": {
      "5% - 20%": [2, 6],
      "20% - 60%": [4, 8],
    },
    "estravismo": {
      "nivel 1": [2, 6],
      "nivel 2": [4, 8],
      "nivel 3": [6, 10],
    },
  },
  "traumatología" : {
    "perdida de dedo": {
      "solo la puntita": [2, 4],
      "hasta la 1ª falange": [4, 8],
      "hasta la 2ª falange": [5, 8],
    },
    "perdida movilidad mano": {
      "nivel 1": [2, 6],
      "nivel 2": [4, 8],
      "nivel 3": [6, 10],
    },
  }
};

const SECUELAS_ALTERNATIVA = { // Los niveles son el índice
  "oftalmologia": {
    "perdida de visión": [
      [2, 6],
      [4, 8],
    ],
    "estravismo": [
      [2, 6],
      [4, 8],
      [6, 10],
    ],
  },
};

List<String> listaEspecialidades() {
  return SECUELAS.keys.toList();
}

List<String> listaSecuela(String especialidad) {
  if(SECUELAS[especialidad]!=null){
    print(SECUELAS[especialidad]!.keys.toList());
    return SECUELAS[especialidad]!.keys.toList();
  }else{
    return [];
  }
}

List<String> listaNiveles(String especialidad, String secuela) {
  if(SECUELAS[especialidad]!=null && SECUELAS[especialidad]![secuela]!=null){ 
    print(SECUELAS[especialidad]![secuela]!.keys.toList());
    return SECUELAS[especialidad]![secuela]!.keys.toList();
  }else{
    return [];
  }
}

List rangoPuntos(String especialidad, String secuela, String nivel) {
  return [4, 6]; //TODO obtener par de valores dinámicamente.
}

@JsonSerializable(explicitToJson: true) // Por tener clase anidada
class Secuela implements ClonableVaciable{
  String? descripcion;
  List<SecuelaTipo> secuelas;

  Secuela({ this.descripcion, List<SecuelaTipo>? secuelas }) : secuelas = secuelas ?? [];

  clone() => Secuela(
    descripcion: descripcion,
    secuelas: secuelas
  );

  vaciar() {
    descripcion = null;
    secuelas = [];
  }

  factory Secuela.fromJson(Map<String, dynamic> json) {
    try {
      return Secuela(
          descripcion: json['descripcion'],
          secuelas: json['secuelas'] != null ? (json['secuelas'] as List).map((secuela) => SecuelaTipo.fromJson(secuela)).toList() : <SecuelaTipo>[],
      );
    } catch (e) {
      print("Error en Secuelas.fromJson");
      print(e);
      return Secuela();
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'descripcion': descripcion,
      'secuelas': secuelas.map((e) => e.toJson()).toList()
    };
    map.removeWhere((key, value) => value == null);
    map.removeWhere((key, value) => value == "null");
    return map;
  }
}


@JsonSerializable()
class SecuelaTipo implements ClonableVaciable{
  String? especialidad;  //Especialidad médica
  String? secuela;       //Descripción de la secuela
  String? nivel;         //Cada tipo de secuela tienen varios niveles
  int puntos;           //puntos asignados por el périto. Para cada indice,nivel hay un rango posible.

  static List<String> listaEspecialidades() {
    return SECUELAS.keys.toList();
  }

  static List<String> listaSecuela(String especialidad) {
    if(SECUELAS[especialidad]!=null){
      return SECUELAS[especialidad]!.keys.toList();
    }else{
      return [];
    }
  }

  static List<String> listaNiveles(String especialidad, String secuela) {
    if(SECUELAS[especialidad]!=null && SECUELAS[especialidad]![secuela]!=null){
      return SECUELAS[especialidad]![secuela]!.keys.toList();
    }else{
      return [];
    }
  }

  static List<int> rangoPuntos(String? especialidad, String? secuela, String? nivel) {
    if(SECUELAS[especialidad]!=null && SECUELAS[especialidad]![secuela]!=null && SECUELAS[especialidad]![secuela]![nivel]!=null){
      return SECUELAS[especialidad]![secuela]![nivel]!.toList();
    }else{
      return [];
    }
  }

  SecuelaTipo({ this.especialidad, this.secuela, this.nivel, this.puntos = 0 });

  factory SecuelaTipo.fromJson(Map<String, dynamic> json) {
    try {
      return SecuelaTipo(
        especialidad: json['especialidad'],
        secuela: json['secuela'],
        nivel: json['nivel'],
        puntos: json['puntos'],
      );
    } catch (e) {
      print("Error en SecuelasTipo.fromJson");
      print(e);
      return SecuelaTipo();
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'especialidad': especialidad,
      'secuela': secuela,
      'nivel': nivel,
      'puntos': puntos,
    };
    map.removeWhere((key, value) => value == null);
    map.removeWhere((key, value) => value == "null");
    return map;
  }

   @override
  clone() => SecuelaTipo(
    especialidad: especialidad,
    nivel: nivel,
    puntos: puntos,
    secuela: secuela
  );

  @override
  vaciar() {
    especialidad = null;
    nivel = null;
    puntos = 0;
    secuela = null;
  }
}
