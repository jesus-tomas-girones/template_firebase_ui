import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

//TODO Quitar este fichero

class UserProfileUiScreen extends StatelessWidget {
  const UserProfileUiScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen(
      providerConfigs: [
        EmailProviderConfiguration(),
        GoogleProviderConfiguration(clientId:"334675337000-dcamtv5qiodg6v92pa2jm7bi2ht68b0g.apps.googleusercontent.com"),
        AppleProviderConfiguration(),
      ],
      avatarSize: 128,
    );
  }
}