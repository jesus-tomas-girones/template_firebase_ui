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

Widget buildDropDown<Enum>(Enum? valorInicial, List<Enum> valuesEnum,List<String> customNames, String? titulo,String? hintText,
    Function(Enum? value) onChange,String? Function(Enum?)? validator){
      Map customNamesMap = customNames.asMap(); // le hacemos un map para poder comprobar si existe las mismas posiciones de Enums que nombres, asi
                                                // devolver el valor por defecto si no existe
      return  DropdownButtonHideUnderline(
            child: DropdownButtonFormField<Enum>(
                decoration: InputDecoration(
                  filled: valorInicial!=null,
                  hintText: hintText ?? "",
                  labelText: titulo ?? "",
                  border: const OutlineInputBorder(),
                ),
                validator: validator,
                isExpanded: true,
                value: valorInicial ,
                onChanged: (value) =>  onChange(value),
                // de esta forma 
                items: valuesEnum.asMap().entries.map((entry) {
                  String texto = customNamesMap.containsKey(entry.key) ? customNames[entry.key] : entry.value.toString();
                  return DropdownMenuItem<Enum>(
                      value: entry.value,
                      child: Text(texto));
                }).toList()
            ),
      
      );
    }

// TODO quitar
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