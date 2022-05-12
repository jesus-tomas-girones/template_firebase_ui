import 'package:json_annotation/json_annotation.dart';

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

enum TipoEspecialidad {
  Traumatoligia, Digestivo /* ... */ }

///
/// Clase que representa un informe
///
@JsonSerializable()
class Gasto {

  @JsonKey(ignore: true)
  String? id;
  String descripcion = "";
  TipoGasto? tipoGasto;
  double importe = 0;
  TipoEspecialidad? especialidad;   // solo grupo quirurgico
  int? grado;

  Gasto(this.descripcion, this.tipoGasto, this.importe, this.especialidad,
      this.grado); // solo grupo quirurgico de 1 a 8

  //List<String>? ficherosAdjuntos = [];

}
