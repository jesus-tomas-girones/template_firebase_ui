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

///
/// Clase que pinta la informacion de un informe, se puede editar y borrar
///

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
  //final _formKey = GlobalKey<FormState>();
  String date = "";
  late DateTime selectedDate;
  late TipoAccidente? tipoAccidenteSeleccionado;
  late String? descripcion;
  late String? lugarAccidente;
  late String? aseguradora;
  late List<Indemnizacion>? indemnizaciones;
  late List<PlatformFile>? ficherosSeleccionados;
  late List<String>? urlServer;
  late List<String>? urlModficadas;
  late Paciente? pacienteSeleccionado;

  late bool isEditing;

  bool _isLoading = false;

  @override
  void initState() {
    isEditing = widget.informe != null;

    selectedDate = widget.informe?.fechaAccidente ?? DateTime.now();
    tipoAccidenteSeleccionado = widget.informe?.tipoAccidente;
    descripcion = widget.informe?.descripcion;
    lugarAccidente = widget.informe?.lugarAccidente;
    aseguradora = widget.informe?.companyiaAseguradora;
    indemnizaciones = widget.informe?.indemnizaciones ?? [];
    pacienteSeleccionado = widget.informe?.paciente;

    // los ficheros selccionados son los que selecciona de la galeria que luego se tendran que subir
    ficherosSeleccionados = [];
    // estas son las url que se obtienen del servidor, es conveniente tenerlas en otro array
    // asi modificar el array de urlModificadas y al darle guardar borrar del storage las url que no estan en modificadas
    urlServer = widget.informe?.ficherosAdjuntos ?? [];
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
                  _buildFormInforme(widget.informe),
                  _buildListaIndemnizaciones(indemnizaciones)
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
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        // GUARDAR INFORME
        IconButton(
          onPressed: _guardarInforme, 
          icon: const Icon(Icons.save)
        )
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: _tabs
      ),
    );
  }
  ///
  /// Funcion que guarda o actualiza el informe
  ///
   ///
  /// Funcion que guarda o actualiza el informe
  ///
  void _guardarInforme() async{
    _setLoading(true);

     try{
       // subir los nuevos ficheros
       String uid = Provider.of<AppState>(context, listen:false).user!.uid;
        for(PlatformFile file in ficherosSeleccionados!){
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

        for(String url in listUrlABorrar){
         bool a = await deleteFile(url);
        }

        var informe = Informe(selectedDate,descripcion!,aseguradora!,lugarAccidente!,pacienteSeleccionado!,
          tipoAccidenteSeleccionado!,urlModficadas!,indemnizaciones!);
        if(isEditing){
          Informe res = await widget.informeApi!.update(informe,widget.informe!.id!);
        }else{
          Informe res = await widget.informeApi!.insert(informe);
        }
        Navigator.of(context).pop();
     }catch(e){
      _setLoading(false);
     }
      _setLoading(false);
  }


  ///
  /// Tab 1 detalles del informe
  ///
  Widget _buildFormInforme(Informe? informe) {

    return ListView(
        children: [
          // date picker fecha accidente
          // TODO habra que ver si debemos poner la hora
          const SizedBox(height: 8,),
          ListTile(
            title: const Text("Fecha del accidente"),
            subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(width: 8,),
                    Text(
                        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
                    const SizedBox(width: 8,),
                    ElevatedButton(
                      onPressed: () {
                        _selectDate(context);
                      },
                      child: const Text("Cambiar Fecha"),
                    ),
                  ],
            ),
          ),
          
          // tipo de accidente
          const SizedBox(height: 8,),
          buildDropDown(tipoAccidenteSeleccionado!, TipoAccidente.values, "Tipo de accidente", "Selecciones Tipo de accidente", 
            (newValue){
              setState(() {
                tipoAccidenteSeleccionado = newValue as TipoAccidente?;
              });
            }),
         // _buildDropDownTipoAccidente(),

          // Descripcion
          const SizedBox(height: 8,),
          _buildCampoTexto(descripcion,"Descripcion",
            (value) async{
              setState(() {
                descripcion = value;
              });
            }
          ),
         
          // lugar del accidente
          const SizedBox(height: 8,),
          _buildCampoTexto(lugarAccidente,"Lugar del accidente",
            (value) async{
              setState(() {
                lugarAccidente = value;
              });
            }),

          // compañia aseguradora
          const SizedBox(height: 8,),
          _buildCampoTexto(aseguradora,"Compañía aseguradora",
            (value) async{
              setState(() {
                aseguradora = value;
              });
            }),

          // Paciente
          const SizedBox(height: 8,),
          _buildDropDownPacientesPrueba(),
          ListTile(
            title: const Text("Paciente"),
            subtitle: Row(
                  children: [
                    ElevatedButton(
                      child: const Text("Añadir Usuario"),
                      onPressed: (){}, 
                    )
                  ],
          )),
          
          // Ficheros adjuntos
          _buildSelectorFicheros(),


        ],
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

  // funcion que muestra el date picker
  _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );
    if (selected != null && selected != selectedDate) {
      setState(() {
        selectedDate = selected;
      });
    }
  }

  // TODO pensar un mejor diseño para el informe
  Widget _buildCampoTexto(String? descripcion, String titulo, Future<dynamic> Function(String value)? onChange) {

    return  ListTile(
            title: Text(titulo),
            subtitle:  Padding(
              padding: const EdgeInsets.only(left: 8),
              child: EditableString(
                onChange: onChange,
                text: descripcion,
                textStyle: const TextStyle(
                              fontSize: 16.0, color: Colors.grey),
              ),
            ),
          );
  }

  // TODO quitar
  Widget _buildDropDownTipoAccidente(){
    return ListTile(
      title: const Text("Tipo accidente"),
      subtitle: DropdownButton<TipoAccidente>(
              hint: const Text("Selecciona el tipo de accidente"),
              value: tipoAccidenteSeleccionado,
              onChanged: (TipoAccidente? newValue) {
                setState(() {
                  tipoAccidenteSeleccionado = newValue!;
                });
              },
              items: TipoAccidente.values.map((TipoAccidente classType) {
                return DropdownMenuItem<TipoAccidente>(
                  value: classType,
                  child: Text(classType.value));
              }).toList()
          ),
    );
  }

  Widget _buildDropDownPacientes(){ 
    return DropdownButton<String>(
        hint: const Text("Selecciona un paciente"),
        value: pacienteSeleccionado?.id,
        onChanged: (String? newIdPaciente) {
          setState(() {
            pacienteSeleccionado = Paciente.findPacienteById(widget.pacientes!, newIdPaciente);
          });
        },
        items: widget.pacientes?.map<DropdownMenuItem<String>>((Paciente paciente){
          return DropdownMenuItem<String>(
            value: paciente.id,
            child: Text(paciente.nombre ?? "")
          );
        }).toList()
    
    );
  }

  Widget _buildDropDownPacientesPrueba(){ 
    return DropdownSearch<Paciente>(
        mode: Mode.DIALOG,// DIALOG, MENU o BOTTOM SHEET
        showSearchBox: true,
        selectedItem: pacienteSeleccionado, // para modificar lo que sale modificamos el toString del objeto
        dropdownSearchDecoration: const InputDecoration(
                  labelText: "Paciente",
                  hintText: "Selecciona un paciente",
        ),
        onChanged: (Paciente? paciente) {
          setState(() {
            pacienteSeleccionado = paciente;
          });
        },
        items: widget.pacientes
    
    );
  }


  // Seccion del selector de ficheros
  
  ///
  /// Widget para seleccionar ficheros
  ///
  Widget _buildSelectorFicheros(){
    return ListTile(
            title: Row(
              children: [
                const Text("Ficheros"),
                ElevatedButton(
                  child: const Text("Añadir ficheros"),
                  onPressed: _addFicheros, 
                ),
              ],
            ),
            subtitle: ficherosSeleccionados!.isEmpty && urlModficadas!.isEmpty
                  ? const Text("Sin fichero adjuntos")
                  : Column(
                    children:[
                        // ficheros
                        Column(children: ficherosSeleccionados!.map((PlatformFile file) {
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
        ficherosSeleccionados!.addAll(result.files);
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
                    ficherosSeleccionados?.remove(file);
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

