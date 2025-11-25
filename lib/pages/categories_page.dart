import 'package:R_noteApp/components/color_picker_dialog.dart';
import 'package:R_noteApp/components/category_settings.dart';
import 'package:R_noteApp/models/category.dart';
import 'package:R_noteApp/models/category_database.dart';
import 'package:R_noteApp/models/note_database.dart';
import 'package:R_noteApp/pages/category_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import '../theme/my_colors.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedColor;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Creation de categorie
  void _showCreateCategoryDialog() {
    final categoryDb = context.read<CategoryDatabase>();
    final availableColors = categoryDb.getAvailableColors();

    if (availableColors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Toutes les couleurs sont déjà utilisées'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _nameController.clear();
    _selectedColor = availableColors.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Nouvelle catégorie',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Champ nom avec styles de l’ancien fichier
                TextField(
                  controller: _nameController,
                  maxLength: 20,
                  decoration: InputDecoration(
                    labelText: 'Nom de la catégorie',
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    floatingLabelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Couleur :',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),

                // Sélecteur couleur
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => ColorPickerDialog(
                        availableColors: availableColors,
                        selectedColor: _selectedColor,
                        onColorSelected: (color) {
                          setDialogState(() => _selectedColor = color);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: _selectedColor != null
                          ? Color(int.parse('FF$_selectedColor', radix: 16))
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Choisir une couleur',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _nameController.clear();
                  Navigator.pop(context);
                },
                child: Text(
                  'Annuler',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Le nom ne peut pas être vide'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  final success = await categoryDb.addCategory(
                    _nameController.text,
                    _selectedColor!,
                  );
                  if (!context.mounted) return;

                  if (success) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Catégorie créée avec succès'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ce nom existe déjà'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text(
                  'Créer',
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

  // notification
  void _showEditCategoryDialog(Category category) {
    final categoryDb = context.read<CategoryDatabase>();

    var availableColors = categoryDb.getAvailableColors();
    if (!availableColors.contains(category.colorHex)) {
      availableColors = [category.colorHex, ...availableColors];
    }

    _nameController.text = category.name;
    _selectedColor = category.colorHex;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Modifier la catégorie',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  maxLength: 20,
                  decoration: InputDecoration(
                    labelText: 'Nom de la catégorie',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Couleur :',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => ColorPickerDialog(
                        availableColors: availableColors,
                        selectedColor: _selectedColor,
                        onColorSelected: (color) {
                          setDialogState(() => _selectedColor = color);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(int.parse('FF$_selectedColor', radix: 16)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Changer la couleur',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final success = await categoryDb.updateCategory(
                    category.id,
                    _nameController.text,
                    _selectedColor!,
                  );
                  if (!context.mounted) return;
                  if (success) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Catégorie modifiée'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ce nom existe déjà'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Modifier'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Suppression de catégorie avec confirmation
  void _confirmDelete(Category category) {
    final noteDb = context.read<NoteDatabase>();
    final noteCount = noteDb.countNotesByCategory(category.id);

    final isDefault = category.isDefault;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Supprimer la catégorie'),
        content: Text(
          isDefault
              ? 'Impossible de supprimer une catégorie par défaut.'
              : noteCount > 0
                  ? 'Voulez-vous vraiment supprimer "${category.name}" ?\n\n'
                      '$noteCount note${noteCount > 1 ? "s" : ""} seront détachées de cette catégorie mais ne seront pas supprimées.'
                  : 'Voulez-vous vraiment supprimer "${category.name}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          if (!isDefault)
            ElevatedButton(
              onPressed: () async {
                final success = await context
                    .read<CategoryDatabase>()
                    .deleteCategory(category.id);

                if (!context.mounted) return;
                Navigator.pop(context);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Catégorie supprimée'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Supprimer'),
            ),
        ],
      ),
    );
  }

  // ----------------------------
  //                UI
  // ----------------------------

  @override
  Widget build(BuildContext context) {
    final categoryDb = context.watch<CategoryDatabase>();
    final noteDb = context.watch<NoteDatabase>();
    final categories = categoryDb.currentCategories;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Catégories',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: _showCreateCategoryDialog,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      body: categories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.category_outlined,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune catégorie',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final color =
                    Color(int.parse('FF${category.colorHex}', radix: 16));
                final noteCount =
                    noteDb.countNotesByCategory(category.id); // NEW

                return GestureDetector(
                  onTap: () {
                    // 🔥 Naviguer vers CategoryDetailPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CategoryDetailPage(category: category),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
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
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(
                        category.name,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (category.isDefault)
                            Text(
                              'Catégorie par défaut',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 12,
                              ),
                            ),

                          // 🔥 Nouveau : nombre de notes
                          Text(
                            '$noteCount note${noteCount > 1 ? "s" : ""}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      // 🔥 Nouveau : menu Popover
                      trailing: Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.more_horiz),
                          color: Theme.of(context).colorScheme.secondary,
                          onPressed: () => showPopover(
                            width: 120,
                            height: 110,
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            context: context,
                            bodyBuilder: (context) => CategorySettings(
                              isDefault: category.isDefault,
                              onEditTap: () {
                                Navigator.pop(context);
                                _showEditCategoryDialog(category);
                              },
                              onDeleteTap: () {
                                Navigator.pop(context);
                                _confirmDelete(category);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
