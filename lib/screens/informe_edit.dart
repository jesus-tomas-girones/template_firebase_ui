import 'package:file_picker/file_picker.dart';
import 'package:firebase_ui/api/api.dart';
import 'package:firebase_ui/model/indemnizacion.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../model/informe.dart';
import '../model/paciente.dart';
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
    Tab(child: Text("Informe"),),
    Tab(child: Text("Indemnizaciones"),)
  ];
  late TabController _tabController;
  late int _currentTabIndex = 0;
  final _formKeyInforme = GlobalKey<FormState>();
  // TODO hacer lo del informe.clone() como en el paciente
  late Informe informeTemp;
  late List<PlatformFile> ficherosAnyadidos;
  late List<String>? urlServer;
  late List<String>? urlFicherosSubidos;
  late String? pacienteSeleccionado;
  late bool isEditing;
  bool _isLoading = false;

  @override
  void initState() {
    isEditing = widget.informe != null;
    if (widget.informe != null) {
      // Debemos hacer esto porque sino se estara modificando la referencia y puede dar a problemas
      informeTemp = widget.informe!.clone();
      isEditing = true;
    } else {
      // TODO cuando es uno nuevo salta error
      informeTemp = Informe();
      isEditing = false;
    }
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
              floatingActionButton: _currentTabIndex == 1 ? _buildFab() : null,
              appBar: _buildAppBar(),
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildFormInforme(informeTemp),
                  _buildListaIndemnizaciones(informeTemp.indemnizaciones)
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
      title: !isEditing ? const Text("Añadir Informe"): const Text("Detalles Informe"),
      automaticallyImplyLeading: true,
      // leading es el icono de la izquierda
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: (){
          if (informeTemp != widget.informe) {
              showDialogSeguro(
                  context: context,
                  title: "Se perderán todos los cambios que no esten guardados",
                  onAccept: () async {
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
        await widget.informeApi!.delete(widget.informe!.id!);
        _setLoading(false);
        Navigator.pop(context);
      },
    );
  }

  void _guardarInforme() async{
    _setLoading(true);
    try {
      if (_formKeyInforme.currentState!.validate()){
        if (isEditing) {
          Informe res = await widget.informeApi!.update(informeTemp,widget.informe!.id!);
        } else {
          Informe res = await widget.informeApi!.insert(informeTemp);
        }
        Navigator.of(context).pop();
      }
    } catch(e) {
       print("error al guardar informe");
       print(e);
      _setLoading(false);
    }
    _setLoading(false);
  }

  // Tab 1 detalles del informe
  Widget _buildFormInforme(Informe? informe) {
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
              storageRef: "users/"+Provider.of<AppState>(context,listen: false).user!.uid.toString()+"/ficherosAdjuntos/",
              titulo: "Ficheros adjuntos",
              textoNoFicheros: "No se han añadido ficheros aun",
            )
          ],
        ),
    );
  }

  // Tab 2 lista de indemnizaciones
  Widget _buildListaIndemnizaciones(List<Indemnizacion>? indemnizaciones) =>
    Column(
      children: [
        Expanded(
          child: (indemnizaciones == null || indemnizaciones.isEmpty
              ? const Center(child: Text("Aun sin indemnizaciones"),)
              // TODO cambiar a obtenerlo de la BD
              :  ListView.separated(
                  separatorBuilder: (context, index) =>
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(color: Colors.black, thickness: 0.2,),),
                  itemBuilder: (context, index) {
                    return Text("Indemnizacion "+index.toString());
                  },
                  itemCount: indemnizaciones.length,
              )
          )
        )
      ],
    );

  // Floating action button = añadir informe
  Widget _buildFab(){
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: (){

      }
    );
  }

}

