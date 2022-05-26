import 'package:flutter/material.dart';

import 'form_miscelanius.dart';

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
  final String? titulo;
  final String tituloAnyadir;
  final ItemBuilder<T> elementoLista; //Para construir el Widget de cada elemento de la lista
  T objetoTemporal; // Objeto que se está editando. //TODO sería interesante eliminar este parámetro y crear el objeto en la clase
  final GlobalKey<FormState>? formKey;
  final void Function()? onChange; // El vaciar no hace efecto en el padre (No se vacia el formulario al guardar), por tanto mediante un callback avisamos que ha cambiado y hacemos un setState
  final double padding;
  final Form Function(T item) crearFormulario; 
  //ValueChanged<void Function(void Function())> onSetStateInitialiced;
  //void Function(void Function())? setStateDialog;

  EditorListaObjetos({Key? key,
    this.titulo,
    required this.listaObjetos,
    required this.objetoTemporal,
    required this.elementoLista,
    required this.crearFormulario,
    this.formKey, // para poder validar el formulario
    this.onChange, 
    this.tituloAnyadir = "Añadir nuevo elemento",
    this.padding = 16,
  }) : super(key: key);

  @override
  _EditorListaObjetosState<T> createState() => _EditorListaObjetosState<T>();
}

class _EditorListaObjetosState<T> extends State<EditorListaObjetos<T>>{

  bool _formCrearAbierto = false; // El formulario para Añadir elemento está abierto
  int _indiceFormAbierto = -1; // Índice de formulario de edición Abierto. -1 si ninguno.

  //T objetoTemporal = newObject();

  @override
  void initState() {
    super.initState();
  }

  void mostrarFormCrear(bool value){
    setState(() {
       _formCrearAbierto = value;
    });
  }

  void mostrarFormEdicion(int indice){
    setState(() {
       _indiceFormAbierto = indice;
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
              if(widget.titulo!=null)Text(widget.titulo!),
              ElevatedButton(
                // si no hay on pressed se desactiva el boton (sale en gris)
                onPressed: _indiceFormAbierto == -1 ? (){
                  mostrarFormCrear(!_formCrearAbierto);
                } : null, 
                child: const Text("Añadir")
              ),
            ],
          ),
          widget.listaObjetos.isNotEmpty 
          ? ListView.separated(
              separatorBuilder: (context, index) => const Divider(),
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.listaObjetos.length,
              itemBuilder: ((context, index) {
                return Column(
                  children: [
                    InkWell(
                      // onTap en null equivale a desavilitarlo
                      onTap: !_formCrearAbierto ?  (){
                          if (_indiceFormAbierto == index || _indiceFormAbierto != -1){
                            // cerramos el formulario
                            mostrarFormEdicion(-1); 
                          } else {
                            mostrarFormEdicion(index); 
                          }
                      } : null,
                      child: _buildItemList(index),
                    ),
                    if (_indiceFormAbierto == index) Container(
                        color:const Color.fromARGB(255, 225, 225, 225),
                        child: widget.crearFormulario(widget.listaObjetos[index]),
                    )
                  ],
                );
            }))
          :  const Padding(padding: EdgeInsets.all(16), child: Center(child:Text("No hay elementos")),),
          _formCrearAbierto ? Column(children: [const SizedBox(height: 16),_buildForm()],) : const Center() 
        ],
      ),
    );
  }

  Widget _buildItemList(index){
    return Row( 
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(flex: 12,child: widget.elementoLista(widget.listaObjetos[index])),
        Flexible(
          flex: 1,
          child: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: (){
              showDialogSeguro(context: context, title: "¿Borrar el elemento?",
                onAccept: () async{
                  setState(() {
                    widget.listaObjetos.removeAt(index);
                  });
                });
          },
        ),),
      ],
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
          // ----------- Titulo formulario
          if(widget.tituloAnyadir!=null) Padding(padding: const EdgeInsets.fromLTRB(16,16,16,0),
              child: Text(widget.tituloAnyadir, style: Theme.of(context).textTheme.titleMedium,),
          ),
          // --------------- Formulario
          widget.crearFormulario(widget.objetoTemporal),
          //---------------- Botones
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Spacer(),// asi podemos obligar a que vaya a la derecha del tódo aun poniendo en la columna superior que empiecen en la izquierda
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
                         mostrarFormCrear(false);
                      });
                    }),
                const SizedBox(width: 8,),
                ElevatedButton(
                    child: const Text("Cancelar"),
                    onPressed: () {
                      (widget.objetoTemporal as ClonableVaciable).vaciar();
                      widget.onChange!=null ? widget.onChange!.call() :null;// avisar al padre para que repinte
                      mostrarFormCrear(false);
                    })
              ],
            ),
          )
        ],
      ),
    );
  }

}
