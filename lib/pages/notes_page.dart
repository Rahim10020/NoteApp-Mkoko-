import 'package:R_noteApp/components/category_chip.dart';
import 'package:R_noteApp/components/my_drawer.dart';
import 'package:R_noteApp/components/note_tile.dart';
import 'package:R_noteApp/models/category_database.dart';
import 'package:R_noteApp/models/note.dart';
import 'package:R_noteApp/models/note_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/my_colors.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final textController = TextEditingController();
  final searchController = TextEditingController();
  bool isSearching = false;
  int? selectedCategoryId;
  bool isImportant = false;

  @override
  void initState() {
    super.initState();
    readNote();
  }

  @override
  void dispose() {
    textController.dispose();
    searchController.dispose();
    super.dispose();
  }

  // create note - avec catégorie et important
  void createNote() {
    selectedCategoryId = null;
    isImportant = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final categoryDb = context.watch<CategoryDatabase>();
          final categories = categoryDb.currentCategories;

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
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Champ texte
                  TextField(
                    controller: textController,
                    maxLines: 5,
                    maxLength: 500,
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
                  const SizedBox(height: 16),

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
                  const SizedBox(height: 8),

                  // Sélection de catégorie
                  Text(
                    "Catégorie :",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Option "Aucune"
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedCategoryId = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: selectedCategoryId == null
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          child: Text(
                            'Aucune',
                            style: TextStyle(
                              color: selectedCategoryId == null
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.secondary,
                              fontWeight: selectedCategoryId == null
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      ...categories.map((category) {
                        return CategoryChip(
                          category: category,
                          isSelected: selectedCategoryId == category.id,
                          onTap: () {
                            setDialogState(() {
                              selectedCategoryId = category.id;
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  textController.clear();
                  selectedCategoryId = null;
                  isImportant = false;
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
                        categoryId: selectedCategoryId,
                        isImportant: isImportant,
                      );
                  if (!context.mounted) return;
                  if (success) {
                    textController.clear();
                    selectedCategoryId = null;
                    isImportant = false;
                    Navigator.pop(context);
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
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Créer",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // read note
  void readNote() {
    context.read<NoteDatabase>().fetchNotes();
  }

  // update note
  void updateNote(Note note) {
    textController.text = note.text;
    selectedCategoryId = note.categoryId;
    isImportant = note.isImportant;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final categoryDb = context.watch<CategoryDatabase>();
          final categories = categoryDb.currentCategories;

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
            content: SingleChildScrollView(
              child: Column(
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
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 8),
                  Text(
                    "Catégorie :",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedCategoryId = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: selectedCategoryId == null
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          child: Text(
                            'Aucune',
                            style: TextStyle(
                              color: selectedCategoryId == null
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.secondary,
                              fontWeight: selectedCategoryId == null
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      ...categories.map((category) {
                        return CategoryChip(
                          category: category,
                          isSelected: selectedCategoryId == category.id,
                          onTap: () {
                            setDialogState(() {
                              selectedCategoryId = category.id;
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ],
              ),
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
                        categoryId: selectedCategoryId,
                        isImportant: isImportant,
                      );
                  if (!context.mounted) return;
                  if (success) {
                    textController.clear();
                    Navigator.pop(context);
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
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Modifier",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // delete note
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
            onPressed: () {
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
              final success = await context.read<NoteDatabase>().deleteNote(id);
              if (!context.mounted) return;

              Navigator.pop(context);

              if (success) {
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

  void performSearch(String query) {
    context.read<NoteDatabase>().searchNotes(query);
  }

  // Afficher le menu de filtres
  void showFilterMenu() {
    final categoryDb = context.read<CategoryDatabase>();
    final noteDb = context.read<NoteDatabase>();
    final categories = categoryDb.currentCategories;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setBottomSheetState) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filtres',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        noteDb.clearFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Réinitialiser'),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),

                // Filtre Important
                CheckboxListTile(
                  title: Row(
                    children: const [
                      Icon(Icons.star, color: importantColor, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text('Seulement les importantes'),
                      ),
                    ],
                  ),
                  value: noteDb.filterImportant,
                  onChanged: (value) {
                    setBottomSheetState(() {
                      noteDb.filterByImportant(value ?? false);
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 16),

                // Filtres de catégories
                const Text(
                  'Catégories :',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setBottomSheetState(() {
                          noteDb.filterByCategory(null);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: noteDb.filterCategoryId == null
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        child: Text(
                          'Toutes',
                          style: TextStyle(
                            color: noteDb.filterCategoryId == null
                                ? Colors.white
                                : Theme.of(context).colorScheme.secondary,
                            fontWeight: noteDb.filterCategoryId == null
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    ...categories.map((category) {
                      return CategoryChip(
                        category: category,
                        isSelected: noteDb.filterCategoryId == category.id,
                        onTap: () {
                          setBottomSheetState(() {
                            noteDb.filterByCategory(category.id);
                          });
                        },
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteDatabase = context.watch<NoteDatabase>();
    List<Note> currentNotes = noteDatabase.currentNotes;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          // Bouton de recherche
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchController.clear();
                  readNote();
                }
              });
            },
          ),
          // Bouton de filtres
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (noteDatabase.hasActiveFilters)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: deleteColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: showFilterMenu,
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: createNote,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      drawer: const MyDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isSearching)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: searchController,
                onChanged: performSearch,
                decoration: InputDecoration(
                  hintText: "Rechercher une note...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.primary,
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 17.0, top: 10, bottom: 10),
            child: Row(
              children: [
                Text(
                  "Notes",
                  style: GoogleFonts.dmSerifText(
                    fontSize: 40,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${currentNotes.length}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: currentNotes.isEmpty
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
                          isSearching || noteDatabase.hasActiveFilters
                              ? "Aucune note trouvée"
                              : "Aucune note pour le moment",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (!isSearching && !noteDatabase.hasActiveFilters)
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
                    itemCount: currentNotes.length,
                    itemBuilder: (context, index) {
                      final note = currentNotes[index];
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
