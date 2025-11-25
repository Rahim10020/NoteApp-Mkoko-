import 'package:isar/isar.dart';

// this line is needed to generate the file
// then run: dart run build_runner build
part 'note.g.dart';

@Collection()
class Note {
  Id id = Isar.autoIncrement;
  late String text;
  // Date de création
  late DateTime createdAt;
  // Date de dernière modification
  late DateTime updatedAt;
}
