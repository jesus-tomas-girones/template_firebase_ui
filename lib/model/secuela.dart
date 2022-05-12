import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class SecuelaTipo {
  int? indice;   //Índice en la tabla de seculas
  int? nivel;    //Cada tipo de secuela tienen varios niveles
  int? puntos;   //puntos asignados por el périto. Para cada indice,nivel hay un rango posible.

  SecuelaTipo(this.indice, this.nivel, this.puntos);
}

@JsonSerializable()
class Secuela {
  String? descripcion;
  List<SecuelaTipo> secuelas;

  Secuela(this.descripcion, this.secuelas);

  //TODO terinar clase

}
