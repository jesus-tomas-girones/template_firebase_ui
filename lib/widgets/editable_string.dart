// Este Widget ha sido copiado de Firebase UI  https://firebase.flutter.dev/docs/ui/overview/

// Muestra un texto con un botón de editar.
// Al pulsar el botón, permite editarlo
// Si no tiene nombre aparece en modo edición
// Se han añadifo los ficheros subtitle y plataform_widget

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

//import 'third_party/subtitle.dart';

//Se le pasa un string con un texto y un callback con las acciones a hacer cuando cambie

class EditableString extends StatefulWidget {
  final String? text; // Texto de entrada
//  final void Function(String text)? onChange; //CallBack cuando se cambie
  final Future Function(String text)? onChange;
  final String? labelText; // Etiqueta del campo que se edita o hint
  final String? explanationText; // Instrucciones para el campo
  final TextStyle? textStyle;

  const EditableString({
    Key? key,
    this.text,
    this.onChange,
    this.labelText,
    this.explanationText,
    this.textStyle,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _EditableString createState() => _EditableString();
}

class _EditableString extends State<EditableString> {
  String? get text => widget.text;
  String? get labelText => widget.labelText;

  //TextStyle? get textStyle => widget.textStyle;

  //late final ctrl = TextEditingController(text: text ?? '');
  late final ctrl = TextEditingController(text: widget.text ?? '');

  late bool _editing = text == null;
  bool _isLoading = false;

  void _onEdit() {
    setState(() {
      _editing = true;
    });
  }

  Future<void> _finishEditing() async {
    try {
      if (text == ctrl.text) return;
      setState(() {
        _isLoading = true;
      });
//////////////////////////////////////////////////////// Nuevo
// Llamos al callBach
      if (widget.onChange != null) {
        await widget.onChange!(ctrl.text);
      }
//////////////////////////////////////////////////////// Nuevo
    } finally {
      setState(() {
        _editing = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //final l = FlutterFireUILocalizations.labelsOf(context);
    final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;

    late Widget iconButton;

    if (isCupertino) {
      iconButton = Transform.translate(
        offset: Offset(0, _editing ? -12 : 0),
        child: CupertinoButton(
          onPressed: _editing ? _finishEditing : _onEdit,
          child: Icon(
            _editing ? CupertinoIcons.check_mark_circled : CupertinoIcons.pen,
          ),
        ),
      );
    } else {
      iconButton = IconButton(
        icon: Icon(_editing ? Icons.check : Icons.edit),
        color: theme.colorScheme.secondary,
        onPressed: _editing ? _finishEditing : _onEdit,
      );
    }

    var _textStyle = widget.textStyle;
    if (_textStyle == null) {
      if (isCupertino) {
        _textStyle = CupertinoTheme.of(context).textTheme.navTitleTextStyle;
      } else {
        _textStyle = Theme.of(context).textTheme.subtitle1;
      }
    }

    if (!_editing) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.5),
        child: IntrinsicWidth(
          child: Row(
            children: [
              Text(text ?? "Unknown", style: _textStyle),
              //Subtitle(text: text ?? 'Unknown'),
              iconButton,
            ],
          ),
        ),
      );
    }
    late Widget textField;

    if (isCupertino) {
      textField = Padding(
        padding: const EdgeInsets.symmetric(vertical: 17.5),
        child: CupertinoTextField(
          autofocus: true,
          controller: ctrl,
          placeholder: labelText, //l.name,
          onSubmitted: (_) => _finishEditing(),
        ),
      );
    } else {
      textField = TextField(
        autofocus: true,
        controller: ctrl,
        decoration: InputDecoration(hintText: labelText, labelText: labelText),
        onSubmitted: (_) => _finishEditing(),
      );
    }

    var _text = widget.explanationText ?? "";
    return Column(
    children:[
      Text(_text),
      Row(
      children: [
        Expanded(child: textField),
        const SizedBox(width: 8),
        SizedBox(
          width: 50,
          height: 32,
          child: Stack(
            children: [
              if (_isLoading)
                const LoadingIndicator(size: 24, borderWidth: 1)
              else
                Align(
                  alignment: Alignment.topLeft,
                  child: iconButton,
                ),
            ],
          ),
        ),
      ],
    ),
    ],
    );
  }
}
