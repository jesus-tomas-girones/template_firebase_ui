
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<String> uploadFile(PlatformFile file, String storageRef) async {
    //
    print("***************" );
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
      
      print("subido" );
      String url = await upload.ref.getDownloadURL();
      print("*************** url " + url);
      return url;
    } catch (e) {
      print('error in uploading image for : ${e.toString()}');
      return '';
    }
  }