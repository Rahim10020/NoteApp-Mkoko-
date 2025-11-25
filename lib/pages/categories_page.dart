import 'package:R_noteApp/components/color_picker_dialog.dart';
import 'package:R_noteApp/models/category.dart';
import 'package:R_noteApp/models/category_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  // Dialog pour créer une nouvelle catégorie
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
                // Champ nom
                TextField(
                  controller: _nameController,
                  maxLength: 20,
                  decoration: InputDecoration(
                    labelText: 'Nom de la catégorie',
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    floatingLabelStyle: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary, // Couleur lors du focus
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // bordure au focus
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

                // Sélecteur de couleur
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
                          setDialogState(() {
                            _selectedColor = color;
                          });
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
                    if (!mounted) return;
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

  // Dialog pour modifier une catégorie
  void _showEditCategoryDialog(Category category) {
    final categoryDb = context.read<CategoryDatabase>();

    // Ajouter la couleur actuelle aux couleurs disponibles
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
                          setDialogState(() {
                            _selectedColor = color;
                          });
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

  // Confirmer la suppression
  void _confirmDelete(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Supprimer la catégorie'),
        content: Text(
          'Voulez-vous vraiment supprimer "${category.name}" ?\n\nLes notes associées ne seront pas supprimées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
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

  @override
  Widget build(BuildContext context) {
    final categoryDb = context.watch<CategoryDatabase>();
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
        backgroundColor: const Color(0xFF3C82F6),
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
                  Icon(
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

                return Container(
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
                    subtitle: category.isDefault
                        ? Text(
                            'Catégorie par défaut',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 12,
                            ),
                          )
                        : null,
                    trailing: category.isDefault
                        ? null
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () =>
                                    _showEditCategoryDialog(category),
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _confirmDelete(category),
                                color: Colors.red,
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
    );
  }
}
