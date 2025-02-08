import 'package:R_noteApp/components/my_drawer_tile.dart';
import 'package:R_noteApp/pages/settings_page.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(children: [
        // we gonna have an Icon for the header
        Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Icon(
            Icons.edit,
            size: 50,
          ),
        ),
        // then we gonna a divider
        Padding(
          padding: const EdgeInsets.all(25.0),
          child: Divider(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        // and the Note tile
        MyDrawerTile(
          text: "N O T E S",
          icon: Icons.note,
          onTap: () => Navigator.pop(context),
        ),
        // and also the settings tile
        MyDrawerTile(
          text: "S E T T I N G S",
          icon: Icons.settings,
          onTap: () {
            // we gonna pop the drawer first
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsPage(),
              ),
            );
          },
        ),
      ]),
    );
  }
}
