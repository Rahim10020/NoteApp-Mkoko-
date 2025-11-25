import 'package:R_noteApp/components/note_settings.dart';
import 'package:R_noteApp/models/category_database.dart';
import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/my_colors.dart';

class NoteTile extends StatelessWidget {
  final String text;
  final DateTime updatedAt;
  final int? categoryId;
  final bool isImportant;
  final Function()? onEditPressed;
  final Function()? onDeletePressed;

  const NoteTile({
    super.key,
    required this.text,
    required this.updatedAt,
    this.categoryId,
    required this.isImportant,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  String _getPreviewText() {
    if (text.length > 80) {
      return '${text.substring(0, 80)}...';
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final categoryDb = context.watch<CategoryDatabase>();

    // Obtenir la couleur de la catégorie
    final categoryColor = categoryDb.getCategoryColor(categoryId);
    final backgroundColor =
        categoryColor ?? Theme.of(context).colorScheme.primary;

    // Calculer la couleur du texte en fonction de la luminosité du fond
    final textColor = _getTextColor(backgroundColor);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            // Icône importante
            if (isImportant)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.star,
                  color: importantColor,
                  size: 20,
                ),
              ),
            Expanded(
              child: Text(
                _getPreviewText(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            _formatDate(updatedAt),
            style: TextStyle(
              color: textColor.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ),
        trailing: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.more_vert,
              color: textColor,
            ),
            onPressed: () => showPopover(
              width: 100,
              height: 100,
              backgroundColor: Theme.of(context).colorScheme.surface,
              context: context,
              bodyBuilder: (context) => NoteSettings(
                onEditTap: onEditPressed,
                onDeleteTap: onDeletePressed,
              ),
            ),
          ),
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
