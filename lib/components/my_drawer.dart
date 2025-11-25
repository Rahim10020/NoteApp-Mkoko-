import 'package:R_noteApp/components/my_drawer_tile.dart';
import 'package:R_noteApp/pages/categories_page.dart';
import 'package:R_noteApp/pages/settings_page.dart';
import 'package:R_noteApp/theme/my_colors.dart';
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
          // Header avec dégradé
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor,
                  primaryColor.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit_note_rounded,
                    size: 40,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "Mes Notes",
                  style: GoogleFonts.dmSerifText(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Organisez vos idées",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
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

          // Categories tile
          MyDrawerTile(
            text: "Catégories",
            icon: Icons.category_outlined,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoriesPage(),
                ),
              );
            },
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
                  builder: (context) => const SettingsPage(),
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
