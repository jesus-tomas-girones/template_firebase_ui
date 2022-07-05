
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<String> uploadFile(PlatformFile file, String storageRef) async {
    //
    try {
      print("upload file en storage: "+storageRef);
      TaskSnapshot upload;
      if(kIsWeb){
        upload = await FirebaseStorage.instance
                  .ref(storageRef)
                  .putData(file.bytes!);
        
      }else{ // ver si en ios es igual a android
        upload = await FirebaseStorage.instance
                  .ref(storageRef)
                  .putFile(File(file.path!));
      }
      
      String url = await upload.ref.getDownloadURL();
      return url;
    } catch (e) {
      print('error in uploading image for : ${e.toString()}');
      return '';
    }
  }

 Future<bool> deleteFile(String urlRef) async {
    try{
      print('se va a borrar : $urlRef');
      Reference ref = FirebaseStorage.instance.refFromURL(urlRef);
      await ref.delete();
      return true;
    }catch(e){
      return false;
    }
    // Rebuild the UI
  }




  // obtenemos los ficheros de una colecciones de firebase que contienen un url y un nombre, ademas tambien lo borramos de storage
  void borrarColeccionDeFirebaseFirestore(String colleccion) async{
     // ficheros adjuntos
    try{
      print("COLECCION: "+colleccion);
      var querySnapshot = await FirebaseFirestore.instance.collection(colleccion).get();
      List<dynamic> ficheros = querySnapshot.docs.map((doc) => doc.data()).toList(); //[{url:string,nombre:string}]
      for(var fichero in ficheros){
          _borrarFichero(colleccion, fichero["url"], fichero.id);
      }
    }catch(e){
       print("Error al borrar coleccion de firebase y firestore: "+e.toString());
    }
  }

  ///
  /// Callbcak borrar fichero
  ///
  void _borrarFichero(firebaseColeccion,urlStorage,idColeccion) async{
    

      
      // borrar de firestore
      await FirebaseFirestore.instance.collection(firebaseColeccion).doc(idColeccion).delete();

      // borrar de storage
      await deleteFile(urlStorage);
    

    }