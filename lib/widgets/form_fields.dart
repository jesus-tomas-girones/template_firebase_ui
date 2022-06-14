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
      bool enable = true,
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
        enabled: enable,
        validator: (mandatory) ? validatorMandatory(validator) : validator,
        maxLines: maxLines,
        initialValue: value_,
        autovalidateMode: AutovalidateMode.always,
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

Widget FieldInt(  /// Campo de entero
    String title,
    int? value,
    ValueChanged<String>? onChanged, //TODO cambiar a ValueChanged<int>?
    { min = 0,
      max = 0x7fffffff, //0x7fffffffffffffff,
      String hint = "",
      bool enable = true,
      String? mensajeError,
      double padding = 16,
      key
    }) =>
    Padding(padding: EdgeInsets.fromLTRB(padding, padding, padding, 0),
      child: TextFormField(
        key: key,
        onChanged: (val) async {
          int valInt = int.parse(val);
          if (valInt < min)  {
            print("El valor ha de ser mayor que " + min.toString());
 /*           await showDialog(
              context: null,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                  )
                );
              }
            );*/
          };
          //if (key.currentState.validate(val)) onChanged!(val);
        },
        enabled: enable,
        initialValue: value.toString(),
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          filled: value != null,
          hintText: hint,
          label: Text(title),
          errorText: mensajeError,
        ),
        validator: (value) {
          print("**");
          if (value == null || value == "") return null;
          int valInt = int.parse(value);
          if (valInt < min) {
            print("El valor ha de ser mayor que "+min.toString());
            return "El valor ha de ser mayor que "+min.toString();
          };
          if (valInt > max) return "El valor ha de ser menor que "+max.toString();
          return null;
        },
      ),
    );


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

/// Nos permite seleccionar uno de los posibles valores de un enum

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


/// Nos permite seleccionar un elemento de una lista de Strings

Widget FieldListString(
    String? title,
    List<String> values,
    String? value,
    ValueChanged<String?>? onChanged,
    { String hint = "",
      bool enable = true,
      double padding = 16
    }) =>
     Padding(padding: EdgeInsets.fromLTRB(padding, padding, padding, 0),
        child: DropdownButton<String>(
          onChanged: enable ? onChanged : null,
          value: value,
          items: values.map<DropdownMenuItem<String>>((valueD) => 
            DropdownMenuItem<String>(child: Text(valueD), value: valueD,)
          ).toList(),
          hint: Text(hint),
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