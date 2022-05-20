import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;


// Clase para poder pasar un booleano como referencia
class BooleanWraper {
  bool value;
  BooleanWraper(this.value);
}

/// Se incluyen diferentes Widgets que se usan como campos de formulario
/// Son formularios normales.
/// En form_fields_icon se definen campos alternativos donde para editar hay que pulsar un botón

Widget FieldText(  /// Campo de texto normal
    String title,
    String? value_,
    ValueChanged<String>? onChanged,
    {String hint = "",
      bool mandatory = false,
      bool isNumeric = false,
      int maxLines = 1,
      String? mensajeError,
      String? Function(String?)? validator,
      double padding = 16,
    }) =>
    Padding(padding: EdgeInsets.fromLTRB(padding, padding, padding, 0),
      child: TextFormField(
        onChanged: onChanged,
        validator: (mandatory) ? validatorMandatory(validator) : validator,
        maxLines: maxLines,
        initialValue: value_,
        keyboardType: isNumeric ? TextInputType.number : null,
        inputFormatters: isNumeric ? <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
        ] : null,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          filled: value_?.isNotEmpty ?? false,
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
  return (value) {
    if (value!.trim().isEmpty) {
      return "El campo no puede estar vacio.";
    }
    if (validator == null){
      return null;
    } else {
      return validator(value);
    }
  };
}

Widget FieldDate(  /// Campo de fecha
    String title,
    DateTime? value,
    ValueChanged<DateTime> onChanged,
    BuildContext context,
    {String hint = "",
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
            filled: value != null,
            contentPadding: const EdgeInsets.symmetric(horizontal:12,vertical:20),
            floatingLabelBehavior: value != null ? FloatingLabelBehavior.always : null,
            // Border Label TextBox 1
            labelText: title,
            //labelStyle: const TextStyle(color: Colors.black54),
            hintText: value == null
                ? title
                : intl.DateFormat('dd/MM/yyyy').format(value),
//            hintMaxLines: 2,
            hintStyle: const TextStyle(color: Colors.black),
          ),
        ),
      ),
    );

Widget FieldEnum<Enum>(
  String? title,
  Enum? valueInit,
  List<Enum> valuesEnum,
  Function(Enum? val) onChange,
  {List<String>? customNames,
  String? Function(Enum?)? validator,
  String hint = "",
  double padding = 16
  }) =>
 //     Map customNamesMap = customNames.asMap(); // le hacemos un map para poder comprobar si existe las mismas posiciones de Enums que nombres, asi
                                                // devolver el valor por defecto si no existe
      Padding(padding: EdgeInsets.fromLTRB(padding, padding, padding, 0),
            child: DropdownButtonFormField<Enum>(
                decoration: InputDecoration(
                  filled: valueInit != null,
                  hintText: hint,
                  labelText: title ?? "",
                  border: const OutlineInputBorder(),
                ),
                validator: validator,
                isExpanded: true,
                value: valueInit ,
                onChanged: (value) =>  onChange(value),
                items: valuesEnum.asMap().entries.map((entry) {
                // items: valuesEnum.map((entry) { //Menudo lio con la línea de arriba. Intento esto, pero no lo consigo
                //  Con la siguiente línea te has rallado pasandolo a map
                //  String texto = customNamesMap.containsKey(entry.key) ? customNames[entry.key] : entry.value.toString();
                  String texto; //Versión larga
                  if (customNames != null && customNames.length>entry.key) {
                    texto = customNames[entry.key];
                  } else {
                    texto = entry.value.toString();
                    texto = texto.substring(texto.indexOf('.')+1);
                  }
                  String _texto =  //Versión corta
                    (customNames != null && customNames.length>entry.key)
                       ? customNames[entry.key]
                       : entry.value.toString().substring(texto.indexOf('.')+1);
                  return DropdownMenuItem<Enum>(
                      value: entry.value,
                      child: Text(texto));
                }).toList()
        ),
      );


Widget FieldObjetList<T>(
  String title,
  T? selectedItem,
  List<T> items,
  void Function(T?)? onChanged,
  {String hint = "",
  double padding = 16}
  ) =>
    Padding(padding: EdgeInsets.fromLTRB(padding, padding, padding, 0),
      child: DropdownSearch<T>(
        mode: Mode.DIALOG,// DIALOG, MENU o BOTTOM SHEET
        showSearchBox: true,
        selectedItem: selectedItem, // para modificar lo que sale modificamos el toString del objeto
        dropdownSearchDecoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: title,
          hintText: hint,
          filled: selectedItem!=null
        ),
        onChanged: onChanged,
        items: items
      ),
    );

Widget FieldCheckBox(
  String title,
  bool initValue,
  void Function(bool?)? onChanged,
  {double padding = 16, 
  bool enable = true}
) =>
    Padding(padding: EdgeInsets.fromLTRB(padding, padding, padding, 0),
      child: CheckboxListTile(
        title: Text(title),
        value: enable ? initValue : false, 
        onChanged: enable ? onChanged : null // de esta forme se vuelve gris y no se puede interactuar
      ),
    );