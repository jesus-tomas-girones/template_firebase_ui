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
              onChange:(){
                // se guardo o cancelo en el widget, repintamos
                setState(() { });
              },
              elementoLista: (item) {
                return Padding(padding: EdgeInsets.fromLTRB(16, 8, 32, 0),
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
            style: const TextStyle(fontSize: 18)),)
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

          FieldEnum<TipoGasto>("Tipo de gasto", gasto.tipoGasto, TipoGasto.values, 
            (value)=> setState(() {
              gasto.tipoGasto = value;
              if(gasto.tipoGasto !=TipoGasto.Cirugia){
                  gasto.especialidad = null;
                  gasto.grado = null;
              }
            
            })),

          if(gasto.tipoGasto!=null && gasto.tipoGasto == TipoGasto.Cirugia)
            FieldObjetList<String>("Especialidad", gasto.especialidad, Gasto.listaEspecialidades(),
            (newValue){setState(() {
              gasto.especialidad = newValue;
              // si cambiamos la especialidad, los campos que dependen de el ponerlos a null para borrarlos
              gasto.grado = null;
            });},
            hint: "Elige la especialidad"
          ),
          if(gasto.especialidad!=null)
            FieldText("Grado de especialidad "+Gasto.rangoGrados(gasto.especialidad).toString(), 
                    gasto.grado == null ? "" : gasto.grado.toString(),
                    (newValue)async{setState(() {
                      
                      gasto.grado = newValue == "" ?  null :  int.parse(newValue);
                      
                    });},
                isNumeric: true,
                validator: (newValue){
                  if(newValue!=null){
                    List<int> rango = Gasto.rangoGrados(gasto.especialidad);
                    double value = newValue == "" ?  0 :  double.parse(newValue);
                    if(value<rango[0] || value>rango[1]){
                      return "El valor debe estar entre "+rango[0].toString()+" y "+rango[1].toString();
                    }
                  }
                },
                hint: "Introduce el grado de especialidad"),
        
          FieldText("Importe", 
                    gasto.importe.toString(),
                    (newValue)async{setState(() {
                      
                      gasto.importe = newValue == "" ?  0 :  double.parse(newValue);
                      
                    });},
                isNumeric: true,
                hint: "Introduce el importe del gasto"),
        
          // TODO hacer adjuntos a cada gasto
          /*SelectorFicherosFirebase(
            firebaseColecion: "users/"+Provider.of<AppState>(context,listen: false).user!.uid.toString()+"/informes/"+informeTemp.id.toString()+"/gastos-"+gasto.id.toString(), 
            storageRef: "users/"+Provider.of<AppState>(context,listen: false).user!.uid.toString()+"/informes/"+informeTemp.id.toString()+"/gastos/"+gasto.descripcion+"/", 
            titulo: "Ficheros adjuntos", 
            textoNoFicheros: "No hay ficheros adjuntos para este gasto"
          )*/

        ],
      ),
    );
  }

}