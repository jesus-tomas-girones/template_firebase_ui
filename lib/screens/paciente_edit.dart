/// Clase que pinta la informacion de un paciente, se puede editar y borrar

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../model/paciente.dart';
import '../api/api.dart';
import '../utils/enum_helpers.dart';
import '../widgets/form_fields.dart';
import 'package:intl/intl.dart' as intl;

class PacienteEditPage extends StatefulWidget {
  Api<Paciente>? pacienteApi;
  Paciente? paciente; // si es null es para crear

  PacienteEditPage({Key? key, this.paciente, this.pacienteApi})
      : super(key: key) {
//    paciente ??= Paciente();
  }

  @override
  _PacienteEditPageState createState() => _PacienteEditPageState();
}

class _PacienteEditPageState extends State<PacienteEditPage> {
  late bool isEditing;
  bool _isLoading = false;
  //bool _seHaEditado = false;
  final _formKey = GlobalKey<FormState>();
  late Paciente pacienteTemp;

  @override
  void initState() {
    if (widget.paciente != null) {
      // Debemos hacer esto porque sino se estara modificando la referencia y puede dar a problemas
      pacienteTemp = widget.paciente!.clone();
      isEditing = true;
    } else {
      pacienteTemp = Paciente();
      isEditing = false;
    }
    super.initState();
  }

  void _setLoading(bool bool) {
    setState(() {
      _isLoading = bool;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.save),
          onPressed: () => _guardarPaciente(),
        ),
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            _buildBodyForm(pacienteTemp), //_bodySinForm(paciente),
            if (_isLoading) buildLoading(),
          ],
        ));
  }

  // TODO poner mejores hint texts
  Widget _buildBodyForm(Paciente paciente) {
    double? espacioEntreInputs = 32;

    return Form(
        key: _formKey,
        child: ListView(
          //TODO Ancho máximo para que quede bien en los navegadores
          //padding: const EdgeInsets.all(0),
          children: [
            FieldText("Nombre", paciente.nombre,
                (value) => setState(() { paciente.nombre = value; }),
                hint: "Introduce el nombre del paciente",
                mandatory: true,
                validator: (value) => (value!.trim().length<4)
                    ? "El nombre es corto"
                    : (value[0] != value[0].toUpperCase())
                    ? "La inicial ha de estar en mayúsculas"
                        : null
            ),
            FieldText("Apellidos", paciente.apellidos ,
                (value) => setState(() { paciente.apellidos = value; }),
                hint: "Introduce los apellidos del paciente",
            ),
            FieldDate(
              "Fecha de nacimiento",
              paciente.fechaNacimiento,
              (value) {setState(() {paciente.fechaNacimiento = value;});},
              context,
            ),

            FieldDesplegableFromEnum(
              "Sexo del paciente",
              paciente.sexo, 
              Sexo.values, ["Hombre", "Mujer"],
              (dynamic value) => setState(() {paciente.sexo = value;}),
              hintText:  "Seleccione el sexo",
            ),
            FieldText("Domicilio", paciente.domicilio,
              (value) => setState(() { paciente.domicilio = value; }),
              hint: "Introduce el domicilio del paciente",
            ),
            FieldText("Telefono", paciente.telefono,
                  (value) => setState(() { paciente.telefono = value; }),
              hint: "Introduce el teléfono del paciente",
            ),
            // DNI
            FieldText("DNI",paciente.dni, 
              (value) async  => setState(() {paciente.dni = value;}),
              hint: "Introduce el DNI del paciente"
            ),
            // NUSS
            FieldText("NUSS",paciente.nuss, 
              (value) async  => setState(() {paciente.nuss = value;}),
              hint: "Introduce el NUSS del paciente"
            ),
            
            // Antecedentes medicos
            FieldText("Antecedentes medicos",paciente.antecedentesMedicos, 
              (value) async  => setState(() {paciente.antecedentesMedicos = value;}),
              hint: "Introduce los antecedentes medicos del paciente",
              maxLines: 10
            ),
            
            // Ocupacion
            FieldText("Ocupacion",paciente.ocupacion, 
              (value) async  => setState(() {paciente.ocupacion = value;}),
              hint: "Introduce la ocupación del paciente",
            ),
            
            // Empresa
            FieldText("Empresa",paciente.empresa, 
              (value) async  => setState(() {paciente.empresa = value;}),
              hint: "Introduce la empresa del paciente",
            ),
            const SizedBox(height: 12,)
          ],
        ));
  }


/*  Widget _bodySinForm(paciente){
    return ListView(
      children: [
        const SizedBox( height: 8 ),
        CampoTexto(paciente.nombre, "Nombre",
                (value) async { setState(() { paciente.nombre = value; });}),
        CampoTexto(paciente.apellidos, "Apellidos",
                (value) async { setState(() { paciente.apellidos = value; });}),
        CampoFecha(paciente.fechaNacimiento, "Fecha de nacimiento", context,
                (value) async { setState(() { paciente.fechaNacimiento = value; });}),
        buildDropDown(paciente.sexo,Sexo.values,["Hombre","Mujer"],"Sexo del paciente","Seleccione el sexo",(dynamic value){
          setState(() {
            paciente.sexo = value;
          });
        },null),
        //_buildDropDownSexo(paciente),
        CampoTexto(paciente.domicilio, "Domicilio",
                (value) async { setState(() { paciente.domicilio = value; });}),
        CampoTexto(paciente.telefono, "Telefono",
                (value) async { setState(() { paciente.telefono = value; });}),
        CampoTexto(paciente.dni, "DNI",
                (value) async { setState(() { paciente.dni = value; });}),
        CampoTexto(paciente.nuss, "NUSS",
                (value) async { setState(() { paciente.nuss = value; });}),
        CampoTexto(paciente.antecedentesMedicos, "Antecedentes Medicos",
                (value) async { setState(() { paciente.antecedentesMedicos = value; });}),
        CampoTexto(paciente.ocupacion, "Ocupacion",
                (value) async { setState(() { paciente.ocupacion = value; });}),
        CampoTexto(paciente.empresa, "Empresa",
                (value) async { setState(() { paciente.empresa = value; });}),

        // carga //TODO ¿Por que dos if?
//          if (_isLoading) const Opacity(opacity: 0.1, child: ModalBarrier(dismissible: false, color: Colors.black),),
//          if (_isLoading) const Center( child: CircularProgressIndicator(),),
        if (_isLoading) buildLoading(),
      ],
    );
  }*/

  PreferredSizeWidget? _buildAppBar() {
    return AppBar(
      actions: [
        isEditing
            ? IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _borrarPaciente,
              )
            : Container()
      ],
      title:
          !isEditing ? const Text("Añadir Paciente") : const Text("Paciente"),
      automaticallyImplyLeading: true,
      leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            //if (_seHaEditado) {
            if (!(pacienteTemp == widget.paciente)) {
              showDialogSeguro(
                  context: context,
                  title: "Se perderán todos los cambios que no esten guardados",
                  onAccept: () async {
                    Navigator.pop(context);
                  });
            } else {
              Navigator.pop(context);
            }
          }),
    );
  }

  void _borrarPaciente() async {
    showDialogSeguro(
        context: context,
        title: '¿Borrar paciente?',
        ok: 'BORRAR',
        onAccept: () async {
          _setLoading(true);
          await widget.pacienteApi!.delete(widget.paciente!.id!);
          Provider.of<AppState>(context, listen: false)
              .removePacienteAndNotify(widget.paciente);
          _setLoading(false);
          Navigator.of(context).pop();
        });
  }

  void _guardarPaciente() async {
    if (_formKey.currentState!.validate()) {
      _setLoading(true);
      if (isEditing) {
        Paciente res = await widget.pacienteApi!
            .update(pacienteTemp, widget.paciente!.id!);
        Provider.of<AppState>(context, listen: false)
            .updatePacienteAndNotify(widget.paciente!, res);
      } else {
        Paciente res = await widget.pacienteApi!.insert(pacienteTemp);
        Provider.of<AppState>(context, listen: false).addPacienteAndNotify(res);
      }

      _setLoading(false);
      Navigator.of(context).pop();
    }
  }

}
