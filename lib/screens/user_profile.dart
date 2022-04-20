import 'package:file_picker/file_picker.dart';
import 'package:firebase_ui/screens/user_profile_edit.dart';
import 'package:firebase_ui/widgets/avatar_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../utils/firestore_utils.dart';
import '../widgets/third_party/editable_user_display_name.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: const Text("Perfil"),
          automaticallyImplyLeading: true,
          // leading es el icono de la izquierda
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer<AppState>(
          builder: (context, appState, child) => ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 24), // espaciador
              AvatarWidget(
                  imagePath: appState.user!.photoURL ?? "",
                  onClicked: _onChangeFileCallback
                  ),
              const SizedBox(height: 24), // espaciador
              //////////////////////////////////
              Align(child: EditableUserDisplayName(user: appState.user)),

              // if (!appState.user!.emailVerified) ...[

              /////////////////////////////////

              _buildName(appState.user),
              const SizedBox(height: 24),
              _buildSignOut((() {
                FirebaseAuth.instance.signOut(); // cerrar sesion
                Navigator.of(context).popUntil(
                  ModalRoute.withName("/")); //Volver a la pagina incial
              }))
            ],
          ),
        ));
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
                  onFileLoading: (FilePickerStatus status) => {}
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


}

Widget _buildSignOut(VoidCallback onPressed) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 128),
    child: ElevatedButton(
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("Cerrar Sesion"),
                SizedBox(width: 8),
                Icon(Icons.logout)
              ]),
        )),
  );

}

Widget _buildName(var user) => Column(
      children: [
        Text(
          user.displayName ?? "Anonimo",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          user.email ?? "",
          style: const TextStyle(color: Colors.grey),
        )
      ],
    );

