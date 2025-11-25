import 'package:R_noteApp/components/my_drawer_tile.dart';
import 'package:R_noteApp/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Header plus élégant avec dégradé
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Column(
              children: [
                // Icône dans un cercle
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.edit_note_rounded,
                    size: 40,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                const SizedBox(height: 15),
                // Titre de l'app
                Text(
                  "Mes Notes",
                  style: GoogleFonts.dmSerifText(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Organisez vos idées",
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Note tile
          MyDrawerTile(
            text: "Notes",
            icon: Icons.note_outlined,
            onTap: () => Navigator.pop(context),
          ),

          // Settings tile
          MyDrawerTile(
            text: "Paramètres",
            icon: Icons.settings_outlined,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(),
                ),
              );
            },
          ),

          const Spacer(),

          // Footer avec version
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Version 1.0.0",
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
