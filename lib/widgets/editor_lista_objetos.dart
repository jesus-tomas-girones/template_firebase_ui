import 'package:flutter/material.dart';

/// Clase que representa un objeto que puede ser clonado y vaciado
/// Los objetos que queramos editar han de impementar este interfaz

abstract class ClonableVaciable {
  clone() => ClonableVaciable;
  vaciar();
}

// clase para poder pasar un item builder asi customizar la lista de items
typedef ItemBuilder<T> = Widget Function(T item);

/// Clase que representa una lista de objetos de tipo [T]. 
/// Dado un un widget de tipo Form (que se mostrara en un dialog al darle a añadir)
/// y un objeto de tipo [T] podemos mostrar un fomrulario para crear un objeto
/// El [elementoLista] representa un objeto en la lista

class EditorListaObjetos<T> extends StatefulWidget{

  List<T> listaObjetos;
  final String titulo;
  final ItemBuilder<T> elementoLista; //Para construir el Widget de cada elemento de la lista
  Form formulario;
  T objetoTemporal; // Objeto que se está editando. Se usa para poder acceder a el desde el form

  ValueChanged<void Function(void Function())> onSetStateInitialiced;

  //void Function(void Function())? setStateDialog;

  EditorListaObjetos({Key? key,
    required this.titulo,
    required this.listaObjetos,
    required this.objetoTemporal,
    required this.elementoLista,
    required this.formulario,
    required this.onSetStateInitialiced,
  }) : super(key: key);

  @override
  _EditorListaObjetosState<T> createState() => _EditorListaObjetosState<T>();
}

class _EditorListaObjetosState<T> extends State<EditorListaObjetos<T>>{

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.titulo),
        ElevatedButton(
          onPressed: (){
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return  Dialog(
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      widget.onSetStateInitialiced(setState);
                      return otra();}
                 ),
/*              return _buildDialog();
                  return StatefulBuilder(// para que los set state tengan efecto
                  builder: (context, setState) {
                    widget.onSetStateInitialiced(setState);
//                    widget.setStateDialog=setState;
                    return _buildDialog(/*setState*/);
                  }*/
                );
              }
            ); 
          }, 
          child: const Text("Añadir")
        ),
        ListView.builder(
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.listaObjetos.length,
          itemBuilder: ((context, index) {
            return widget.elementoLista(
              widget.listaObjetos[index]
            );
        })) 
      ],
    );
  }

  Widget otra() =>
//      Dialog(
//        shape: RoundedRectangleBorder( borderRadius:BorderRadius.circular(50.0)),
  //      child:
  Material( child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.formulario,
            //---------------- ACTIONS
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Spacer(),// asi podemos obligar a que vaya a la derecha del todo aun poniendo en la columna superior que empiecen en la izquierda
                  ElevatedButton(
                      child: const Text("Guardar"),
                      onPressed: () {
                        // vaciamos el temp para que al volver a añadir salga en blanco y añadimos un clone
                        setState(() {
                          widget.listaObjetos.add((widget.objetoTemporal as ClonableVaciable).clone());
                          (widget.objetoTemporal as ClonableVaciable).vaciar();
                        });
                        Navigator.pop(context);
                      }),

                  const SizedBox(width: 8,),
                  ElevatedButton(
                      child: const Text("Cancelar"),
                      onPressed: () {
                        (widget.objetoTemporal as ClonableVaciable).vaciar();
                        Navigator.pop(context);
                      })
                ],
              ),
            )
          ],
        ),
  );

  Widget _buildDialog(/*setState*/) =>
     Dialog(
        shape: RoundedRectangleBorder( borderRadius:BorderRadius.circular(50.0)), 
        child: Material( child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.formulario,
            //---------------- ACTIONS
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Spacer(),// asi podemos obligar a que vaya a la derecha del todo aun poniendo en la columna superior que empiecen en la izquierda
                  ElevatedButton(
                      child: const Text("Guardar"),
                      onPressed: () {
                        // vaciamos el temp para que al volver a añadir salga en blanco y añadimos un clone
                          setState(() {
                            widget.listaObjetos.add((widget.objetoTemporal as ClonableVaciable).clone());
                            (widget.objetoTemporal as ClonableVaciable).vaciar();
                          });
                          Navigator.pop(context);
                      }),

                  const SizedBox(width: 8,),
                  ElevatedButton(
                      child: const Text("Cancelar"),
                      onPressed: () {
                        (widget.objetoTemporal as ClonableVaciable).vaciar();
                        Navigator.pop(context);
                      })
                ],
              ),
            )
          ],
        ), ) ,
    );

}
