import 'package:R_noteApp/models/category_database.dart';
import 'package:R_noteApp/models/note_database.dart';
import 'package:R_noteApp/pages/notes_page.dart';
import 'package:R_noteApp/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:R_noteApp/models/note.dart';
import 'package:R_noteApp/models/category.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Isar avec les deux schémas (Note et Category)
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [NoteSchema, CategorySchema],
    directory: dir.path,
  );

  // Assigner l'instance Isar aux databases
  NoteDatabase.isar = isar;
  CategoryDatabase.isar = isar;

  // Créer l'instance de CategoryDatabase et initialiser les catégories par défaut
  final categoryDatabase = CategoryDatabase();
  await categoryDatabase.initializeDefaultCategories();

  runApp(
    MultiProvider(
      providers: [
        // Theme provider
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
        // Note database provider
        ChangeNotifierProvider(
          create: (context) => NoteDatabase(),
        ),
        // Category database provider
        ChangeNotifierProvider.value(
          value: categoryDatabase,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const NotesPage(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
