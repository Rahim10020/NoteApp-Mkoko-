import 'package:R_noteApp/components/my_drawer.dart';
import 'package:R_noteApp/components/note_tile.dart';
import 'package:R_noteApp/models/note.dart';
import 'package:R_noteApp/models/note_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    readNote();
  }

  // create note
  void createNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
        ),
        actions: [
          //  cancel button
          MaterialButton(
            onPressed: () {
              textController.clear();
              Navigator.pop(context);
            },
            child: const Text("cancel"),
          ),
          // create button
          MaterialButton(
            onPressed: () {
              // add to the database
              context.read<NoteDatabase>().addNote(textController.text);
              textController.clear();
              Navigator.pop(context);
            },
            child: const Text("create"),
          ),
        ],
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Update note"),
        content: TextField(
          controller: textController,
        ),
        actions: [
          // cancel button
          MaterialButton(
            onPressed: () {
              textController.clear();
              Navigator.pop(context);
            },
            child: const Text("cancel"),
          ),
          // update button
          MaterialButton(
            onPressed: () {
              // we gonna prefill the controller with the text we wanna update
              context
                  .read<NoteDatabase>()
                  .updateNote(note.id, textController.text);
              // clear the textfield
              textController.clear();
              // now we gonna pop the dialog box
              Navigator.pop(context);
            },
            child: const Text("update"),
          ),
        ],
      ),
    );
  }

  // delete note
  void deleteNote(int id) {
    context.read<NoteDatabase>().deleteNote(id);
  }

  @override
  Widget build(BuildContext context) {
    // note database
    final noteDatabase = context.watch<NoteDatabase>();
    // current Notes
    List<Note> currentNotes = noteDatabase.currentNotes;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: createNote,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      drawer: MyDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // heading
          Padding(
            padding: const EdgeInsets.only(left: 17.0),
            child: Text(
              "Notes",
              style: GoogleFonts.dmSerifText(
                  fontSize: 40,
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
          ),
          // list of notes
          Expanded(
            child: ListView.builder(
              itemCount: currentNotes.length,
              itemBuilder: (context, index) {
                // get individual note
                final note = currentNotes[index];
                // return a list tile
                return NoteTile(
                  text: note.text,
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
