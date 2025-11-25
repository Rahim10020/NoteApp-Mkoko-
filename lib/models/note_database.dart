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

  // CREATE
  Future<bool> addNote(String textFromUser) async {
    try {
      // Validation : ne pas créer de note vide
      if (textFromUser.trim().isEmpty) {
        return false;
      }

      // Créer une nouvelle note avec les dates
      final newNote = Note()
        ..text = textFromUser.trim()
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      // Sauvegarder dans la base de données
      await isar.writeTxn(() => isar.notes.put(newNote));
      await fetchNotes();
      return true;
    } catch (e) {
      debugPrint('Erreur lors de la création de la note: $e');
      return false;
    }
  }

  // READ - tri par date (plus récentes en premier)
  Future<void> fetchNotes() async {
    try {
      List<Note> fetchedNotes = await isar.notes
          .where()
          .sortByUpdatedAtDesc() // Tri par date de modification décroissante
          .findAll();
      currentNotes.clear();
      currentNotes.addAll(fetchedNotes);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des notes: $e');
    }
  }

  // UPDATE
  Future<bool> updateNote(int id, String newText) async {
    try {
      // Validation
      if (newText.trim().isEmpty) {
        return false;
      }

      final existingNote = await isar.notes.get(id);
      if (existingNote != null) {
        existingNote.text = newText.trim();
        existingNote.updatedAt = DateTime.now(); // Mise à jour de la date
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

  // DELETE
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

  // SEARCH
  Future<void> searchNotes(String query) async {
    try {
      if (query.trim().isEmpty) {
        await fetchNotes();
        return;
      }

      List<Note> allNotes = await isar.notes.where().findAll();
      List<Note> searchResults = allNotes
          .where(
              (note) => note.text.toLowerCase().contains(query.toLowerCase()))
          .toList();

      // Trier les résultats par date
      searchResults.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      currentNotes.clear();
      currentNotes.addAll(searchResults);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la recherche: $e');
    }
  }
}
