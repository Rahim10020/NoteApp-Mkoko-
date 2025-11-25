import 'package:R_noteApp/theme/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Paramètres",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section Apparence
          Text(
            "Apparence",
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),

          // Dark mode setting
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.dark_mode_outlined,
                    color: Theme.of(context).colorScheme.inversePrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mode sombre",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Activer le thème sombre",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                CupertinoSwitch(
                  value: Provider.of<ThemeProvider>(context, listen: false)
                      .isDarkMode,
                  onChanged: (value) =>
                      Provider.of<ThemeProvider>(context, listen: false)
                          .toggleThemes(),
                  activeTrackColor:
                      Theme.of(context).colorScheme.inversePrimary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Section À propos
          Text(
            "À propos",
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  context,
                  "Version",
                  "1.0.0",
                  Icons.info_outline,
                ),
                Divider(
                  height: 20,
                  color: Theme.of(context).colorScheme.surface,
                ),
                _buildInfoRow(
                  context,
                  "Développeur",
                  "R_noteApp",
                  Icons.code_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.secondary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
            fontSize: 15,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
