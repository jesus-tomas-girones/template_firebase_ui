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
  final GlobalKey<FormState>? formKey;
  final void Function()? onChange; // El vaciar no hace efecto en el padre (No se vacia el formulario al guardar), por tanto mediante un callback avisamos que ha cambiado y hacemos un setState
  final double padding;
  //ValueChanged<void Function(void Function())> onSetStateInitialiced;

  //void Function(void Function())? setStateDialog;

  EditorListaObjetos({Key? key,
    required this.titulo,
    required this.listaObjetos,
    required this.objetoTemporal,
    required this.elementoLista,
    required this.formulario,
    this.formKey, // para poder validar el formulario
    this.onChange, 
    this.padding = 16,
    //required this.onSetStateInitialiced,
  }) : super(key: key);

  @override
  _EditorListaObjetosState<T> createState() => _EditorListaObjetosState<T>();
}

class _EditorListaObjetosState<T> extends State<EditorListaObjetos<T>>{

  bool _mostrarForm = false;

  void mostrarForm(bool value){
    setState(() {
       _mostrarForm = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(widget.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.titulo),
              ElevatedButton(
                onPressed: (){
                  mostrarForm(!_mostrarForm);
                }, 
                child: const Text("Añadir")
              ),
            ],
          ),
          ListView.builder(
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.listaObjetos.length,
            itemBuilder: ((context, index) {
              return widget.elementoLista(
                widget.listaObjetos[index]
              );
          })),
          _mostrarForm ? _buildForm() : const Center() 
        ],
      ),
    );
  }

  Widget _buildForm(){
    return Material( 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Colors.grey, width: 1),
      ),
      child: Column(
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
                        if(widget.formKey!=null){
                          if(widget.formKey!.currentState!.validate()){
                             widget.listaObjetos.add((widget.objetoTemporal as ClonableVaciable).clone());
                            (widget.objetoTemporal as ClonableVaciable).vaciar();
                          }
                        }else{
                          widget.listaObjetos.add((widget.objetoTemporal as ClonableVaciable).clone());
                          (widget.objetoTemporal as ClonableVaciable).vaciar();
                        }
                         widget.onChange!=null ? widget.onChange!.call() :null; // avisar al padre para que repinte
                         mostrarForm(false);
                      });
                    }),
                const SizedBox(width: 8,),
                ElevatedButton(
                    child: const Text("Cancelar"),
                    onPressed: () {
                      (widget.objetoTemporal as ClonableVaciable).vaciar();
                      widget.onChange!=null ? widget.onChange!.call() :null;// avisar al padre para que repinte
                      mostrarForm(false);
                    })
              ],
            ),
          )
        ],
      ),
    );
  }

}
