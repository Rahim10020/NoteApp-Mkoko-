import 'package:isar/isar.dart';

// this line is needed to generate the file
// then run: dart run build_runner build
part 'note.g.dart';

@Collection()
class Note {
  Id id = Isar.autoIncrement;
  late String text;

  // Date de création et de modification
  late DateTime createdAt;
  late DateTime updatedAt;

  // Catégorie (nullable car une note peut ne pas avoir de catégorie)
  int? categoryId;

  // Marqueur important (indépendant de la catégorie)
  late bool isImportant;
}
