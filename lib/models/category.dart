import 'package:isar/isar.dart';

part 'category.g.dart';

@Collection()
class Category {
  Id id = Isar.autoIncrement;
  late String name;
  late String colorHex; // Couleur au format hex (ex: "FF6B6B")
  late bool isDefault; // true pour les catégories par défaut (non supprimables)
  late DateTime createdAt;
}
