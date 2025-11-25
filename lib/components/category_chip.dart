import 'package:R_noteApp/models/category.dart';
import 'package:flutter/material.dart';
import '../theme/my_colors.dart';

class CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse('FF${category.colorHex}', radix: 16));
    // Determiner si c'est le mode clair
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // Vérifier si la couleur est jaune (vous pouvez ajuster cette condition)
    final isYellow = category.colorHex.toUpperCase() == 'FFE66D' ||
        category.name.toLowerCase() == 'études';
    // Utiliser noir en mode clair pour la catégorie jaune
    final displayColor =
        (!isDarkMode && isYellow) ? etudeBackgroundColor : color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : displayColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.check,
                  size: 16,
                  color: _getTextColor(color),
                ),
              ),
            Text(
              category.name,
              style: TextStyle(
                color: isSelected ? _getTextColor(color) : color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Déterminer la couleur du texte en fonction de la luminosité du fond
  Color _getTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
