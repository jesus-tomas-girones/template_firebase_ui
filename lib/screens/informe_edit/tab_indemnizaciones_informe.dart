part of 'informe_edit.dart';

///
/// Parte de clase [_InformeEditPageState]
///
extension SectionTabIndemnizacion on _InformeEditPageState{

  // en las extensiones no se pueden declarar variables

  // ======================================================================================
  // Tab 2 indemnización
  // ======================================================================================
  Widget _TabIndemnizacion() {
    return ListView(
      children: [
        //-------------------------------------------------
        FieldCheckBox("Hay muerte", informeTemp.hayMuerte,
                (newValue){setState(() {informeTemp.hayMuerte = newValue ?? false;});},
            padding: 0
        ),
        informeTemp.hayMuerte ? _mostrarCamposMuerte() : Container(),
        const Divider(),

        //-------------------------------------------------
        FieldCheckBox("Hay lesiones temporales", informeTemp.hayLesion,
                (newValue){setState(() {informeTemp.hayLesion = newValue ?? false;});},
            padding: 0,
            enable: !informeTemp.hayMuerte
        ),
        (informeTemp.hayLesion && !informeTemp.hayMuerte) ? _mostrarCamposLesionTemporales() : Container(),

        const Divider(),

        //-------------------------------------------------
        FieldCheckBox("Hay secuelas", informeTemp.haySecuela,
                (newValue){setState(() {informeTemp.haySecuela = newValue ?? false;});},
            padding: 0,
            enable: !informeTemp.hayMuerte
        ),
        (informeTemp.haySecuela && !informeTemp.hayMuerte) ? _mostrarCamposSecuelas() : Container(),

        

      ],
    );
  }

  Widget _mostrarCamposMuerte(){

     Paciente? victima = Paciente.findPacienteById(widget.pacientes!,informeTemp.idPaciente);

    return Container(
      color: const Color.fromARGB(200, 240, 240, 240),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
        
          if(informeTemp.fechaAccidente==null)
            _buildTextoExplicativo("* Recuerde asignar una fecha de accidente al informe para el correcto cáclulo del importe por muerte"),

          if(victima==null)
            _buildTextoExplicativo("* Recuerde asignar un paciente para el correcto cáluclo del importe por muerte"),
          
          if(victima!=null && victima.fechaNacimiento==null)
            _buildTextoExplicativo("* Recuerde asignarle fecha de nacimiento al paciente para el correcto cáluclo del importe por muerte"),

          FieldEnum<Embarazo>("Embarazo", informeTemp.embarazo, Embarazo.values,
              (newValue){setState(() {informeTemp.embarazo = newValue!;});},
                validator: (value) => value==null ? "Campo obligatorio" : null,
                customNames: ["No embarazada","Perdida de feto con más 12 semanas","Perdida de feto con 12 semanas o menos"]
        ),
          // explicaciones de hijo, progenitor, hermano unico
          if(informeTemp.embarazo == Embarazo.mas12Semanas)
            _buildTextoExplicativo("* Incremento sobre el perjuicio básico de 30.000 €"),
          if(informeTemp.embarazo == Embarazo.menosO12Semanas)
            _buildTextoExplicativo("* Incremento sobre el perjuicio básico de 15.000 €"),
          
          EditorListaObjetos<Familiar>(
            titulo: "Lista de familiares:", // Encabezado de la lista. NO DE EL DIALOG
            listaObjetos: informeTemp.familiares,
            tituloAnyadir: "Añadir nuevo familiar",
            formKey: _formKeyAddFamiliar,
            objetoTemporal: tempFamiliar, // TODO intentar quitar y que solo este en editor_lista_objetos
            crearFormulario: _buildFormFamiliar,
            onChange:() { setState(() {}); },
            elementoLista: (item) => Padding(padding: EdgeInsets.fromLTRB(16, 8, 32, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(flex: 2,child: Text(item.nombre.toString() +" "+ item.apellidos.toString(),overflow: TextOverflow.ellipsis, maxLines: 2,),),
                      Flexible(child: Text(item.parentesco!.name)),
                      Flexible(child: Text(formatoMoneda(item.calcularIndemnizacion(informeTemp,victima).round())+" €")),
                    ])
              ),
            //formulario: _buildFormFamiliar(tempFamiliar, tituloForm: "Añadir Familiar"),
          ),
       
          Padding(padding: const EdgeInsets.all(16), 
            child: Text("Importe total: "+formatoMoneda(informeTemp.calcularTotalGastos().round())+" €",
                    style: const TextStyle(fontSize: 18),),
          )
        ],
      ),
    );
  }

  ///
  ///
  /// Crear un formulario en base a un familiar
  ///
  Form _buildFormFamiliar( Familiar f, {String? tituloForm}){
    Paciente? victima = Paciente.findPacienteById(widget.pacientes!,informeTemp.idPaciente);  
    return Form(
      key: _formKeyAddFamiliar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldText("Nombre", f.nombre,
              (value) => setState(() { f.nombre=value; }),
              mandatory: true),
          FieldText("Apellidos", f.apellidos,
              (value) => setState(() { f.apellidos=value; }),
              mandatory: true),

          // Parentesco y fecha de nacimiento
          Padding(padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(children: [
              Flexible(child:
                FieldEnum<Parentesco>(
                "Parentesco", f.parentesco, Parentesco.values,
                    (value) => setState(() { f.parentesco = value; },
                    ),
                customNames:  ["Hijo", "Padre", "Conyuge", "Nieto","Abuelo","Hermano","Allegado"], // TODO obtener automaticamente con bucle
                padding: 8,
                validator: (value) => value==null ? "Campo obligatorio" : null),
              ),

              // Fecha de naciemiento cuando hijo, nieto o hermano
              if (f.parentesco!=null && (f.parentesco == Parentesco.hijo || f.parentesco == Parentesco.hermano))
                Flexible(child:
                  FieldDate("Fecha nacimiento", f.fechaNacimiento,
                  (value) => setState(() { 
                    f.fechaNacimiento = value;
                  }),
                  context, padding: 8,
                  )
                ),
            ],),
          ),
        
          // explicaciones de hijo, progenitor, hermano unico
          if(f.esParentescoUnico(f, informeTemp.familiares) && f.parentesco == Parentesco.hijo)
            _buildTextoExplicativo("* Tiene un aumento del 25% por ser hijo único"),
          if(f.esParentescoUnico(f, informeTemp.familiares) && f.parentesco == Parentesco.padre)
            _buildTextoExplicativo("* Tiene un aumento del 25% por ser progenitor único"),
          if(f.esParentescoUnico(f, informeTemp.familiares) && f.parentesco == Parentesco.hermano)
            _buildTextoExplicativo("* Tiene un aumento del 25% por ser hermano único"),

          // explicacion de unico familiar vivo
          if(informeTemp.familiares.length==1)
            _buildTextoExplicativo("* Tiene un aumento del 25% por ser el único familiar vivo"),
          
          // explicacion de perdida de hijo unico
          if(f.parentesco == Parentesco.padre && !f.esHijoUnico(informeTemp.familiares))
            _buildTextoExplicativo("* Tiene un aumento del 25% por la perdida del hijo único"),

          // explicacion cuando se escoge abuelo
          if (f.parentesco!=null && f.parentesco == Parentesco.abuelo)
            _buildTextoExplicativo("* Solo en caso de premorencia del progenitor de su rama familiar."),

          // explicacion cuando se escoge nieto
          if (f.parentesco!=null && f.parentesco == Parentesco.nieto)
            _buildTextoExplicativo("* Solo en caso de premorencia del progenitor hijo del abuelo fallecido."),
          
          // explicacion cuando se escoge allegado
          if (f.parentesco!=null && f.parentesco == Parentesco.allegado)
            _buildTextoExplicativo("* Se considera allegado a aquella persona que tenga una convivencia por un mínimo de 5 años inmediatamente anterior al fallecimiento y tenga una relación de cercanía entre la víctima y el “allegado” basada en razones de parentesco o afectividad.\n\nQueda excluido el concepto las personas que simplemente comparten piso sin existir vínculo afectivo alguno entre ellas."),
          
          if (f.parentesco!=null && f.parentesco == Parentesco.hijo)
            FieldEnum<ElOtroProgenitor>(
                "El otro progenitor", f.elOtroProgenitor, ElOtroProgenitor.values,
                    (value) => setState(() { f.elOtroProgenitor = value; },
                    ),
                customNames:  ["Vive", "Muiró en el accidente", "Ya murió"],
                validator: (value) => value==null ? "Campo obligatorio" : null),

          // Fecha del matrimonio si es conyuge
          if (f.parentesco!=null && f.parentesco == Parentesco.conyuge)
            FieldDate("Fecha del matrimonio", f.fechaMatrimonio,
                (value) => setState(() { f.fechaMatrimonio = value;}),
                context,
                validator: (fecha){if(fecha==null){return "Campo obligatorio";}return null;}),

          Padding(padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
            child: Row(children: [
              Flexible(child:
                FieldText("DNI", f.dni,
                  (value) => setState(() { f.dni = value;}),
                  mandatory: true, padding: 8),
              ),
              Flexible(child:
                FieldCheckBox("Discapacidad", f.discapacidad??false,
                  (value) => setState(() { 
                    f.discapacidad = value;
                    if(!f.discapacidad!){
                      f.incrementoDiscapacidad = null;
                    }
                  
                  }),
                  padding: 0),
                ),
            ] ),
          ),

          // incremento por discapacidad
          if (f.discapacidad!=null && f.discapacidad!)
            FieldText("Incremento sobre prejuicio básico [25% - 75%]", 
                    f.incrementoDiscapacidad == null ? "" : f.incrementoDiscapacidad.toString(),
                    (newValue)async{setState(() {
                      f.incrementoDiscapacidad = newValue == "" ?  0 :  double.parse(newValue);
                      
                    });},
                isNumeric: true,
                validator: (newValue){
                  if(newValue!=null){
                    double value = newValue == "" ?  0 :  double.parse(newValue);
                    if(value<25 || value>75){
                      return "El valor debe estar entre 25 y 75";
                    }
                  }
                },
                hint: "Introduce el porcentaje de incremento debido a la discapacidad"),
          // explicacion de discapacidad
          if (f.discapacidad!=null &&f.discapacidad!)
            _buildTextoExplicativo("* Grado de discapacidad física, intelectual o sensorial del perjudicado como mínimo del 33%. No es necesario disponer de una resolución administrativa que así lo reconozca, pudiendo acreditarse por cualquiera de los medios de prueba admitidos en Derecho.\n\nPuede ser anterior al accidente o a resultas del mismo.\n\nEl accidente debe provocar una “alteración perceptible” en la vida de la persona con discapacidad."),

          // Perjuicio excepcional
          FieldText("Perjuicio excepcional (hasta 25%)", 
                    f.perjuicioExcepcional == null ? "" : f.perjuicioExcepcional.toString(),
                    (newValue)async{setState(() {
                      
                      f.perjuicioExcepcional = newValue == "" ?  null :  double.parse(newValue);
                      
                    });},
                isNumeric: true,
                validator: (newValue){
                  if(newValue!=null){
                    double value = newValue == "" ?  0 :  double.parse(newValue);
                    if(value<0 || value>25){
                      return "El valor debe estar entre 0 y 25";
                    }
                  }
                },
                hint: "Introduce el porcentaje de incremento debido a perjuicio excepcional"),

          // justificacionPerjuicioExcepcional
          FieldText("Justificación del perjucio excepcional ", f.justificacionPerjuicioExcepcional, 
            (value) => f.justificacionPerjuicioExcepcional = value,
            maxLines: 3
          ),

          // Check box de convivencia
          if((f.parentesco == Parentesco.padre && victima!=null && informeTemp.fechaAccidente!=null && victima.fechaNacimiento!=null && diferenciaAnyos(informeTemp.fechaAccidente!,victima.fechaNacimiento!)>30) // padres cuyo hijo victima es mayor de 30 años
              || ((f.parentesco == Parentesco.hijo || f.parentesco == Parentesco.hermano) && informeTemp.fechaAccidente!=null && f.fechaNacimiento!=null && diferenciaAnyos(informeTemp.fechaAccidente!,f.fechaNacimiento!)>30) // hijos de mayor de 30 que vivian con su padre
              || (f.parentesco == Parentesco.nieto) 
              || (f.parentesco == Parentesco.abuelo))
              FieldCheckBox("Convivencia con la victima", f.convivencia??false,
                  (value) => setState(() { 
                    f.convivencia = value;
                  }),
                  padding: 0),

        

      ], ),
    );
  }

  Widget _buildTextoExplicativo(String texto){
    return Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 0), 
    child: RichText(text: TextSpan(text: texto,style: const TextStyle(fontSize: 14,color: Color.fromARGB(221, 33, 33, 33))),textAlign: TextAlign.justify,));
  }

  Widget _mostrarCamposLesionTemporales(){
    return Container(
      color: const Color.fromARGB(200, 240, 240, 240),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Lista de Texto
          FieldText("Lesiones", informeTemp.lesiones,
                  (newValue)async{
                setState(() {
                  informeTemp.lesiones = newValue;
                });
              },
              maxLines: 4,
              hint: "Introduzca las lesiones temporales del paciente"
          ),

          Row(
            children: [
              Flexible(
                  child: FieldText("Días de UCI", informeTemp.diasUci == 0 ? "" : informeTemp.diasUci.toString(),
                        (newValue)async{setState(() {
                          informeTemp.diasUci = newValue == "" ?  0 :  int.parse(newValue);
                        
                        
                        });},
                    isNumeric: true,
                    hint: "Introduce los días que el paciente estuvo en la uci",
                  )),
              Flexible(
                  child: FieldText("Días hospitalizado", informeTemp.diasPlanta == 0 ? "" : informeTemp.diasPlanta.toString(),
                          (newValue)async{setState(() {
                            informeTemp.diasPlanta = newValue == "" ?  0 :  int.parse(newValue);
                            
                            });},
                      isNumeric: true,
                      hint: "Introduce los días que el paciente estuvo hospitalizado"
                  )),
              Flexible(
                  child: FieldText("Días de baja laboral", informeTemp.diasBaja == 0 ? "" : informeTemp.diasBaja.toString(),
                          (newValue)async{setState(() {
                            informeTemp.diasBaja = newValue == "" ?  0 :  int.parse(newValue);
                            
                            });},
                      isNumeric: true,
                      hint: "Introduce los días que el paciente estuvo de baja laboral"
                  )),
            ],
          ),

          // Dias de perjuicio basico
          FieldText("Días de perjuicio básico", informeTemp.diasPerjuicio == 0 ? "" : informeTemp.diasPerjuicio.toString(),
                  (newValue)async{setState(() {
                    informeTemp.diasPerjuicio = newValue == "" ?  0 :  int.parse(newValue);
                     });},
              isNumeric: true,
              hint: "Introduce los días de perjucio básico del paciente"
          ),
          FieldText("Lucro cesante", informeTemp.lucroCesante == 0 ? "" : informeTemp.diasPerjuicio.toString(),
                  (newValue)async{setState(() {
                    informeTemp.lucroCesante = newValue == "" ?  0 :  double.parse(newValue);
                     });},
              isNumeric: true,
              hint: "Introduce el lucro cesante del paciente"
          ),
          Padding(padding: const EdgeInsets.all(16), 
          child: Text("Importe total: "+formatoMoneda(informeTemp.calcularImporteIndemnizacionesLesiones().round())+" €",
                  style: const TextStyle(fontSize: 18),),
          )
        ],
      )
    );
  }

  Widget _mostrarCamposSecuelas(){
    return Container(
      color: const Color.fromARGB(200, 240, 240, 240),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          EditorListaObjetos<Secuela>(
            titulo: "Lista de secuelas:", // Encabezado de la lista. NO DE EL DIALOG
            listaObjetos: informeTemp.secuelas,
            formKey: _formKeyAddSecuela,
            objetoTemporal: tempSecuela,
            onChange:(){
              // se guardo o cancelo en el widget, repintamos
              setState(() {});
            },
            elementoLista: (item) {
              return Text(item.descripcion.toString());
            },
            crearFormulario: _buildFormSecuela,
          ),
          // total indemnizaciones
        Padding(padding: const EdgeInsets.all(16), child: 
        Text("Total puntos: "+ informeTemp.calcularPuntosSecuelas().toString()+"",
        style: const TextStyle(fontSize: 18)),)
        ],
      )
    );
  }

  ///
  ///
  /// Crear un formulario en base a una secuela
  ///
  Form _buildFormSecuela(Secuela s){
    return Form(
      key: _formKeyAddSecuela,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldText("Descripcion", s.descripcion,
              (value) => setState(() { s.descripcion=value; }),
              mandatory: true),
          EditorListaObjetos<SecuelaTipo>(
            onChange: (){setState(() {});},
            titulo: "Lista de tipos secuelas:",
            formKey: _formKeyAddTipoSecuela,
            listaObjetos: s.secuelas, 
            objetoTemporal: tempTipoSecuela, 
            elementoLista: (item){
              return Text((item.secuela ?? "") + " - " + (item.nivel ?? "") +
                  " - puntos: "+ item.puntos.toString());
            }, 
            crearFormulario: _buildFormTipoSecuela
            )
        ],
      )
    );
  }

  ///
  ///
  /// Crear un formulario en base a tipo secuela
  ///
  Form _buildFormTipoSecuela(SecuelaTipo s){
    return Form(
      key: _formKeyAddTipoSecuela,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          FieldObjetList<String>("Especialidad", s.especialidad, SecuelaTipo.listaEspecialidades(),
            (newValue){setState(() {
              s.especialidad = newValue;
              // si cambiamos la especialidad, los campos que dependen de el ponerlos a null para borrarlos
              s.secuela = null;
              s.nivel = null;
            });},
            hint: "Elige la especialidad"
          ),
          FieldObjetList<String?>("Secuela",s.secuela, SecuelaTipo.listaSecuela(s.especialidad ?? ""), 
            (newValue){setState(() {
              s.secuela = newValue;
              // si cambiamos la secuela, los campos que dependen de el ponerlos a null para borrarlos
              s.nivel = null;
            });},
            hint: "Elige la secuela",
            enable: s.especialidad!=null // si la especialidad no esta puesta deshabilitarlo
          ),
          FieldObjetList<String?>("Nivel", s.nivel, SecuelaTipo.listaNiveles(s.especialidad ?? "",s.secuela ?? "" ), 
            (newValue){setState(() {
              s.nivel = newValue; s.puntos = 0;});
              //rango = SecuelaTipo.rangoPuntos(s.especialidad, s.secuela, s.nivel);
            },
            hint: "Elige el nivel",
            enable: s.secuela!=null // si la secuela no esta puesta deshabilitarlo
          ),
          /*FieldInt("Puntos "+SecuelaTipo.rangoPuntos(s.especialidad, s.secuela, s.nivel).toString(),
            s.puntos,
            (newValue){ setState(() {
                s.puntos = newValue.isNotEmpty ? int.parse(newValue) : 0;
                //print("puntos");
              }); },
            key: formKey,
            enable: s.nivel!=null, // si el nivel no esta puesta deshabilitarlo
            min: 3,
            max: 6,
        ),*/
          FieldText(
            "Puntos "+SecuelaTipo.rangoPuntos(s.especialidad, s.secuela, s.nivel).toString(),
            s.puntos.toString(),
            (newValue){
              setState(() {
                int puntos = newValue.isNotEmpty ? int.parse(newValue) : 0;
                // [0] -> min, [1]-> max
                List<int> rangoPuntos = SecuelaTipo.rangoPuntos(s.especialidad, s.secuela, s.nivel);
                if(puntos >= rangoPuntos[0] && puntos <= rangoPuntos[1]){
                   s.puntos = puntos;
                }
              });
            },
            isNumeric: true,
            enable: s.nivel!=null, // si el nivel no esta puesta deshabilitarlo
            //mandatory: true,
            validator: (value){
              value = value ?? "";
              int valueInt = value.isNotEmpty ? int.parse(value) : 0;
              // [0] -> min, [1]-> max
              List<int> rangoPuntos = SecuelaTipo.rangoPuntos(s.especialidad, s.secuela, s.nivel);
              if(valueInt<rangoPuntos[0] || valueInt > rangoPuntos[1]){
                return "El valor debe estar entre " + rangoPuntos[0].toString() + " y " + rangoPuntos[1].toString();
              }
              return null;
            }
          )
        ],
      )
    );
  }




}