import 'package:firebase_ui/widgets/editable_string.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../model/informe.dart';
import '../model/paciente.dart';

/// Se incluyen diferentes Widgets que se usan como campos de formulario
/// Son formularios normales.
/// En form_fields_icon se definen campos alternativos donde para editar hay que pulsar un botón

Widget FieldText(  /// Campo de texto normal
    String title,
    String? value,
    ValueChanged<String>? onChanged,
    {String hint = "",
      bool mandatory = false,
      int maxLines = 1,
      String? mensajeError,
      String? Function(String?)? validator,
      double padding = 16
    }) =>
    Padding(
      padding: EdgeInsets.fromLTRB(padding, padding, padding, 0),
      child: TextFormField(
        onChanged: onChanged,
        validator: (mandatory) ? validatorMandatory(validator) : validator,
        maxLines: maxLines,
        initialValue: value,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          filled: value?.isNotEmpty ?? false,
          hintText: hint,
          label: mandatory
              ? RichText(
              text: TextSpan(
                  style: const TextStyle(color: Colors.black54),
                  text: title,
                  children: const [
                    TextSpan(text: '*', style: TextStyle(color: Colors.red))
                  ]))
              : Text(title),
          errorText: mensajeError,
        ),
      ),
    );

//Si se indica mandatory, se añade automáticamente el siguiente validator
String? Function(String? p1)? validatorMandatory(String? Function(String? p1)? validator) {
  return (value) => (value!.trim().isEmpty)
      ? "El campo no puede estar vacio."
      : validator!(value);
}


Widget FieldDate_(  /// Campo de fecha
    String title,
    DateTime? value,
    ValueChanged<DateTime> onChanged,
    BuildContext context,
    {String hint = "",
      bool mandatory = false,
      String? Function(String?)? validator,
      double padding = 16
    }) =>
    Padding(
      padding: EdgeInsets.fromLTRB(padding, padding, padding, 0),
      child: InkWell(
        child: TextFormField(
          readOnly: true,
          onTap: () async {
            var newDate = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(), // TODO - poner sin fecha
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            // Don't change the date if the date picker returns null.
            if (newDate == null) return;
            onChanged(newDate);
          },
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            filled: true,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            // Border Label TextBox 1
            labelText: title,
            labelStyle: const TextStyle(
              color: Colors.black54,
            ),
            hintText: intl.DateFormat("dd-MM-yyyy").format(value!),  //revisar !
            hintMaxLines: 2,
            hintStyle: const TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ),
    );






//TODO los métodos de abajo podrían ir a otro fichero

showDialogSeguro({
        required BuildContext context,
        required String title,
        String? cancel,
        String? ok,
        required Future Function() onAccept}) =>
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        actions: [
          TextButton(
            child: Text(cancel ?? 'Cancelar'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text(ok ?? 'Ok'),
            onPressed: () {
              onAccept();
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );

Widget buildLoading() => const Center(child: CircularProgressIndicator());
//TODO revisar si se pone también lo de Opacity
//if (_isLoading) const Opacity(opacity: 0.1, child: ModalBarrier(dismissible: false, color: Colors.black),),
//if (_isLoading) const Center( child: CircularProgressIndicator(),),


/*Widget CampoTexto(String? valorInicial, String? titulo,
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
}*/