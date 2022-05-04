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
                    : (value![0] != value![0].toUpperCase())
                    ? "La inicial ha de estar en mayúsculas"
                        : null
            ),
            FieldText("Apellidos", paciente.apellidos ,
                (value) => setState(() { paciente.apellidos = value; }),
                hint: "Introduce los apellidos del paciente",
            ),
            FieldDate_(
              "Fecha de nacimiento",
              paciente.fechaNacimiento?? DateTime.now(), //TODO dejar fecha sin indicar
              (value) {setState(() {paciente.fechaNacimiento = value;});},
              context,
            ),

            FieldDate(
              title: "Fecha de nacimiento",
              value: paciente.fechaNacimiento ?? DateTime.now(),
              onChanged: (value) {
                setState(() {
                  paciente.fechaNacimiento = value;
                });
              },
            ),

            buildDropDown(paciente.sexo, Sexo.values, ["Hombre", "Mujer"],
                "Sexo del paciente", "Seleccione el sexo", (dynamic value) {

              setState(() {
                paciente.sexo = value;
              });
            }, null),


            FieldText("Domicilio", paciente.domicilio,
              (value) => setState(() { paciente.domicilio = value; }),
              hint: "Introduce el domicilio del paciente",
            ),
            FieldText("Telefono", paciente.telefono,
                  (value) => setState(() { paciente.telefono = value; }),
              hint: "Introduce el teléfono del paciente",
            ),
            // DNI
            _buildCampoTexto(
                false, paciente.dni ?? "", 1, "DNI", "Introduce ", null,
                (value) async {

              setState(() {
                paciente.dni = value;
              });
            }, null),
            SizedBox(
              height: espacioEntreInputs,
            ),
            // NUSS
            _buildCampoTexto(
                false, paciente.nuss ?? "", 1, "NUSS", "Introduce ", null,
                (value) async {

              setState(() {
                paciente.nuss = value;
              });
            }, null),
            SizedBox(
              height: espacioEntreInputs,
            ),
            // Antecedentes medicos
            _buildCampoTexto(false, paciente.antecedentesMedicos ?? "", 10,
                "Antecedentes Medicos", "Introduce ", null, (value) async {
              //_seHaEditado = true;
              setState(() {
                paciente.antecedentesMedicos = value;
              });
            }, null),
            SizedBox(
              height: espacioEntreInputs,
            ),
            // Ocupacion
            _buildCampoTexto(false, paciente.ocupacion ?? "", 1, "Ocupacion",
                "Introduce ", null, (value) async {
              //_seHaEditado = true;
              setState(() {
                paciente.ocupacion = value;
              });
            }, null),
            SizedBox(
              height: espacioEntreInputs,
            ),
            // Empresa
            _buildCampoTexto(
                false, paciente.empresa ?? "", 1, "Empresa", "Introduce ", null,
                (value) async {
              //_seHaEditado = true;
              setState(() {
                paciente.empresa = value;
              });
            }, null),
          ],
        ));
  }

  // TODO eliminarlo
  Widget _buildCampoTexto(
      bool esObligatorio,
      String? initValue,
      int maxLines,
      String title,
      String hintText,
      String? _mensajeError,
      ValueChanged<String> onChanged,
      String? Function(String?)? validator) {
    return TextFormField(
      onChanged: onChanged,
      validator: validator,
      maxLines: maxLines,
      initialValue: initValue,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        filled: initValue?.isNotEmpty ?? false,
        hintText: hintText,
        label: esObligatorio
            ? RichText(
                text: TextSpan(
                    style: const TextStyle(color: Colors.black54),
                    text: title,
                    children: const [
                    TextSpan(text: '*', style: TextStyle(color: Colors.red))
                  ]))
            : Text(title),
        errorText: _mensajeError,
      ),
    );
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


// TODO cambiar de sitio
class FieldDate extends StatefulWidget {
  final String title;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  const FieldDate({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  _FieldDateState createState() => _FieldDateState();
}

class _FieldDateState extends State<FieldDate> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: TextFormField(
        readOnly: true,
        onTap: () async {
          var newDate = await showDatePicker(
            context: context,
            initialDate: widget.value,
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );

          // Don't change the date if the date picker returns null.
          if (newDate == null) {
            return;
          }

          widget.onChanged(newDate);
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          // Border Label TextBox 1
          labelText: widget.title,
          labelStyle: const TextStyle(
            color: Colors.black54,
          ),
          hintText: intl.DateFormat("dd-MM-yyyy").format(widget.value),

          hintMaxLines: 2,
          hintStyle: const TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
    /*Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
                widget.titulo,
                style: Theme.of(context).textTheme.titleMedium,
              ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 240, 240, 240),
            border: Border.all(color: Colors.black54, width: 1),
            borderRadius: BorderRadius.circular(4.0)
          ),
          child:  Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                    intl.DateFormat("dd-MM-yyyy").format(widget.date),
                    style: Theme.of(context).textTheme.subtitle1,
                  ),

              TextButton(
                child: const Icon(Icons.edit),
                onPressed: () async {
                  var newDate = await showDatePicker(
                    context: context,
                    initialDate: widget.date,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );

                  // Don't change the date if the date picker returns null.
                  if (newDate == null) {
                    return;
                  }

                  widget.onChanged(newDate);
                },
              )
            ],
          ),
        )
      ]
    )*/



  }



}
