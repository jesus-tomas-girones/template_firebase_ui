

import 'dart:html';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_ui/api/api.dart';
import 'package:firebase_ui/model/gasto.dart';
import 'package:firebase_ui/model/secuela.dart';
import 'package:firebase_ui/utils/numero_helper.dart';
import 'package:firebase_ui/utils/pdf_helper.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';



import '../../app.dart';
import '../../model/familiar.dart';
import '../../model/informe.dart';
import '../../model/paciente.dart';
import '../../utils/date_time_helpers.dart';
import '../../widgets/editor_lista_objetos.dart';
import '../../widgets/selector_ficheros_firebase.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/form_miscelanius.dart';
import '../paciente_edit.dart';


part 'tab_datos_informe.dart';
part 'tab_indemnizaciones_informe.dart';
part 'tab_gastos_informe.dart';

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
  late SelectorFicherosFirebaseController _ficherosFirebaseControllerGastos;
  late int _currentTabIndex = 0;

  // variables tab de datos -------------------------------
  final _formKeyInforme =  GlobalKey<FormState>(debugLabel: "key_form_informe");
  late Informe informeTemp;
  late String? pacienteSeleccionado;
  late bool isEditing;
  late bool _seHaAnyadidoFichero = false;


  // variables tab de indemnizaciones -------------------------------
  Familiar tempFamiliar = Familiar();
  Secuela tempSecuela = Secuela();
  SecuelaTipo tempTipoSecuela = SecuelaTipo();
  final _formKeyAddFamiliar =  GlobalKey<FormState>(debugLabel:"key_form_familiar");
  final _formKeyAddSecuela =  GlobalKey<FormState>(debugLabel:"key_form_secuela");
  final _formKeyAddTipoSecuela =  GlobalKey<FormState>(debugLabel:"key_form_tipo_secuela");


  // variables tab de gastos  -------------------------------
  Gasto tempGasto = Gasto();
  final _formKeyAddGasto =  GlobalKey<FormState>(debugLabel:"key_form_gasto");
  final EditorListaObjetosController _listaObjetosControllerGastos = EditorListaObjetosController();
  
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
    _ficherosFirebaseControllerGastos = SelectorFicherosFirebaseController();
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
                     // debe estar el selector de ficheros renderizado para que se pueda hacer una accion con él
                    // en este caso llamar al borrar de su controlador
                    _tabController.animateTo(0);
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
        ) : Container(),
        IconButton(
          onPressed: _generarPdf,
          icon: const Icon(Icons.more)
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: _tabs
      ),
    );
  }

  void _generarPdf()async{
      
      PDFHelper pdfHelper = PDFHelper();

      // SI PONEMOS INFORME TEMP SE GENERA DE LOS CAMBIOS ACTUALES
      // SI PONEMOS widget.informe se hace del que esta guardado
      // TODO valorar cual de los dos informes guardar como pdf
      var pdf = await pdfHelper.generar_pdf_de_informe(widget.informe!);
      var path = await pdfHelper.guardar_pdf("informe", pdf);

      print("Se guardo en: "+path);
      
  }

  void _borrarInforme()async{
    await showDialogSeguro(
      context: context,
      title: '¿Borrar informe?',
      ok: 'BORRAR',
      onAccept: () async{
        _setLoading(true);
        // debe estar el selector de ficheros renderizado para que se pueda hacer una accion con él
        // en este caso llamar al borrar de su controlador
        _tabController.animateTo(0);
        await _ficherosFirebaseController.borrarTodos();
        //_tabController.animateTo(2);
        //await _ficherosFirebaseControllerGastos.borrarTodos();
        await widget.informeApi!.delete(widget.informe!.id!);
        _setLoading(false);
        Navigator.pop(context);
      },
    );
  }

  void _guardarInforme() async{
    _setLoading(true);

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

    // si se guarda habiendo un gasto abierto la aplicacion da error
    if(_tabController.index == 2 && _listaObjetosControllerGastos.esconderFormEditar!=null){
      _listaObjetosControllerGastos.esconderFormEditar!();
    }
   

    Informe res = await widget.informeApi!.update(informeTemp,informeTemp.id!);
    Navigator.of(context).pop();

    _setLoading(false);
  }

  

  

}
