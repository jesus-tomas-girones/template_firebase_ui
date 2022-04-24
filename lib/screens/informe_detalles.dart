import 'package:file_picker/file_picker.dart';
import 'package:firebase_ui/modelo/Indemnizacion.dart';
import 'package:firebase_ui/modelo/TipoAccidente.dart';
import 'package:firebase_ui/widgets/editable_string.dart';
import 'package:flutter/material.dart';

import '../modelo/Informe.dart';
import '../modelo/Paciente.dart';

///
/// TODO pensar un mejor nombre que informe_detalles.dart
/// Clase que pinta la informacion de un informe, se puede editar y borrar
///

class InformeDetallePage extends StatefulWidget {

  Informe? informe; // si es null es para crear
  List<Paciente>? pacientes;

  InformeDetallePage({Key? key, this.informe,this.pacientes}) : super(key: key);

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


  final _formKey = GlobalKey<FormState>();
  String date = "";
  late DateTime selectedDate;
  late TipoAccidente? tipoAccidenteSeleccionado;
  late String? descripcion;
  late String? lugarAccidente;
  late String? aseguradora;
  late List<Indemnizacion>? indemnizaciones;
  late List<PlatformFile>? ficherosSeleccionados;
  late Paciente? pacienteSeleccionado;

  @override
  void initState() {
    selectedDate = widget.informe?.fechaAccidente ?? DateTime.now();
    tipoAccidenteSeleccionado = widget.informe?.tipoAccidente;
    descripcion = widget.informe?.descripcion;
    lugarAccidente = widget.informe?.lugarAccidente;
    aseguradora = widget.informe?.companyiaAseguradora;
    indemnizaciones = widget.informe?.indemnizaciones;
    pacienteSeleccionado = widget.informe?.paciente;
    ficherosSeleccionados = widget.informe?.ficherosAdjuntos ?? [];

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

  @override
  Widget build(BuildContext context) {
    return  DefaultTabController(
        length: _tabs.length,
        child: Scaffold(
            floatingActionButton: _currentTabIndex == 1 ? _buildFab() : null,
            appBar: _buildAppBar(),
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildFormInforme(widget.informe),
                _buildListaIndemnizaciones(indemnizaciones)
              ],
            )
        )
    );
    
       
  }

  PreferredSizeWidget? _buildAppBar(){
    return AppBar(
      title: widget.informe == null ? const Text("Añadir Informe"): const Text("Detalles Informe"),
      automaticallyImplyLeading: true,
      // leading es el icono de la izquierda
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        // GUARDAR INFORME
        IconButton(
          onPressed: (){}, 
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
          _buildDropDownTipoAccidente(),

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
          ListTile(
            title: const Text("Paciente"),
            subtitle: Row(
                  children: [
                    _buildDropDownPacientes(),
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
                  child: Text(classType.toString()));
              }).toList()
          ),
    );
  }

  Widget _buildDropDownPacientes(){
    return DropdownButton<int>(
        hint: const Text("Selecciona un paciente"),
        value: pacienteSeleccionado?.id,
        onChanged: (int? newIdPaciente) {
          setState(() {
            pacienteSeleccionado = Paciente.findPacienteById(widget.pacientes!, newIdPaciente);
          });
        },
        items: widget.pacientes?.map<DropdownMenuItem<int>>((Paciente paciente){
          return DropdownMenuItem<int>(
            value: paciente.id,
            child: Text(paciente.nombre)
          );
        }).toList()
    
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
            subtitle: ficherosSeleccionados!.isEmpty 
                  ? const Text("Sin fichero adjuntos")
                  : Column(children: ficherosSeleccionados!.map((PlatformFile file) => _buildFileItem(file)).toList(),)
              
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
        onFileLoading: (FilePickerStatus status) => {}
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

}

