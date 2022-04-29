import 'package:firebase_ui/widgets/editable_string.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

/// Se incluyen diferentes Widgets que se usan como campos de formulario

Widget CampoTexto(String? valorInicial, String? titulo,
        Future<dynamic> Function(String value)? onChange) =>
    ListTile(
      title: Text(titulo ?? ""),
      subtitle: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: EditableString(
          onChange: onChange,
          text: valorInicial,
          textStyle: const TextStyle(fontSize: 16.0, color: Colors.grey),
        ),
      ),
    );

Widget CampoFecha(DateTime? fecha, String? titulo, BuildContext context,
        Future<dynamic> Function(DateTime value) onChange) =>
    ListTile(
      title: Text(titulo ?? ""),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(width: 8),
          Text(fecha == null
              ? "<fecha desconocida>"
              : intl.DateFormat('dd/MM/yyyy').format(fecha)),
          IconButton(
            icon: const Icon(Icons.edit),
            color: Theme.of(context).colorScheme.secondary,
            onPressed: () {
              showDatePicker(
                context: context,
                initialDate: fecha ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              ).then((value) {
                if (value != null) {
                  onChange(value);
                }
              });
            },
          ),
        ],
      ),
    );

showDialogSeguro({
        required BuildContext context,
        required String title,
        String? cancel,
        String? ok,
        required Future Function() onAccept}) =>
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        actions: [
          TextButton(
            child: Text(cancel ?? 'Cancelar'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text(ok ?? 'Ok'),
            onPressed: () {
              onAccept();
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );

Widget buildLoading() => const Center(child: CircularProgressIndicator());
//TODO revisar si se pone también lo de Opacity
//if (_isLoading) const Opacity(opacity: 0.1, child: ModalBarrier(dismissible: false, color: Colors.black),),
//if (_isLoading) const Center( child: CircularProgressIndicator(),),
