import 'package:firebase_ui/widgets/editable_string.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../model/informe.dart';
import '../model/paciente.dart';

/// Se incluyen diferentes Widgets que se usan como campos de formulario
/// Para editar hay que pulsar un botón

Widget CampoTexto(String? valorInicial, String? titulo,
        Future<dynamic> Function(String value)? onChange) =>
    ListTile(
      title: Text(titulo ?? ""),
      subtitle: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: EditableString(
          onChange: onChange,
          text: valorInicial,
          textStyle: const TextStyle(fontSize: 16.0, color: Colors.grey),
        ),
      ),
    );

Widget CampoFecha(DateTime? fecha, String? titulo, BuildContext context,
        Future<dynamic> Function(DateTime value) onChange) =>
    ListTile(
      title: Text(titulo ?? ""),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(width: 8),
          Text(fecha == null
              ? "<fecha desconocida>"
              : intl.DateFormat('dd/MM/yyyy').format(fecha)),
          IconButton(
            icon: const Icon(Icons.edit),
            color: Theme.of(context).colorScheme.secondary,
            onPressed: () {
              showDatePicker(
                context: context,
                initialDate: fecha ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              ).then((value) {
                if (value != null) {
                  onChange(value);
                }
              });
            },
          ),
        ],
      ),
    );



Widget CampoDesplegable<Enum>(Enum? valorInicial, List<Enum> valuesEnum, String? titulo, String? hintText,
    Function(Enum? value) onChange) =>
    ListTile(
      title: Text(titulo ?? ""),
      subtitle: DropdownButton<Enum>(
          hint: Text(hintText ?? ""),
          value: valorInicial ,
          onChanged: (value) =>  onChange(value),
          items: valuesEnum.map((value) {
            return DropdownMenuItem<Enum>(
                value: value,
                child: Text(getCustomEnumName(value)));
          }).toList()
      ),
    );


// TODO revisar si es buena solucion

// Mejor indicar los posibles strings en un array en un paámetro
//CampoDesplegable(paciente.sexo, Sexo.values, ["hombre","mujer"]
//          "Sexo del paciente","Seleccione el sexo",
//          (dynamic value){ setState(() { paciente.sexo = value; }); }cor),

String getCustomEnumName(e) {
  try {
    switch (e) {
      case Sexo.hombre:
        return "Hombre";
      case Sexo.mujer:
        return "Mujer";
      case TipoAccidente.Deportivo:
        return "Deportivo";
      case TipoAccidente.Laboral:
        return "Laboral";
      case TipoAccidente.ViaPublica:
        return "Via publica";
      case TipoAccidente.Trafico:
        return "Trafico";
      default:
        return e.name;
    }
  } catch (e) {
    return "";
  }
}