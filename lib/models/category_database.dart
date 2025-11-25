import 'package:R_noteApp/models/category.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

class CategoryDatabase extends ChangeNotifier {
  static late Isar isar;

  // Liste des catégories
  final List<Category> currentCategories = [];

  // Palette de couleurs disponibles (17 couleurs)
  static const List<String> allColors = [
    'FF6B6B', // Personnel
    '4ECDC4', // Travail
    'FFE66D', // Études
    '95E1D3', // Idées
    'FF9F43', // Important
    'F3E8FF',
    'AF83F6',
    'ED6998',
    'FAE7F3',
    'DBF7E7',
    'FFEDD5',
    'FBE7EB',
    'ABC2A1',
    '98DEE1',
    'F5EBE0',
    'E07A5F',
    'F5AC9D',
  ];

  // Initialiser les catégories par défaut
  Future<void> initializeDefaultCategories() async {
    try {
      // Vérifier si des catégories existent déjà
      final count = await isar.categorys.count();

      if (count == 0) {
        // Créer les catégories par défaut
        final defaultCategories = [
          Category()
            ..name = 'Personnel'
            ..colorHex = 'FF6B6B'
            ..isDefault = true
            ..createdAt = DateTime.now(),
          Category()
            ..name = 'Travail'
            ..colorHex = '4ECDC4'
            ..isDefault = true
            ..createdAt = DateTime.now(),
          Category()
            ..name = 'Études'
            ..colorHex = 'FFE66D'
            ..isDefault = true
            ..createdAt = DateTime.now(),
          Category()
            ..name = 'Idées'
            ..colorHex = '95E1D3'
            ..isDefault = true
            ..createdAt = DateTime.now(),
        ];

        await isar.writeTxn(() async {
          for (var category in defaultCategories) {
            await isar.categorys.put(category);
          }
        });
      }

      await fetchCategories();
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation des catégories: $e');
    }
  }

  // CREATE - Créer une nouvelle catégorie
  Future<bool> addCategory(String name, String colorHex) async {
    try {
      if (name.trim().isEmpty) {
        return false;
      }

      // Vérifier si le nom existe déjà
      final existing = currentCategories
          .where((cat) => cat.name.toLowerCase() == name.trim().toLowerCase())
          .toList();

      if (existing.isNotEmpty) {
        return false;
      }

      final newCategory = Category()
        ..name = name.trim()
        ..colorHex = colorHex
        ..isDefault = false
        ..createdAt = DateTime.now();

      await isar.writeTxn(() => isar.categorys.put(newCategory));
      await fetchCategories();
      return true;
    } catch (e) {
      debugPrint('Erreur lors de la création de la catégorie: $e');
      return false;
    }
  }

  // READ - Récupérer toutes les catégories
  Future<void> fetchCategories() async {
    try {
      List<Category> fetchedCategories =
          await isar.categorys.where().sortByCreatedAt().findAll();
      currentCategories.clear();
      currentCategories.addAll(fetchedCategories);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des catégories: $e');
    }
  }

  // UPDATE - Modifier une catégorie
  Future<bool> updateCategory(
      int id, String newName, String newColorHex) async {
    try {
      if (newName.trim().isEmpty) {
        return false;
      }

      final existingCategory = await isar.categorys.get(id);
      if (existingCategory != null) {
        // Vérifier si le nouveau nom existe déjà (sauf si c'est la même catégorie)
        final duplicate = currentCategories
            .where((cat) =>
                cat.id != id &&
                cat.name.toLowerCase() == newName.trim().toLowerCase())
            .toList();

        if (duplicate.isNotEmpty) {
          return false;
        }

        existingCategory.name = newName.trim();
        existingCategory.colorHex = newColorHex;
        await isar.writeTxn(() => isar.categorys.put(existingCategory));
        await fetchCategories();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour de la catégorie: $e');
      return false;
    }
  }

  // DELETE - Supprimer une catégorie
  Future<bool> deleteCategory(int id) async {
    try {
      final category = await isar.categorys.get(id);

      // Ne pas supprimer les catégories par défaut
      if (category != null && category.isDefault) {
        return false;
      }

      await isar.writeTxn(() => isar.categorys.delete(id));
      await fetchCategories();
      return true;
    } catch (e) {
      debugPrint('Erreur lors de la suppression de la catégorie: $e');
      return false;
    }
  }

  // Obtenir les couleurs disponibles (non utilisées)
  List<String> getAvailableColors() {
    final usedColors = currentCategories.map((cat) => cat.colorHex).toSet();
    return allColors.where((color) => !usedColors.contains(color)).toList();
  }

  // Obtenir une catégorie par son ID
  Category? getCategoryById(int? id) {
    if (id == null) return null;
    try {
      return currentCategories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obtenir la couleur d'une catégorie
  Color? getCategoryColor(int? categoryId) {
    final category = getCategoryById(categoryId);
    if (category == null) return null;
    return Color(int.parse('FF${category.colorHex}', radix: 16));
  }
}
