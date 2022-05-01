import 'package:firebase_ui/model/informe.dart';
import 'package:firebase_ui/model/paciente.dart';
import 'package:flutter/material.dart';

///
/// Metodo que al pasarle los valores de un enum (ClassEnum.values) y uno de sus valores en tu String
/// te devuelve el objeto del enum
/// Con esto podemos guardar en firebase el to string y al recogerlo podemos obtener el enum
///
dynamic enumfromString<T>(List<dynamic> values, String? value){
  if(value != null){
    for(Enum e in values){
      if(e.toString() == value){
        return e;
      }
    }
  }
  return null;
}

Widget buildDropDown<Enum>(Enum? valorInicial, List<Enum> valuesEnum, String? titulo,String? hintText,
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
String getCustomEnumName(e){
  try{
    switch(e){
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
  }catch(e){
    return "";
  }
}