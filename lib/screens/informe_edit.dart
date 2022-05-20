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
import '../widgets/field_lista_objetos.dart';
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
  final _formKeyInforme = GlobalKey<FormState>();
  final _formKeyAddFamiliar = GlobalKey<FormState>();
  final _formKeyAddSecuela = GlobalKey<FormState>();
  late Informe informeTemp;
  Familiar tempFamiliar = Familiar();
  Secuela tempSecuela = Secuela();
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
        informeTemp.hayLesion = false;
        informeTemp.haySecuela = false;
        informeTemp.lesiones = "";
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
            formKey: _formKeyAddFamiliar,
            objetoTemporal: tempFamiliar,
            onChange:(){
              // se guardo o cancelo en el widget, repintamos
              setState(() {});
            },
            
            elementoLista: (item) {
              return ListViewItemDesplegable(
                itemLista: Padding(padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.nombre.toString() +" "+ item.apellidos.toString()),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: (){
                          showDialogSeguro(context: context, title: "¿Borrar el familiar?", 
                          onAccept: () async{
                            setState(() {
                              informeTemp.familiares.remove(item);
                            });
                          });
                        },
                      )
                    ],
                  ),
                ), 
                itemDesplegado: Container(
                  color:const Color.fromARGB(255, 225, 225, 225),
                  child: _buildFormFamiliar("Editar familiar",item),
                ) 
              );
            },
            formulario: _buildFormFamiliar('Añadir nuevo familiar',tempFamiliar),
          ),
      
        ],
      ),
    );
  }

  ///
  ///
  /// Crear un formulario en base a un familiar
  ///
  Form _buildFormFamiliar(String tituloForm, Familiar f){
    return Form(
      key: _formKeyAddFamiliar,
      child: Column( 
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16,16,16,0),
            child: Text(tituloForm, style: Theme.of(context).textTheme.titleLarge,),
          ),
          FieldText("Nombre", f.nombre,
              (value) => setState(() { f.nombre=value; }),
              mandatory: true),
          FieldText("Apellidos", f.apellidos,
              (value) => setState(() { f.apellidos=value; }),
              mandatory: true),
          FieldEnum<Parentesco>(
              "Parentesco", f.parentesco, Parentesco.values,
              (value) => setState(() { f.parentesco = value; }),
              validator: (value) => value==null ? "Campo obligatorio" : null),
          FieldDate("Fecha de nacimiento", f.fechaNacimiento,
              (value) => setState(() { f.fechaNacimiento = value;}),
              context),
          FieldText("DNI", f.dni,
              (value) => setState(() { f.dni = value;}),
              mandatory: true),
          // mostrar si no es padre
          f.parentesco != Parentesco.padre ? FieldCheckBox("Discapacidad", f.discapacidad??false,
              (value) => setState(() { f.discapacidad = value;})):Container(),
        ],
      )
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
              return ListViewItemDesplegable(
                itemLista: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.descripcion.toString()),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: (){
                          showDialogSeguro(context: context, title: "¿Borrar la secuela?", 
                          onAccept: () async{
                            setState(() {
                              informeTemp.secuelas.remove(item);
                            });
                          });
                        },
                      )
                    ],
                  ),
                ), 
                itemDesplegado: Container(
                  color:const Color.fromARGB(255, 225, 225, 225),
                  child: _buildFormSecuela("Editar secuela",item),
                ) 
              );
            },
            formulario: _buildFormSecuela('Añadir nueva secuela',tempSecuela),
          ),
        ],
      )
    );
  }

   ///
  ///
  /// Crear un formulario en base a un familiar
  ///
  Form _buildFormSecuela(String tituloForm, Secuela s){
    return Form(
      key: _formKeyAddSecuela,
      child: Column( 
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16,16,16,0),
            child: Text(tituloForm, style: Theme.of(context).textTheme.titleLarge,),
          ),
          FieldText("Descripcion", s.descripcion,
              (value) => setState(() { s.descripcion=value; }),
              mandatory: true),
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


class ListViewItemDesplegable extends StatefulWidget{

  final Widget itemLista;
  final Widget itemDesplegado;

  ListViewItemDesplegable({Key? key, 
    required this.itemLista,
    required this.itemDesplegado,
  }) : super(key: key);

  @override
  _ListViewItemDesplegable createState() => _ListViewItemDesplegable();

}

class _ListViewItemDesplegable extends State<ListViewItemDesplegable>{
 

  bool _mostrar = false;


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: (){
            setState(() {
              _mostrar = !_mostrar;
            });
          },
          child: widget.itemLista,
        ),
        _mostrar ? widget.itemDesplegado : Container()
      ],
    );
  }
  
}