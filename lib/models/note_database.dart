import 'package:R_noteApp/models/note.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class NoteDatabase extends ChangeNotifier {
  static late Isar isar;

  // INITIALIZE THE DATABASE
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([NoteSchema], directory: dir.path);
  }

  // list of notes
  final List<Note> currentNotes = [];

  // Filtres actifs
  int? _filterCategoryId;
  bool _filterImportant = false;
  String _searchQuery = '';

  // CREATE - Créer une note
  Future<bool> addNote(
    String textFromUser, {
    int? categoryId,
    bool isImportant = false,
  }) async {
    try {
      if (textFromUser.trim().isEmpty) {
        return false;
      }

      final newNote = Note()
        ..text = textFromUser.trim()
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..categoryId = categoryId
        ..isImportant = isImportant;

      await isar.writeTxn(() => isar.notes.put(newNote));
      await fetchNotes();
      return true;
    } catch (e) {
      debugPrint('Erreur lors de la création de la note: $e');
      return false;
    }
  }

  // READ - Récupérer toutes les notes avec filtres
  Future<void> fetchNotes() async {
    try {
      List<Note> fetchedNotes =
          await isar.notes.where().sortByUpdatedAtDesc().findAll();

      // Appliquer les filtres
      fetchedNotes = _applyFilters(fetchedNotes);

      currentNotes.clear();
      currentNotes.addAll(fetchedNotes);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des notes: $e');
    }
  }

  // UPDATE - Modifier une note
  Future<bool> updateNote(
    int id,
    String newText, {
    int? categoryId,
    bool? isImportant,
  }) async {
    try {
      if (newText.trim().isEmpty) {
        return false;
      }

      final existingNote = await isar.notes.get(id);
      if (existingNote != null) {
        existingNote.text = newText.trim();
        existingNote.updatedAt = DateTime.now();
        existingNote.categoryId = categoryId;
        if (isImportant != null) {
          existingNote.isImportant = isImportant;
        }
        await isar.writeTxn(() => isar.notes.put(existingNote));
        await fetchNotes();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour de la note: $e');
      return false;
    }
  }

  // DELETE - Supprimer une note
  Future<bool> deleteNote(int id) async {
    try {
      await isar.writeTxn(() => isar.notes.delete(id));
      await fetchNotes();
      return true;
    } catch (e) {
      debugPrint('Erreur lors de la suppression de la note: $e');
      return false;
    }
  }

  // Recherche de notes
  Future<void> searchNotes(String query) async {
    _searchQuery = query;
    await fetchNotes();
  }

  // Filtrer par catégorie
  void filterByCategory(int? categoryId) {
    _filterCategoryId = categoryId;
    fetchNotes();
  }

  // Filtrer par important
  void filterByImportant(bool showOnlyImportant) {
    _filterImportant = showOnlyImportant;
    fetchNotes();
  }

  // Réinitialiser tous les filtres
  void clearFilters() {
    _filterCategoryId = null;
    _filterImportant = false;
    _searchQuery = '';
    fetchNotes();
  }

  // Appliquer les filtres
  List<Note> _applyFilters(List<Note> notes) {
    var filtered = notes;

    // Filtre de recherche
    if (_searchQuery.trim().isNotEmpty) {
      filtered = filtered
          .where((note) =>
              note.text.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Filtre de catégorie
    if (_filterCategoryId != null) {
      filtered = filtered
          .where((note) => note.categoryId == _filterCategoryId)
          .toList();
    }

    // Filtre important
    if (_filterImportant) {
      filtered = filtered.where((note) => note.isImportant).toList();
    }

    return filtered;
  }

  // Getters pour les filtres actifs
  int? get filterCategoryId => _filterCategoryId;
  bool get filterImportant => _filterImportant;
  String get searchQuery => _searchQuery;

  // Vérifier si des filtres sont actifs
  bool get hasActiveFilters =>
      _filterCategoryId != null || _filterImportant || _searchQuery.isNotEmpty;
}
