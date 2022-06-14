import 'package:file_picker/file_picker.dart';
import 'package:firebase_ui/api/api.dart';
import 'package:firebase_ui/model/secuela.dart';
import 'package:firebase_ui/widgets/form_fields_edit.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../model/familiar.dart';
import '../model/informe.dart';
import '../model/paciente.dart';
import '../widgets/editor_lista_objetos.dart';
import '../widgets/selector_ficheros_firebase.dart';
import '../widgets/form_fields.dart';
import '../widgets/form_miscelanius.dart';
import 'paciente_edit.dart';


///
/// Clase que pinta la informacion de un informe, se puede editar y borrar
///
class InformeEditPage extends StatefulWidget {

  Api<Informe>? informeApi;
  Api<Paciente>? pacienteApi;  // Para poder crear nuevos pacientes
  Informe? informe; // si es null es para crear
  List<Paciente>? pacientes;
  InformeEditPage({Key? key, this.informe,this.pacientes,this.informeApi,this.pacienteApi}) : super(key: key);

  @override
  _InformeEditPageState createState() => _InformeEditPageState();
}

// el with es para poder usar el tab controller
class _InformeEditPageState extends State<InformeEditPage> with SingleTickerProviderStateMixin{

  final List<Tab> _tabs = const [
    Tab(child: Text("Datos"),),
    Tab(child: Text("Indemnización"),),
    Tab(child: Text("Gastos"),),
  ];
  late TabController _tabController;
  late SelectorFicherosFirebaseController _ficherosFirebaseController;
  late int _currentTabIndex = 0;
  final _formKeyInforme =  GlobalKey<FormState>(debugLabel: "key_form_informe");
  final _formKeyAddFamiliar =  GlobalKey<FormState>(debugLabel:"key_form_familiar");
  final _formKeyAddSecuela =  GlobalKey<FormState>(debugLabel:"key_form_secuela");
  final _formKeyAddTipoSecuela =  GlobalKey<FormState>(debugLabel:"key_form_tipo_secuela");
  late Informe informeTemp;
  Familiar tempFamiliar = Familiar();
  Secuela tempSecuela = Secuela();
  SecuelaTipo tempTipoSecuela = SecuelaTipo();
  late List<PlatformFile> ficherosAnyadidos;
  late List<String>? urlServer;
  late List<String>? urlFicherosSubidos;
  late String? pacienteSeleccionado;
  late bool isEditing;
  late bool _seHaAnyadidoFichero = false;

  bool _isLoading = false;

  @override
  void initState() {
    isEditing = widget.informe != null;
    if (widget.informe != null) {
      // Debemos hacer esto porque sino se estara modificando la referencia y puede dar a problemas
      informeTemp = widget.informe!.clone();
      isEditing = true;
    } else {
      _isLoading = true;
      informeTemp = Informe();
      _crearInformeVacio(); // de esta forme tenemos una referencia a la bd y podemos añadirle imagenes
      isEditing = false;
    }

    _ficherosFirebaseController = SelectorFicherosFirebaseController();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
            if (!_tabController.indexIsChanging) {
              // Your code goes here.
              // To get index of current tab use tabController.index
              setState(() {
                _currentTabIndex = _tabController.index;
              });
            }
      });
    super.initState();
  }

  // crear un informe vacio para tener la referencia del id y asi poder subir imagenes
  void _crearInformeVacio() async{

    informeTemp =  await widget.informeApi!.insert(informeTemp);
    _setLoading(false);

  }


  @override void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _setLoading(bool bool) {
    setState(() {
      _isLoading = bool;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  DefaultTabController(
        length: _tabs.length,
        child: Stack(
          children: [
            Scaffold(
              //floatingActionButton: _currentTabIndex == 1 ? _buildFab() : null,
              appBar: _buildAppBar(),
              body: TabBarView(
                controller: _tabController,
                children: [
                  _TabDetalles(informeTemp),
                  _TabIndemnizacion(),
                  _TabGastos()
                ],
              )
            ),
            // carga //TODO ¿Por que dos if?
            if (_isLoading) const Opacity(opacity: 0.1, child: ModalBarrier(dismissible: false, color: Colors.black),),
            if (_isLoading) const Center( child: CircularProgressIndicator(),),
          ],
        )
    );
  }

  PreferredSizeWidget? _buildAppBar(){
    return AppBar(
      title: !isEditing ? const Text("Añadir Informe"): const Text("Informe"),
      automaticallyImplyLeading: true,
      // leading es el icono de la izquierda
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: (){
          if (informeTemp != widget.informe || _seHaAnyadidoFichero) {
              showDialogSeguro(
                  context: context,
                  title: "Se perderán todos los cambios que no esten guardados",
                  onAccept: () async {
                    _setLoading(true);

                    await _ficherosFirebaseController.borrarAnyadidos();
                    // si no se estaba editando y cancela cambios borramos el documentos
                    if(!isEditing){
                      await widget.informeApi!.delete(informeTemp.id!);
                    }
                    _setLoading(false);
                    Navigator.pop(context);
                  });
            } else {
              Navigator.pop(context);
            }
        },
      ),
      actions: [
        // GUARDAR INFORME
        IconButton(
          onPressed: _guardarInforme,
          icon: const Icon(Icons.save)
        ),
        isEditing ? IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _borrarInforme,
        ) : Container()
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: _tabs
      ),
    );
  }

  void _borrarInforme()async{
    await showDialogSeguro(
      context: context,
      title: '¿Borrar informe?',
      ok: 'BORRAR',
      onAccept: () async{
        _setLoading(true);
        await _ficherosFirebaseController.borrarTodos();
        await widget.informeApi!.delete(widget.informe!.id!);
        _setLoading(false);
        Navigator.pop(context);
      },
    );
  }

  void _guardarInforme() async{
    _setLoading(true);
//    try {

      if(informeTemp.hayMuerte){
        // no guardar secuelas y lesiones si esta marcado hayMuerte
        // TODO valorar si ponerlo o no 
        informeTemp.hayLesion = false;
        informeTemp.haySecuela = false;
        informeTemp.lesiones = null;
        informeTemp.diasBaja = 0;
        informeTemp.diasPerjuicio = 0;
        informeTemp.diasPlanta = 0;
        informeTemp.diasUci = 0;
        informeTemp.secuelas = [];
      }

//      print(_formKeyInforme.currentState!.validate());

//      if (_formKeyInforme.currentState!.validate()){
   //     if (isEditing) {
   //       Informe res = await widget.informeApi!.update(informeTemp,widget.informe!.id!);
   //     }else{
          Informe res = await widget.informeApi!.update(informeTemp,informeTemp.id!);
   //     }
        Navigator.of(context).pop();
//      }
/*    } catch(e) {
       print('isEditing: ' + isEditing.toString());
       print("error al guardar informe");
       print(e);
      _setLoading(false);
    }*/
    _setLoading(false);
  }

  // ======================================================================================
  // Tab 1 Detalles
  // ======================================================================================
  Widget _TabDetalles(Informe? informe) {
    return Form(
        key: _formKeyInforme,
        child: ListView(
          children: [
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
              customNames: ["Trafico","Laboral","Deportivo","Via publica"],
              hint: "Selecciona el tipo de accidente"),
            FieldText("Descripción", informeTemp.descripcion,
                (value) => setState(() { informeTemp.descripcion = value; }),
                hint: "Introduce la descripcion del informe",
                mandatory: true,
                maxLines: 3
              ),
            FieldText("Lugar del accidente", informeTemp.lugarAccidente,
                (value) => setState(() { informeTemp.lugarAccidente = value; }),
                hint: "Introduce el lugar del accidente",
              ),
            FieldText("Compañía aseguradora", informeTemp.companyiaAseguradora,
                (value) => setState(() { informeTemp.companyiaAseguradora = value; }),
                hint: "Introduce la compañía aseguradora",
              ),
            SelectorFicherosFirebase(
              firebaseColecion: "users/"+Provider.of<AppState>(context,listen: false).user!.uid.toString()+"/informes/"+informeTemp.id.toString()+"/ficheros",
              storageRef: "users/"+Provider.of<AppState>(context,listen: false).user!.uid.toString()+"/informes/"+informeTemp.id.toString()+"/",
              titulo: "Ficheros adjuntos",
              textoNoFicheros: "No se han añadido ficheros aun",
              controller: _ficherosFirebaseController,
              callbackFicheroAnyadido: (){
                _seHaAnyadidoFichero = true;
              },
            )
          ],
        ),
    );
  }

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
        FieldCheckBox("Hay lesiones temproales", informeTemp.hayLesion,
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
    return Container(
      color: const Color.fromARGB(200, 240, 240, 240),
      child: Column(
        children: [
          FieldCheckBox("Fallecida embarazada", informeTemp.embarazada,
                (newValue){setState(() {informeTemp.embarazada = newValue ?? false;});},
          ),
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
                      Flexible(child: Text(" 5.000 €")), // TODO calcular importe del familiar, crear funcion en familiar
                    ])
              ),
            //formulario: _buildFormFamiliar(tempFamiliar, tituloForm: "Añadir Familiar"),
          ),
       
           
        ],
      ),
    );
  }

  ///
  ///
  /// Crear un formulario en base a un familiar
  ///
  Form _buildFormFamiliar( Familiar f, {String? tituloForm}){
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
        Padding(padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(children: [
            Flexible(child:
              FieldEnum<Parentesco>(
              "Parentesco", f.parentesco, Parentesco.values,
                  (value) => setState(() { f.parentesco = value; },
                  ),
              customNames:  ["Hijo", "Padre", "Conyuge", "Pareja de hecho","Divorciado"], // TODO obtener automaticamente con bucle
              padding: 8,
              validator: (value) => value==null ? "Campo obligatorio" : null),
            ),
            Flexible(child:
              FieldDate("Fecha nacimiento", f.fechaNacimiento,
              (value) => setState(() { f.fechaNacimiento = value;}),
              context, padding: 8,),
            ),
          ],),
        ),
        Padding(padding: EdgeInsets.fromLTRB(8, 8, 0, 0),
          child: Row(children: [
            Flexible(child:
              FieldText("DNI", f.dni,
                (value) => setState(() { f.dni = value;}),
                mandatory: true, padding: 8),
            ),
            Flexible(child:
              FieldCheckBox("Discapacidad", f.discapacidad??false,
                (value) => setState(() { f.discapacidad = value;}),
                padding: 0),
              ),
          ] ),
        ),
      ], ),
    );
  }

  Widget _mostrarCamposLesionTemporales(){
    return Container(
      color: const Color.fromARGB(200, 240, 240, 240),
      child: Column(
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
                        (newValue)async{setState(() {informeTemp.diasUci = newValue == "" ?  0 :  int.parse(newValue);});},
                    isNumeric: true,
                    hint: "Introduce los días que el paciente estuvo en la uci",
                  )),
              Flexible(
                  child: FieldText("Días hospitalizado", informeTemp.diasPlanta == 0 ? "" : informeTemp.diasPlanta.toString(),
                          (newValue)async{setState(() {informeTemp.diasPlanta = newValue == "" ?  0 :  int.parse(newValue);});},
                      isNumeric: true,
                      hint: "Introduce los días que el paciente estuvo hospitalizado"
                  )),
              Flexible(
                  child: FieldText("Días de baja laboral", informeTemp.diasBaja == 0 ? "" : informeTemp.diasBaja.toString(),
                          (newValue)async{setState(() {informeTemp.diasBaja = newValue == "" ?  0 :  int.parse(newValue);});},
                      isNumeric: true,
                      hint: "Introduce los días que el paciente estuvo de baja laboral"
                  )),
            ],
          ),

          // Dias de perjuicio basico
          FieldText("Días de perjuicio básico", informeTemp.diasPerjuicio == 0 ? "" : informeTemp.diasPerjuicio.toString(),
                  (newValue)async{setState(() {informeTemp.diasPerjuicio = newValue == "" ?  0 :  int.parse(newValue);});},
              isNumeric: true,
              hint: "Introduce los días de perjucio básico del paciente"
          ),
        ],
      )
    );
  }

  Widget _mostrarCamposSecuelas(){
    return Container(
      color: const Color.fromARGB(200, 240, 240, 240),
      child: Column(
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
  // TODO cambiar al bueno, ahora es form de prueba
  Form _buildFormTipoSecuela(SecuelaTipo s){
    const Key formKey = Key("");
    return Form(
      key: _formKeyAddTipoSecuela,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldListString("Especialidad", SecuelaTipo.listaEspecialidades(), s.especialidad, 
            (newValue){setState(() {
              s.especialidad = newValue;
              // si cambiamos la especialidad, los campos que dependen de el ponerlos a null para borrarlos
              s.secuela = null;
              s.nivel = null;
            });},
            hint: "Elige la especialidad"
          ),
          FieldListString("Secuela", SecuelaTipo.listaSecuela(s.especialidad ?? ""), s.secuela, 
            (newValue){setState(() {
              s.secuela = newValue;
              // si cambiamos la secuela, los campos que dependen de el ponerlos a null para borrarlos
              s.nivel = null;
            });},
            hint: "Elige la secuela",
            enable: s.especialidad!=null // si la especialidad no esta puesta deshabilitarlo
          ),
          FieldListString("Nivel", SecuelaTipo.listaNiveles(s.especialidad ?? "",s.secuela ?? "" ), s.nivel, 
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
              // TODO no valida bien, da problemas de key duplicadas
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

  // ======================================================================================
  // Tab 3 gastos
  // ======================================================================================
  Widget _TabGastos() =>
      Center(child: Text("Gastos"),);

  // Floating action button = añadir informe
  Widget _buildFab(){
    return FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: (){

        }
    );
  }

}
