import 'package:flutter/material.dart';

/// Se incluyen diferentes Widgets que se usan en formularios

Widget Button(
    String title,
    IconData? icon,
    VoidCallback onPressed  ) =>
    Container(//    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 16),
      constraints: BoxConstraints(minWidth: 300, maxWidth: 400),
      //constraints: null,
      child: ElevatedButton(
          onPressed: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children:  [
                  Text(title),
                  SizedBox(width: 10),
                  if(icon!=null) Icon(icon)
                ]),
          )),
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

