import 'package:firebase_ui/utils/enum_helpers.dart';
import 'package:json_annotation/json_annotation.dart';

import '../widgets/editor_lista_objetos.dart';

enum TipoGasto {
  Desplazamiento, Cirugia, Protesis, Autonomia, Otros }

extension TipoGastoExtension on TipoGasto {
  String get value {
    switch (this) {
      case TipoGasto.Desplazamiento:
        return "Desplazamiento";
      case TipoGasto.Cirugia:
        return "Intervención quirúrgica";
      case TipoGasto.Protesis:
        return "Prótesis u órtesis";
      case TipoGasto.Autonomia:
        return "Apoyo a la autonomía";
      case TipoGasto.Otros:
        return "Otros gastos sanitarios";
      default:
        return "sin valor";
    }
  }
}

const ESPACIALIDADES = {
  "Traumatología":[1,4],// del grado 1 al 4
  "Digestivo":[1,8],// del grado 1 al 4
};

enum TipoEspecialidad {
  Traumatoligia, Digestivo /* ... */ }




///
/// Clase que representa un informe
///
@JsonSerializable()
class Gasto implements ClonableVaciable{

  @JsonKey(ignore: true)
  String? id;
  String descripcion = "";
  TipoGasto? tipoGasto;
  double importe = 0;
  String? especialidad;   // solo grupo quirurgico
  int? grado;

  Gasto({
    this.descripcion = "",
    this.tipoGasto,
    this.importe = 0,
    this.especialidad,
    this.grado,

  });

  @override
  clone() {
    return Gasto(
      descripcion: descripcion,
      tipoGasto: tipoGasto,
      importe: importe,
      especialidad: especialidad,
      grado: grado
    )..id = id;
  }

  @override
  vaciar() {
    descripcion = "";
    tipoGasto = null;
    importe = 0;
    especialidad = null;
    grado = null;
  }

    Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
        'descripcion': descripcion,
        'tipo_gasto': tipoGasto.toString(),
        'importe':importe,
        'especialidad': especialidad,
        'grado':grado
      };
    map.removeWhere((key, value) => value == null);
//    map.removeWhere((key, value) => value == []);
    map.removeWhere((key, value) => value == "null");
    print(map);
    return map;
  }

  factory Gasto.fromJson(Map<String, dynamic> json) {
    try {
      return Gasto(
        descripcion: json['descripcion'],
        importe: json['importe'],
        tipoGasto: enumfromString(TipoGasto.values, json['tipo_gasto']),
        especialidad: json['especialidad'],
        grado: json['grado']
      );
    } catch (e) {
      print("Error en Gasto.fromJson");
      print(e);
      return Gasto();
    }
  }


  static List<String> listaEspecialidades() {
    return ESPACIALIDADES.keys.toList();
  }

  static List<int> rangoGrados(String? especialidad) {
    if(ESPACIALIDADES[especialidad]!=null){
      return ESPACIALIDADES[especialidad]!.toList();
    }else{
      return [];
    }
  }
}
