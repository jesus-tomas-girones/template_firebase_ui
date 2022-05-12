import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(explicitToJson: true) // Por tener clase anidada
class Secuela {
  String? descripcion;
  List<SecuelaTipo> secuelas;

  Secuela({ this.descripcion, this.secuelas = const [] });

  factory Secuela.fromJson(Map<String, dynamic> json) {
    try {
      return Secuela(
          descripcion: json['descripcion'],
          secuelas: json['secuelas'],
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
      'secuelas': secuelas,
    };
    map.removeWhere((key, value) => value == null);
    map.removeWhere((key, value) => value == "null");
    return map;
  }
}

@JsonSerializable()
class SecuelaTipo {
  int? indice;   //Índice en la tabla de seculas
  int? nivel;    //Cada tipo de secuela tienen varios niveles
  int? puntos;   //puntos asignados por el périto. Para cada indice,nivel hay un rango posible.

  SecuelaTipo({this.indice, this.nivel, this.puntos});

  factory SecuelaTipo.fromJson(Map<String, dynamic> json) {
    try {
      return SecuelaTipo(
        indice: json['indice'],
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
      'indice': indice,
      'nivel': nivel,
      'puntos': puntos,
    };
    map.removeWhere((key, value) => value == null);
    map.removeWhere((key, value) => value == "null");
    return map;
  }
}
