import 'package:file_picker/file_picker.dart';
import 'package:firebase_ui/widgets/avatar_widget.dart';
import 'package:firebase_ui/widgets/cambiar_password_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../utils/firestore_utils.dart';
import '../widgets/editable_string.dart';
import '../widgets/form_miscelanius.dart';

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
          builder: (context, appState, child) =>
              ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 24), // espaciador
                  AvatarWidget(
                      imagePath: appState.user!.photoURL ?? "",
                      onClicked: _onChangeFileCallback
                  ),
                  const SizedBox(height: 24), // espaciador
                  //Align(child: EditableUserDisplayName(user: appState.user)),
                  Align(child: EditableString(
                      text: appState.user!.displayName,
                      labelText: 'nombre',
                      textStyle: const TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.bold),
                      onChange: (text) async {
                        await appState.user?.updateDisplayName(text)
                            .then((value) {
                          Provider.of<AppState>(context, listen: false)
                              .updateUserAndNotify(
                              FirebaseAuth.instance.currentUser);
                        });
                      }
                  )),
                  Align(child: EditableString(
                      text: appState.user!.email,
                      labelText: 'correo',
                      explanationText: 'Para cambiar el correo, primero reinicia sesión',
                      textStyle: const TextStyle(
                          fontSize: 16.0, color: Colors.grey),
                      onChange: (text) async {
                        await appState.user?.updateEmail(text)
                            .then((value) {
                          Provider.of<AppState>(context, listen: false)
                              .updateUserAndNotify(
                              FirebaseAuth.instance.currentUser);
                        });
                      }
                  )),
                  const SizedBox(height: 24),

                  /*_buildSignOut((() {
                    FirebaseAuth.instance.signOut(); // cerrar sesion
                    Navigator.of(context).popUntil(
                        ModalRoute.withName("/")); //Volver a la pagina incial
                  })),
                  const SizedBox(height: 24), */
                  //Align(child: EditableUserDisplayName(user: appState.user)),
                  //_buildName(appState.user),

                  Button("Cerrar sesión", Icons.logout, () {
                    FirebaseAuth.instance.signOut();
                    Navigator.of(context).popUntil(
                        ModalRoute.withName("/")); //Volver a la pagina incial
                  }),

                  Button("Cambiar contraseña", Icons.password, () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(builder: ((context, setState) {
                            return SimpleDialog(children: [
                              CambiarFirebasePasswordWidget(user: appState.user)
                            ],);
                          }));
                        }
                    );
                  }),


/*                  ElevatedButton(onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(builder: ((context, setState) {
                            return SimpleDialog(children: [
                              CambiarFirebasePasswordWidget(user: appState.user)
                            ],);
                          }));
                        }
                    );
                  }, child: const Text("Cambiar contraseña"))*/

                ],
              ),
        ));
  }

  ///
  /// Callback del widget de la foto de perfil
  ///
  void _onChangeFileCallback() async {
    String uid = Provider
        .of<AppState>(context, listen: false).user!.uid;

    FilePickerResult? result = await FilePicker.platform
        .pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        onFileLoading: (FilePickerStatus status) => {},
        allowedExtensions: ['jpg', 'png']);

    if (result != null) {
      String url = await uploadFile(result.files.first,"users/"+uid+"/fotoPerfil/"+result.files.first.name);
      // imagen subida, camnbiarla al usuario
      if (url != "") {
        FirebaseAuth.instance.currentUser!.updatePhotoURL(url).then((value) {
          Provider.of<AppState>(context, listen: false).updateUserAndNotify(
              FirebaseAuth.instance.currentUser);
        });
      }
    } else {
      print("*************** RESULT NULL");
    }
  }
}



Widget _buildSignOut(VoidCallback onPressed) {
  return Container(//    Padding(
    padding: const EdgeInsets.symmetric(horizontal: 64),
    constraints: BoxConstraints(minWidth: 300, maxWidth: 400),
    //constraints: null,
    child: ElevatedButton(

        onPressed: onPressed,

        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("Cerrar Sesion"),
                SizedBox(width: 10),
                Icon(Icons.logout)
              ]),
        )),
  );
}

/*Widget _buildName(var user) =>
    Column(
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
    );*/

