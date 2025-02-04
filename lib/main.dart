import 'package:flutter/material.dart';
import 'package:my_first_project/models/note_database.dart';
import 'package:my_first_project/pages/notes_page.dart';
import 'package:my_first_project/theme/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  // we gonna initialize isar note database
  WidgetsFlutterBinding.ensureInitialized();
  await NoteDatabase.initialize();
  runApp(
    MultiProvider(
      providers: [
        // theme provider
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
        // note databaseProvider
        ChangeNotifierProvider(
          create: (context) => NoteDatabase(),
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
