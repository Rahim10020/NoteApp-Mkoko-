import 'package:flutter/material.dart';
import '../theme/my_colors.dart';

class CategorySettings extends StatelessWidget {
  final Function()? onEditTap;
  final Function()? onDeleteTap;
  final bool isDefault;

  const CategorySettings({
    super.key,
    required this.onEditTap,
    required this.onDeleteTap,
    required this.isDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // edit button
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            onEditTap!();
          },
          child: Container(
            height: 50,
            color: Theme.of(context).colorScheme.surface,
            child: Center(
              child: Text(
                "Edit",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        // delete button - désactivé si catégorie par défaut
        GestureDetector(
          onTap: isDefault
              ? null
              : () {
                  Navigator.pop(context);
                  onDeleteTap!();
                },
          child: Container(
            height: 50,
            color: Theme.of(context).colorScheme.surface,
            child: Center(
              child: Text(
                "Delete",
                style: TextStyle(
                  color: isDefault
                      ? Theme.of(context).colorScheme.secondary
                      : deleteColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
