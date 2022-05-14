
import 'package:flutter/material.dart';



// clase para poder pasar un item builder asi customizar la lista de items
typedef ItemBuilder<T> = Widget Function(T item);
// lo necesitamos para poder pasar los objetos genericos por callback
typedef CustomCallback<T> = void Function(T value);

/// Clase que representa una lista de objetos de tipo [T]. 
/// Dado un un widget de tipo Form (que se mostrara en un dialog al darle a añadir)
/// y un objeto de tipo [T] podemos mostrar un fomrulario para crear un objeto 
/// y pasarla por calback meidante el [CustomCallback]
/// Cuando creas la clase los onchange del formulario [form]
/// deben modificar el objeto que se pasa al widget como [objetoTemporal]
/// 
/// En el dialog donde se representa el formulario hay un action de onsumbit donde pasa el objeto 
/// por el callback [onSave] 
/// 
/// El [formKey] debe serl mismo al que se le pone al [form]
/// 
/// El [itemBuilder] y la [listaObjetos] los usamos para representar los objetos
/// 
/// El [objetoTemporal] debe tener la clase wrapper
class FieldListaObjetos<T> extends StatefulWidget{

  List<T> listaObjetos;
  final String title;
  final CustomCallback onSave;    //
  final void Function() onCancel;
  final ItemBuilder<T> itemBuilder;
  final GlobalKey<FormState>? formKey;
  Form form;
  T objetoTemporal;

  FieldListaObjetos({Key? key, 
    required this.title,
    required this.listaObjetos,
    required this.objetoTemporal,
    required this.onSave,           // ???? Por que no dentro
    required this.onCancel,         // ???? Por que no dentro
    required this.itemBuilder,
    required this.form, 
    this.formKey,
  }) : super(key: key);

  @override
  _FieldListaObjetosState<T> createState() => _FieldListaObjetosState<T>();
}

class _FieldListaObjetosState<T> extends State<FieldListaObjetos<T>>{


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: (){
            showDialog(
              barrierDismissible: false,
              context: context, 
              builder: (context){
                return StatefulBuilder(// para que los set state tengan efecto
                  builder: (context, setState) =>  _buildDialog(),
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
            return widget.itemBuilder(
              widget.listaObjetos[index]
            );
        })) 
      ],
    );
  }

  Widget _buildDialog(){
    return Dialog(
        shape: RoundedRectangleBorder( borderRadius:BorderRadius.circular(50.0)), 
        child: Material(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //--------------- TITULO
            Padding(  //TODO Pasar esto al formulario
              padding: const EdgeInsets.fromLTRB(16,16,16,0),
              child: Text(widget.title,style: Theme.of(context).textTheme.titleLarge,),
            ),
            //---------------- BODY
            widget.form,
            //---------------- ACTIONS
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 16),
              child:  _buildDialogActions(),
            )
          ],
        ),
        ) ,

    );
  }

  Widget _buildDialogActions(){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Spacer(),// asi podemos obligar a que vaya a la derecha del todo aun poniendo en la columna superior que empiecen en la izquierda
        ElevatedButton(
          child: const Text("Guardar"),
          onPressed: () {
            // vaciamos el temp para que al volver a añadir salga en blanco y añadimos un clone
            if(widget.formKey == null ){
              widget.onSave.call(widget.objetoTemporal);
              Navigator.pop(context);
            }else{
              if(widget.formKey!.currentState!.validate()){
                widget.onSave.call(widget.objetoTemporal);
                Navigator.pop(context);
              }
            }
          }),
        
        const SizedBox(width: 8,),
        //--------------------------------
        ElevatedButton(
          child: const Text("Cancelar"),
          onPressed: () {
            widget.onCancel.call();
            Navigator.pop(context);
          })
      ],
    );
  }

}
