// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../widgets/dialogs.dart';
import '../widgets/third_party/adaptive_scaffold.dart';
import 'dashboard.dart';
import 'entries.dart';
import 'user_profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    //print(widget.photoUrl);
    return AdaptiveScaffold(
      title: const Text('Template con Firebase'),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<AppState>(
            builder: (context, appState, child) {
              return Text(appState.user!.displayName!);
              //TODO: usar operador elvis ?:
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserProfileScreen()),
              ); //TODO botón para volver, al cerrar in sign_in
            },
            child: Consumer<AppState>(builder: (context, appState, child) {
              String? url = appState.user!.photoURL;
              if (url == null) {
                return const CircleAvatar(child: Icon(Icons.person));
              } else {
                return CircleAvatar(backgroundImage: NetworkImage(url));
              }
              //TODO al pasar el ratón pone el nombre flotante (POCO IMPORTANTE)
            }),
          ),
        ),
      ],
      currentIndex: _pageIndex,
      destinations: const [
        AdaptiveScaffoldDestination(title: 'Home', icon: Icons.home),
        AdaptiveScaffoldDestination(title: 'Entries', icon: Icons.list),
        AdaptiveScaffoldDestination(title: 'Settings', icon: Icons.settings),
      ],
      body: _pageAtIndex(_pageIndex),
      onNavigationIndexChange: (newIndex) {
        setState(() {
          _pageIndex = newIndex;
        });
      },
      floatingActionButton:
          _hasFloatingActionButton ? _buildFab(context) : null,
    );
  }

  bool get _hasFloatingActionButton {
    if (_pageIndex == 2) return false;
    return true;
  }

  FloatingActionButton _buildFab(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () => _handleFabPressed(),
    );
  }

  void _handleFabPressed() {
    if (_pageIndex == 0) {
      showDialog<NewCategoryDialog>(
        context: context,
        builder: (context) => const NewCategoryDialog(),
      );
      return;
    }
    if (_pageIndex == 1) {
      showDialog<NewEntryDialog>(
        context: context,
        builder: (context) => const NewEntryDialog(),
      );
      return;
    }
  }

/*  Future<void> _handleSignOut() async {
    var shouldSignOut = await (showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    ));
    if (shouldSignOut == null || !shouldSignOut) {
      return;
    }
    widget.onSignOut();
  }*/

  static Widget _pageAtIndex(int index) {
    if (index == 0) {
      return const DashboardPage(); //Center(child: Text('Dashboard page'));
    }
    if (index == 1) {
      return const EntriesPage(); //Center(child: Text('Entries page'));
    }
    return const UserProfileScreen(); //Center(child: Text('Settings page'));
  }
}
