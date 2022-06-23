part of 'informe_edit.dart';

///
/// Parte de clase [_InformeEditPageState]
///
extension SectionTabDetalles on _InformeEditPageState {

  // en las extensiones no se pueden declarar variables


  // ======================================================================================
  // Tab 1 Detalles
  // ======================================================================================
  Widget _TabDetalles(Informe? informe) {
    return Form(
        key: _formKeyInforme,
        child: ListView(
          children: [

            FieldText("Título", informeTemp.titulo,
                (value) => setState(() { informeTemp.titulo = value; }),
                hint: "Introduce el titulo del informe",
                mandatory: true,
              ),

            //Paciente
            Row( children: [
              Expanded( child:
              // TODO habra que ver si debemos poner la hora
                FieldObjetList<Paciente>("Paciente",
                  Paciente.findPacienteById(widget.pacientes!, informeTemp.idPaciente),
                  widget.pacientes!,
                  (Paciente? paciente) => informeTemp.idPaciente = paciente!.id,
                  hint: "Selcciona el paciente"
                ),),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 16, 0),
                child: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PacienteEditPage(
                        pacienteApi: widget.pacienteApi,
                        paciente: null)
                      ));
                  },
                ),),
              ],),
            FieldDate("Fecha del accidente",
                informeTemp.fechaAccidente,
                (value) {setState(() {informeTemp.fechaAccidente = value;});},
                context,
                hint: "Seleccione la fecha del accidente"
              ),
            FieldEnum("Tipo de accidente",
              informeTemp.tipoAccidente,
              TipoAccidente.values,
              (newValue){
                setState(() {informeTemp.tipoAccidente = newValue as TipoAccidente?;});
              },
              customNames: ["Trafico","Laboral","Deportivo","Via publica","Incapacidad sobrevenida"],
              hint: "Selecciona el tipo de accidente"),
            
            FieldText("Lugar del accidente", informeTemp.lugarAccidente,
                (value) => setState(() { informeTemp.lugarAccidente = value; }),
                hint: "Introduce el lugar del accidente",
              ),
            FieldText("Compañía aseguradora", informeTemp.companyiaAseguradora,
                (value) => setState(() { informeTemp.companyiaAseguradora = value; }),
                hint: "Introduce la compañía aseguradora",
              ),
            FieldText("Descripción", informeTemp.descripcion,
                (value) => setState(() { informeTemp.descripcion = value; }),
                hint: "Introduce la descripcion del informe",
                maxLines: 2000
              ),
            SelectorFicherosFirebase(
              firebaseColecion: "users/"+Provider.of<AppState>(context,listen: false).user!.uid.toString()+"/informes/"+informeTemp.id.toString()+"/ficheros",
              storageRef: "users/"+Provider.of<AppState>(context,listen: false).user!.uid.toString()+"/informes/"+informeTemp.id.toString()+"/",
              titulo: "Ficheros adjuntos",
              textoNoFicheros: "No se han añadido ficheros aun",
              controller: _ficherosFirebaseController,
              callbackFicheroAnyadido: (){
                //_seHaAnyadidoFichero = true;
              },
            )
          ],
        ),
    );
  }
}

