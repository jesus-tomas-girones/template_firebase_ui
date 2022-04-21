import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
///
/// Widget que consiste de un boton que al darle lanza 
/// un dialog con un formulario para cambiar la contraseña
/// Que recibe la contraseña antigua y devuelve la nueva contraseña en el callback
/// onSuccess si pasa todas las validaciones
///
class CambiarFirebasePasswordWidget extends StatefulWidget {
  final User? user;

  const CambiarFirebasePasswordWidget({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _CambiarFirebasePasswordWidgetState createState() => _CambiarFirebasePasswordWidgetState();
}

class _CambiarFirebasePasswordWidgetState extends State<CambiarFirebasePasswordWidget> {
  // un controller de texto y un booleano para ver si se esta editando o no el campo
  // en dart los tipos primitivos se pasan por valor por lo que si se hace un set state no hace referencia al mismo valor
  // la solucion que dan es crear un objeto wraper para que asi si se pase como referencia
  final TextEditingController controllerAntigua = TextEditingController();
  final BooleanWraper _isPasswordVisibleAntigua = BooleanWraper(false);

  final TextEditingController controllerNueva = TextEditingController();
  final BooleanWraper _isPasswordVisibleNueva = BooleanWraper(false);

  final TextEditingController controllerRepetir = TextEditingController();
  final BooleanWraper _isPasswordVisibleRepetir = BooleanWraper(false);

  bool _isLoading = false;
  bool _isExito = false; // para bloquear los inputs pero nos mostrar la carga
  String _mensajeErrorFirebase = "";

  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controllerAntigua.dispose();
    controllerNueva.dispose();
    controllerRepetir.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Padding (padding: const EdgeInsets.all(24),child:_buildForm()),
        //if (_isLoading) const Opacity(opacity: 0.1, child: ModalBarrier(dismissible: false, color: Colors.black),),
        if (_isLoading) const Center( child: CircularProgressIndicator(),),
      ],
    );
  }
  
  ///
  /// Formulario 
  ///
  Widget _buildForm(){
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // antigua contraseña
          ///////////////////////////////////////////
          _buildPassTextField("Antigua contraseña","",_isPasswordVisibleAntigua, controllerAntigua,
            // validator
            (value){
              if(value!.trim().isEmpty){
                return "El campo no puede estar vacío";
              }
              return null;
            }),

          const SizedBox(height: 24,),

          // nueva contraseña
          ///////////////////////////////////////////
          _buildPassTextField("Nueva contraseña","",_isPasswordVisibleNueva, controllerNueva,
            // validator
              (value){
                if(value!.trim().isEmpty){
                  return "El campo no puede estar vacío";
                }
                if(value == controllerAntigua.text){
                  return "No puede ser igual que la contraseña antigua";
                }
                return null;
              }),
          const SizedBox(height: 24,),
          _buildPassTextField("Repetir nueva contraseña","",_isPasswordVisibleRepetir, controllerRepetir,
            // validator
            (value){
              if(value!.trim().isEmpty){
                  return "El campo no puede estar vacío";
              }
              if(controllerNueva.text != controllerRepetir.text){
                return "Debe coincidir con la nueva contraseña";
              }
              return null;
            }
            ),
          const SizedBox(height: 24,),

          Text(_mensajeErrorFirebase),
          _mensajeErrorFirebase != "" ? const SizedBox(height: 24,) : const SizedBox(height: 1,), 

          ElevatedButton(
            child: const Text("Cambiar contraseña"),
            // si esta cargando el boton no hace nada
            onPressed: _isLoading || _isExito ? null : () async{
              // si esta todo correcto devolver por el callback la nueva contraseña y la antigua
              if(_formKey.currentState!.validate()){
                // poner en modo carga el dialog
                setState(() {
                  _mensajeErrorFirebase = "";
                  _isLoading = true;
                });
                //cambiar contraseña
                bool isExito = await _changePassword(controllerAntigua.text, controllerNueva.text, widget.user);
                
                // parar la carga y mostrar mensaje
                setState(() {
                    _mensajeErrorFirebase = _mensajeErrorFirebase;
                    _isLoading = false;
                    _isExito = isExito;
                });
                if(isExito){
                    // si hay exito un delay de x segundos y salir
                    await Future.delayed(const Duration(milliseconds: 1000)).then((value) {
                      Navigator.pop(context);
                    });
                    
                }
                
              }
            },
          )
        ],
      ),  
    );
  }
  
  ///
  /// Funcion que crea un campo de texto de tipo password
  /// recibe el controllador del input y un booleano que controla la visibilidad de la contraseña
  ///
  Widget _buildPassTextField( String labelText, String hintText,
   BooleanWraper isPasswordVisible, TextEditingController controller, String? Function(String?)? validator){

    return TextFormField(
        keyboardType: TextInputType.text,
        controller: controller,
        enabled: !_isLoading && !_isExito,
        validator: validator,
        obscureText: !isPasswordVisible.value,//This will obscure text dynamically
        decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            // Here is key idea
            suffixIcon: IconButton(
                  icon: Icon(
                    // Based on passwordVisible state choose the icon
                    isPasswordVisible.value
                    ? Icons.visibility
                    : Icons.visibility_off,
                    color: Theme.of(context).primaryColorDark,
                    ),
                  onPressed: () {
                    // Update the state i.e. toogle the state of passwordVisible variable
                    setState(() {
                        isPasswordVisible.value= !isPasswordVisible.value;
                    });
                  },
                  ),
                ),
        );


  }



   // funcion para cambiar la contraseña
  Future<bool> _changePassword(String antiguaPassword,String nuevaPassword, User? user) async {
    
   
    setState(() {
      _isLoading = true;
      _mensajeErrorFirebase = "";
    });

    String? email = user!.email;
    bool isExito = false;
    try {
      // saber si la antigua contraseña es la correcta
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email!,
          password: antiguaPassword,
      );
      // si los credenciales son correctos cambiar la contraseña
      isExito = await user.updatePassword(nuevaPassword).then((_){
       
        _mensajeErrorFirebase = "Contraseña cambiada correctamente";
        return true;

      }).catchError((error){

          _mensajeErrorFirebase = "Password can't be changed" + error.toString();
          return false;
      
        //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
      });

      return isExito;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
      
          _mensajeErrorFirebase = 'No user found for that email.';
          isExito = false;
      } else if (e.code == 'wrong-password') {
          _mensajeErrorFirebase = 'Wrong password provided for that user.';
          isExito = false;
      }else{
         _mensajeErrorFirebase = 'Error desconocido';
         isExito = false;
      }
    }
  
    return isExito;
  }


}

// Clase para poder pasar un booleano como referencia
class BooleanWraper {
  bool value;
  BooleanWraper(this.value);
}