import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app.dart';
import '../utils/firestore_utils.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/textfield_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';

//TODO Quitar este fichero

class EditUserProfileScreen extends StatefulWidget {
  const EditUserProfileScreen({Key? key}) : super(key: key);

  @override
  _EditUserProfileScreenState createState() => _EditUserProfileScreenState();
}

class _EditUserProfileScreenState extends State<EditUserProfileScreen> {
  
  final _formKey = GlobalKey<FormState>();

  // variables del formulario
  String _nombre = "";

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<AppState>(context, listen: false).user;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Perfil"),
        automaticallyImplyLeading: true,
        // leading es el icono de la izquierda
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context),),
        ),
      body: Stack(
        children: [
          _buildForm(_user),
         
          if (_isLoading) const Opacity(opacity: 0.1, child: ModalBarrier(dismissible: false, color: Colors.black),),
          if (_isLoading) const Center( child: CircularProgressIndicator(),),
          
        ],
      )
    );
  }

  ///
  /// Formulario del usuario
  ///
  Widget _buildForm(User? _user){
    return Form(
            key: _formKey,
            child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 24),
              AvatarWidget(
                imagePath: _user!.photoURL ?? "",
                isEdit: true,
                onClicked: _onChangeFileCallback
              ),
              const SizedBox(height: 24),
              // clase propia creada en la carpeta widgets
              TextFieldWidget(
                label: 'Nombre',
                text: _user.displayName ?? "",
                onChanged: (nombre){
                  _nombre = nombre;
                },
                validator: (name) {
                  if(name!.trim().isEmpty){
                    return "El nombre no puede ser vacío";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                      child: const Text("Guardar"),
                      onPressed: _btnGuardarCallback,
                    ),
              ],
            ),
          );
  }

  

  ///
  /// Callback del widget de la foto de perfil
  ///
  void _onChangeFileCallback() async {
      
      String uid = Provider.of<AppState>(context,listen: false).user!.uid;
      
      FilePickerResult? result = await FilePicker.platform
              .pickFiles(
                  type: FileType.custom,
                  allowMultiple: false,
                  onFileLoading: (FilePickerStatus status) => {},
                  allowedExtensions: ['jpg', 'png']);

      print("*************** CALLBACK" );

      if (result != null) {
        String url = await uploadFile(result.files.first,"users/"+uid);
        // imagen subida, camnbiarla al usuario
        if(url != ""){
          print("*************** url: "+url );
          FirebaseAuth.instance.currentUser!.updatePhotoURL(url).then((value) {
             print("*************** ACTUALIZAR USER UI" );
            Provider.of<AppState>(context,listen: false).updateUserAndNotify(FirebaseAuth.instance.currentUser);
          });
        }
         
      }else{
        print("*************** RESULT NULL" );
      }
                 
  }

  ///
  /// Callback del boton de guardar del formulario del perfil
  ///
  void _btnGuardarCallback(){
    var validationSucces = _formKey.currentState!.validate();
    if (validationSucces) {
      // Antes de leer los datos del fomr, debemos guardar el formulario
      _formKey.currentState!.save(); // fuerza a todos los on save del form
      setState(() {
        _isLoading = true;
      });
      // TODO Pasar esto a un sitio con mas sentido (un objeto de la parte de api que sea el user)
      FirebaseAuth.instance.currentUser?.updateDisplayName(_nombre)
      .then((value){
          Provider.of<AppState>(context,listen: false).updateUserAndNotify(FirebaseAuth.instance.currentUser);
          setState(() {
            _isLoading = false;
          });
          Navigator.pop(context);// volver atras
      })
      // TODO mostrar el error en un sanck bar o similar
      .onError((error, stackTrace) {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

}