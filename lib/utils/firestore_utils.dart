
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<String> uploadFile(PlatformFile file, String storageRef) async {
    //
    try {
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