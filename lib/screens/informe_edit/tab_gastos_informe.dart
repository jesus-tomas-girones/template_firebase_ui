part of 'informe_edit.dart';

///
/// Parte de clase [_InformeEditPageState]
///
extension SectionTabGastos on _InformeEditPageState{


  // ======================================================================================
  // Tab 3 gastos
  // ======================================================================================
  Widget _TabGastos() {
    return ListView(
      children: [ 
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            EditorListaObjetos<Gasto>(
              titulo: "Lista de gastos:", // Encabezado de la lista. NO DE EL DIALOG
              tituloAnyadir: "Añadir nuevo gasto",
              listaObjetos: informeTemp.gastos,
              formKey: _formKeyAddGasto,
              objetoTemporal: tempGasto,
              controlador: _listaObjetosControllerGastos,
              onChange:(){
                // se guardo o cancelo en el widget, repintamos
                setState(() {});
              },
              elementoLista: (item) {
                return Padding(padding: const EdgeInsets.fromLTRB(16, 8, 32, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(flex: 2,child: Text(item.descripcion.toString(), overflow: TextOverflow.ellipsis, maxLines: 2,),),
                      Flexible(child: Text(formatoMoneda(item.importe.round())+" €")),
                    ])
                );
              },
              crearFormulario: _buildFormGasto,
            ),
          
          // total indemnizaciones
          Padding(padding: const EdgeInsets.all(16), child: 
            Text("Total de gastos: "+formatoMoneda(informeTemp.calcularTotalGastos().round())+" €",
            style: const TextStyle(fontSize: 18)),),
          
          // ficheros
          SelectorFicherosFirebase(
            firebaseColecion: "users/"+Provider.of<AppState>(context,listen: false).user!.uid.toString()+"/informes/"+informeTemp.id.toString()+"/gastos", 
            storageRef: "users/"+Provider.of<AppState>(context,listen: false).user!.uid.toString()+"/informes/"+informeTemp.id.toString()+"/gastos/", 
            titulo: "Ficheros adjuntos", 
            controller: _ficherosFirebaseControllerGastos,
            textoNoFicheros: "No hay ficheros adjuntos para los gasto",
            callbackFicheroAnyadido: (){
                _seHaAnyadidoFichero = true;
            }
          )
          ],
        ) 
      ]
    );
  }

  Form _buildFormGasto(Gasto gasto){
    return Form(
      key: _formKeyAddGasto,
      child: Column(
        children: [
          FieldText("Descripción", gasto.descripcion, 
            (value)=>setState(() {gasto.descripcion = value;})),

          FieldText("Importe", 
                    gasto.importe.toString(),
                    (newValue)async{setState(() {
                      
                      gasto.importe = newValue == "" ?  0 :  double.parse(newValue);
                      
                    });},
                isNumeric: true,
                hint: "Introduce el importe del gasto"),
                
          FieldEnum<TipoGasto>("Tipo de gasto", gasto.tipoGasto, TipoGasto.values, 
            (value)=> setState(() {
              gasto.tipoGasto = value;
              if(gasto.tipoGasto !=TipoGasto.Cirugia){
                  gasto.especialidad = null;
                  gasto.grado = null;
                  gasto.intervencion = null;
              }
            
            })),

          if(gasto.tipoGasto!=null && gasto.tipoGasto == TipoGasto.Cirugia)
            FieldObjetList<String>("Especialidad", gasto.especialidad, Gasto.listaEspecialidades(),
            (newValue){setState(() {
              gasto.especialidad = newValue;
              // si cambiamos la especialidad, los campos que dependen de el ponerlos a null para borrarlos
              gasto.grado = null;
              gasto.intervencion = null;
            });},
            hint: "Elige la especialidad"
          ),

          if(gasto.especialidad!=null)
            FieldText("Intervención", 
                    gasto.intervencion ?? "",
                    (newValue)async{setState(() {
                      
                      gasto.intervencion = newValue == "" ?  null :  newValue;
                      if(gasto.intervencion == null){
                        gasto.grado = null;
                      }
                      
                    });},
                hint: "Introduce el grado de la intervención"),

          if(gasto.intervencion!=null)
            FieldText("Grado de la intervención", 
                    gasto.grado ?? "",
                    (newValue)async{setState(() {
                      
                      gasto.grado = newValue == "" ?  null :  (newValue);
                      
                    });},
                hint: "Introduce el grado de la intervención"),
        

        ],
      ),
    );
  }

}