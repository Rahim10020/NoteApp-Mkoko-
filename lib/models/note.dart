import 'package:isar/isar.dart';

// this line is needed to generate the file
// then run: dart run build_runner
part 'note.g.dart';

@Collection()
class Note {
  Id id = Isar.autoIncrement;
  late String text;
  late String dummy = '';
}
