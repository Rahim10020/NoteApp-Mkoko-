import 'package:flutter/material.dart';
import 'package:my_first_project/components/my_drawer_tile.dart';
import 'package:my_first_project/pages/settings_page.dart';

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
            Icons.add,
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
