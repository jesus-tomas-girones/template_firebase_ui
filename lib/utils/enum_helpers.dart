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

