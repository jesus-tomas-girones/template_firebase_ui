import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_ui/api/api.dart';
import 'package:firebase_ui/model/indemnizacion.dart';
import 'package:firebase_ui/utils/enum_helpers.dart';
import 'package:firebase_ui/widgets/editable_string.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../model/informe.dart';
import '../model/paciente.dart';
import '../utils/firestore_utils.dart';
import '../widgets/form_fields.dart';
import '../widgets/form_miscelanius.dart';

///
/// Clase que pinta la informacion de un informe, se puede editar y borrar
///
// TODO una variable bool isModified para que no te pregunte
class InformeDetallePage extends StatefulWidget {

  Api<Informe>? informeApi;
  Informe? informe; // si es null es para crear
  List<Paciente>? pacientes;

  InformeDetallePage({Key? key, this.informe,this.pacientes,this.informeApi}) : super(key: key);

  @override
  _InformeDetallePageState createState() => _InformeDetallePageState();
}

// el with es para poder usar el tab controller
class _InformeDetallePageState extends State<InformeDetallePage> with SingleTickerProviderStateMixin{

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
  late List<String>? urlModficadas;
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

    // los ficheros selccionados son los que selecciona de la galeria que luego se tendran que subir
    ficherosAnyadidos = [];
    // estas son las url que se obtienen del servidor, es conveniente tenerlas en otro array
    // asi modificar el array de urlModificadas y al darle guardar borrar del storage las url que no estan en modificadas
    // TODO no se muestran las urls del servidor
    urlServer = informeTemp.ficherosAdjuntos ?? [];
    print("url server");
    print(urlServer);
    urlModficadas = [];
    urlModficadas!.addAll(urlServer!);
    

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
  
  @override
 void dispose() {
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
            
            // contenido
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
  ///
  /// Funcion que borra el informe
  ///
  void _borrarInforme()async{
    await showDialogSeguro(
      context: context,
      title: '¿Borrar informe?',
      ok: 'BORRAR',
      onAccept: () async{
        _setLoading(true);
        await widget.informeApi!.delete(widget.informe!.id!);
        if(widget.informe!.ficherosAdjuntos!=null){
          for(String ref in widget.informe!.ficherosAdjuntos!){
            deleteFile(ref);
          }
        }
        _setLoading(false);
        Navigator.pop(context);
      },
      );
  }

  ///
  /// Funcion que guarda o actualiza el informe
  ///
  void _guardarInforme() async{
    _setLoading(true);

     try{
      if(_formKeyInforme.currentState!.validate()){
         // subir los nuevos ficheros
       String uid = Provider.of<AppState>(context, listen:false).user!.uid;
        for(PlatformFile file in ficherosAnyadidos){
          String url = await uploadFile(file,"users/"+uid+"/ficherosAdjuntos/"+file.name);
          urlModficadas!.add(url);
        }
        // borrar de las urls de la base de datos que el usuario ha quitado
        List<String> listUrlABorrar = [];
        for(String url in urlServer!){
          if(!urlModficadas!.contains(url)){
            listUrlABorrar.add(url);
          }
        }

        print("URL MODIFICADAS: ");
        print(urlModficadas);
        print("URL A BORRAR: ");
        print(listUrlABorrar);

        for(String url in listUrlABorrar){
         bool a = await deleteFile(url);
        }
        
        informeTemp.ficherosAdjuntos = urlModficadas;
        if(isEditing){
          Informe res = await widget.informeApi!.update(informeTemp,widget.informe!.id!);
        }else{
          Informe res = await widget.informeApi!.insert(informeTemp);
        }
        Navigator.of(context).pop();
      }
     }catch(e){
       print("error al guardar informe");
       print(e);
      _setLoading(false);
     }
      _setLoading(false);
  }


  ///
  /// Tab 1 detalles del informe
  ///
  Widget _buildFormInforme(Informe? informe) {

    return Form(
        key: _formKeyInforme,
        child: ListView(
          children: [
            // date picker fecha accidente
            // TODO habra que ver si debemos poner la hora
            FieldDate(
                "Fecha del accidente",
                informeTemp.fechaAccidente,
                (value) {setState(() {informeTemp.fechaAccidente = value;});},
                context,
                hint: "Seleccione la fecha del accidente"
              ),

            // tipo de accidente
            FieldEnum( 
              "Tipo de accidente", 
              informeTemp.tipoAccidente, 
              TipoAccidente.values,
              (newValue){
                setState(() {
                  informeTemp.tipoAccidente = newValue as TipoAccidente?;
                });
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
          
            FieldObjetList<Paciente>(
              "Paciente",
              Paciente.findPacienteById(widget.pacientes!, informeTemp.idPaciente),
              widget.pacientes!,
              (Paciente? paciente){
                informeTemp.idPaciente = paciente!.id;
              },
              hint: "Selcciona el paciente"
            ),
            
            // Ficheros adjuntos
            // TODO pensar mejor diseño
            _buildSelectorFicheros(),
          ],
        ),
    );
  }

  ///
  /// Tab 2 lista de indemnizaciones
  ///
  Widget _buildListaIndemnizaciones(List<Indemnizacion>? indemnizaciones) {
    return Column(
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

  }

  ///
  /// Floating action button = añadir informe
  ///
  Widget _buildFab(){
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: (){

      }
    );
  }

  // Seccion del selector de ficheros
  
  ///
  /// Widget para seleccionar ficheros
  ///
  Widget _buildSelectorFicheros(){
    return ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Ficheros"),
                ElevatedButton(
                  child: const Text("Añadir ficheros"),
                  onPressed: _addFicheros, 
                ),
              ],
            ),
            subtitle: ficherosAnyadidos.isEmpty && urlModficadas!.isEmpty
                  ? const Text("Sin fichero adjuntos")
                  : Column(
                    children:[
                        // ficheros
                        Column(children: ficherosAnyadidos.map((PlatformFile file) {
                            return _buildFileItem(file);
                         }).toList(),),
                         //urls
                         Column(children: urlModficadas!.map((String ref) {
                            return _buildRefFirebaseItem(ref);
                         }).toList(),)
                      ]
                  )
              
            );
  }


  ///
  /// Callbcak del file picker
  ///
  void _addFicheros() async{
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        onFileLoading: (FilePickerStatus status) => {},
        allowedExtensions: ['jpg', 'png','pdf','txt']);

    if (result != null) {
      setState(() {
        ficherosAnyadidos.addAll(result.files);
      });
    }
  }

  ///
  /// Item de la lista de ficheros seleccionados
  ///
  Widget _buildFileItem(PlatformFile file){
    // para controlar el nombre del fichero (por ejmplo el 60% de la pantalla)
    // TODO buscar una mejor solucion para el overflow del nombre del fichero
    double screenWidth = MediaQuery.of(context).size.width;
    return Card(
          elevation: 5,
          shadowColor: Colors.black,
          color: Colors.greenAccent[100],
          // Dos rows para que el icono de la foto y el nombre salgan al lado y el eliminar a la otra punta
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Row(
                  children: [
                    const SizedBox(width: 8,),
                    const Icon(Icons.image),
                    const SizedBox(width: 8,),
                    LimitedBox(maxWidth: screenWidth*0.7,child: Text(file.name, overflow: TextOverflow.ellipsis, softWrap: false,),)
                  ]
                  
              ),
              IconButton( 
                icon: const Icon(Icons.close),
                onPressed: (){
                  setState(() {
                    ficherosAnyadidos.remove(file);
                  });
                },
              ),
            ],
        ),
    );
  }

  Widget _buildRefFirebaseItem(String ref){
    // para controlar el nombre del fichero (por ejmplo el 60% de la pantalla)
    double screenWidth = MediaQuery.of(context).size.width;
    return Card(
          elevation: 5,
          shadowColor: Colors.black,
          color: Colors.greenAccent[100],
          // Dos rows para que el icono de la foto y el nombre salgan al lado y el eliminar a la otra punta
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Row(
                  children: [
                    const SizedBox(width: 8,),
                    const Icon(Icons.image),
                    const SizedBox(width: 8,),
                    LimitedBox(maxWidth: screenWidth*0.7,child: Text(ref, overflow: TextOverflow.ellipsis, softWrap: false,),)
                  ]
                  
              ),
              IconButton( 
                icon: const Icon(Icons.close),
                onPressed: (){
                  setState(() {
                    urlModficadas?.remove(ref);
                  });
                },
              ),
            ],
        ),
    );
  }

}

