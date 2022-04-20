import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app.dart';
import '../widgets/profile_widget.dart';
import '../widgets/textfield_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
          // TODO Extraer el loading como widget independiente para poder utilizarlo en otras partes
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
              ProfileWidget(
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

  Future<String> uploadImage(PlatformFile file, String storageName) async {
    //
    print("***************" );
    try {
      TaskSnapshot upload = await FirebaseStorage.instance
          //.ref('users/$storageName.${file.extension}')
          .ref('fichero.png')
          .putBlob(Blob(file.bytes!));
      print("subido" );
      String url = await upload.ref.getDownloadURL();
      print("*************** url " + url);
      return url;
    } catch (e) {
      print('error in uploading image for : ${e.toString()}');
      return '';
    }
  }

  ///
  /// Callback del widget de la foto de perfil
  ///
  void _onChangeFileCallback() async {
      FilePickerResult? result = await FilePicker.platform
              .pickFiles(
                  type: FileType.custom,
                  allowMultiple: false,
                  onFileLoading: (FilePickerStatus status) => {}
                  allowedExtensions: ['jpg', 'png']);

      print("***************" );

      if (result != null) {
        PlatformFile file = result.files.first;
        String url = await uploadImage(file, "poner_uid");
        // Cambiar foto a esta URL
      }


      if (Platform.isAndroid) {
          // android
      }else{
         if (result != null) {
          PlatformFile file = result.files.first;
          //print(file.name);
          //print(file.bytes);
          //print(file.size);
          //print(file.extension);

          // subir la imgen a firestore
          
        } else {
          // cancelado
        }
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