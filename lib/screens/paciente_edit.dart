/// Clase que pinta la informacion de un paciente, se puede editar y borrar

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../model/paciente.dart';
import '../api/api.dart';
import '../utils/enum_helpers.dart';
import '../widgets/campos_formulario.dart';

//TODO Al salir preguntar si se pierden los cambios
//TODO Al aceptar un campo, pasar al siguiente

class PacienteEditPage extends StatefulWidget {
  Api<Paciente>? pacienteApi;
  Paciente? paciente; // si es null es para crear

  PacienteEditPage({Key? key, this.paciente,  this.pacienteApi})
      : super(key: key) {
   print(pacienteApi.toString());
   paciente ??= Paciente();
  }

  @override
  _PacienteEditPageState createState() => _PacienteEditPageState();
}

class _PacienteEditPageState extends State<PacienteEditPage> {

  late bool isEditing;
  bool _isLoading = false;

  @override
  void initState() {
    isEditing = widget.paciente!.id  != null;
    super.initState();
  }

  void _setLoading(bool bool) {
    setState(() {
      _isLoading = bool;
    });
  }

  @override
  Widget build(BuildContext context) {
    var paciente = widget.paciente!; //Para acortar
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () => _guardarPaciente(),
      ),
      appBar: _buildAppBar(),
      body: ListView(
        children: [
          const SizedBox( height: 8 ),
          CampoTexto(paciente.nombre, "Nombre",
            (value) async { setState(() { paciente.nombre = value; });}),
          CampoTexto(paciente.apellidos, "Apellidos",
            (value) async { setState(() { paciente.apellidos = value; });}),
          CampoFecha(paciente.fechaNacimiento, "Fecha de nacimiento", context,
            (value) async { setState(() { paciente.fechaNacimiento = value; });}),
          buildDropDown(paciente.sexo,Sexo.values,"Sexo del paciente","Seleccione el sexo",(dynamic value){
            setState(() {
              paciente.sexo = value;
            });
          }),
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
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    return AppBar(
      title:
          !isEditing ? const Text("Añadir Paciente") : const Text("Paciente"),
      automaticallyImplyLeading: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(
            context), //TODO Si hay cambios preguntar si se desea salir
      ),
    );
  }

  void _guardarPaciente() async {
    _setLoading(true);
    if (isEditing) {
      Paciente res = await widget.pacienteApi!.update(widget.paciente!, widget.paciente!.id!);
      Provider.of<PacienteState>(context,listen: false).updatePacienteAndNotify(widget.paciente!,res);

    } else {
      
      Paciente res = await widget.pacienteApi!.insert(widget.paciente!);
      Provider.of<PacienteState>(context,listen: false).addPacienteAndNotify(res);
    }
    Navigator.of(context).pop();
    _setLoading(false);
  }

    /*Widget _buildDropDownSexo(Paciente paciente) {
      return ListTile(
        title: const Text("Sexo"),
        subtitle: DropdownButton<Sexo>(
            hint: const Text("Selecciona el tipo de accidente"),
            value: paciente.sexo,
            onChanged: (value) {
              setState(() {
                paciente.sexo = value;
              });
            },
            items: Sexo.values.map((Sexo classType) {
              return DropdownMenuItem<Sexo>(
                  value: classType, child: Text(getCustomEnumName(classType)));
            }).toList()),
      );
    }*/

}
