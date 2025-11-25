import 'package:R_noteApp/components/note_tile.dart';
import 'package:R_noteApp/models/category.dart';
import 'package:R_noteApp/models/note.dart';
import 'package:R_noteApp/models/note_database.dart';
import 'package:R_noteApp/theme/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CategoryDetailPage extends StatefulWidget {
  final Category category;

  const CategoryDetailPage({
    super.key,
    required this.category,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  final textController = TextEditingController();
  List<Note> categoryNotes = [];
  bool isImportant = false;

  @override
  void initState() {
    super.initState();
    _loadCategoryNotes();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  // Charger les notes de cette catégorie
  void _loadCategoryNotes() {
    final noteDb = context.read<NoteDatabase>();
    setState(() {
      categoryNotes = noteDb.getNotesByCategory(widget.category.id);
    });
  }

  // Créer une note dans cette catégorie
  void createNote() {
    isImportant = false;
    textController.clear();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              "Nouvelle note",
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info catégorie
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(int.parse('FF${widget.category.colorHex}',
                            radix: 16))
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Color(int.parse('FF${widget.category.colorHex}',
                          radix: 16)),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.category,
                        size: 16,
                        color: Color(int.parse('FF${widget.category.colorHex}',
                            radix: 16)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.category.name,
                        style: TextStyle(
                          color: Color(int.parse(
                              'FF${widget.category.colorHex}',
                              radix: 16)),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Champ texte
                TextField(
                  controller: textController,
                  maxLines: 5,
                  maxLength: 500,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "Écrivez votre note ici...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                const SizedBox(height: 8),

                // Checkbox Important
                CheckboxListTile(
                  title: const Text("Marquer comme important"),
                  value: isImportant,
                  onChanged: (value) {
                    setDialogState(() {
                      isImportant = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  activeColor: importantColor, // Couleur de fond quand coché
                  checkColor: Colors.white, // Couleur de la coche
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  textController.clear();
                  Navigator.pop(context);
                },
                child: Text(
                  "Annuler",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (textController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("La note ne peut pas être vide"),
                        backgroundColor: warningColor,
                      ),
                    );
                    return;
                  }

                  final success = await context.read<NoteDatabase>().addNote(
                        textController.text,
                        categoryId: widget.category.id,
                        isImportant: isImportant,
                      );
                  if (!context.mounted) return;
                  if (success) {
                    textController.clear();
                    Navigator.pop(context);
                    _loadCategoryNotes();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Note créée avec succès"),
                        backgroundColor: successColor,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(
                      int.parse('FF${widget.category.colorHex}', radix: 16)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Créer",
                  style: TextStyle(
                    color: _getTextColor(
                      Color(int.parse('FF${widget.category.colorHex}',
                          radix: 16)),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Modifier une note
  void updateNote(Note note) {
    textController.text = note.text;
    isImportant = note.isImportant;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              "Modifier la note",
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: textController,
                  maxLines: 5,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: "Modifiez votre note...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: const Text("Marquer comme important"),
                  value: isImportant,
                  onChanged: (value) {
                    setDialogState(() {
                      isImportant = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  activeColor: importantColor, // Couleur de fond quand coché
                  checkColor: Colors.white, // Couleur de la coche
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  textController.clear();
                  Navigator.pop(context);
                },
                child: Text(
                  "Annuler",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (textController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("La note ne peut pas être vide"),
                        backgroundColor: warningColor,
                      ),
                    );
                    return;
                  }

                  final success = await context.read<NoteDatabase>().updateNote(
                        note.id,
                        textController.text,
                        categoryId: widget.category.id,
                        isImportant: isImportant,
                      );
                  if (!context.mounted) return;

                  if (success) {
                    textController.clear();
                    Navigator.pop(context);
                    _loadCategoryNotes();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Note modifiée avec succès"),
                        backgroundColor: successColor,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(
                      int.parse('FF${widget.category.colorHex}', radix: 16)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Modifier",
                  style: TextStyle(
                    color: _getTextColor(
                      Color(int.parse('FF${widget.category.colorHex}',
                          radix: 16)),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Supprimer une note
  void deleteNote(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Confirmer la suppression",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Êtes-vous sûr de vouloir supprimer cette note ? Cette action est irréversible.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Annuler",
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await context.read<NoteDatabase>().deleteNote(id);
              if (!context.mounted) return;
              Navigator.pop(context);

              if (success) {
                _loadCategoryNotes();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Note supprimée"),
                    backgroundColor: deleteColor,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: deleteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Supprimer",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor =
        Color(int.parse('FF${widget.category.colorHex}', radix: 16));

    // Écouter les changements dans la base de données
    context.watch<NoteDatabase>();
    _loadCategoryNotes();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: categoryColor,
        foregroundColor: _getTextColor(categoryColor),
        elevation: 0,
        title: Text(
          widget.category.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _getTextColor(categoryColor),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: createNote,
        backgroundColor: categoryColor,
        child: Icon(
          Icons.add,
          color: _getTextColor(categoryColor),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  categoryColor,
                  categoryColor.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.category,
                      color: _getTextColor(categoryColor),
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.category.name,
                        style: GoogleFonts.dmSerifText(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: _getTextColor(categoryColor),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${categoryNotes.length}",
                        style: TextStyle(
                          color: _getTextColor(categoryColor),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  categoryNotes.isEmpty
                      ? "Aucune note"
                      : "${categoryNotes.length} note${categoryNotes.length > 1 ? 's' : ''}",
                  style: TextStyle(
                    color: _getTextColor(categoryColor).withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Liste des notes
          Expanded(
            child: categoryNotes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: 80,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Aucune note dans cette catégorie",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Appuyez sur + pour créer une note",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: categoryNotes.length,
                    itemBuilder: (context, index) {
                      final note = categoryNotes[index];
                      return NoteTile(
                        text: note.text,
                        updatedAt: note.updatedAt,
                        categoryId: note.categoryId,
                        isImportant: note.isImportant,
                        onEditPressed: () => updateNote(note),
                        onDeletePressed: () => deleteNote(note.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
