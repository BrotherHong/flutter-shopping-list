import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_list/constants/my_color.dart';
import 'package:shopping_list/models/shop_person.dart';
import 'package:shopping_list/tools/database_helper.dart';
import 'package:shopping_list/widgets/slidable_delete.dart';

class PersonTile extends StatefulWidget {
  final ShoppingPerson person;

  const PersonTile({super.key, required this.person});

  @override
  State<PersonTile> createState() => _PersonTileState();
}

class _PersonTileState extends State<PersonTile> {
  @override
  Widget build(BuildContext context) {
    return SlidableDelete(
      onDeletePressed: () {
        final dbProvider = Provider.of<DatabaseHelper>(context, listen: false);
        dbProvider.removePerson(widget.person);
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(
            widget.person.name,
            style: const TextStyle(fontSize: 20),
          ),
          leading: const Icon(
            Icons.person,
            color: MyColor.main,
          ),
        ),
      ),
    );
  }

  /*
  
   */

  void deletePerson(BuildContext context) {
    final dbProvider = Provider.of<DatabaseHelper>(context, listen: false);
    // remove all items shopped by this person
    final items = dbProvider.items;
    items
        .where((element) => element.belongsTo == widget.person.name)
        .forEach((item) => dbProvider.removeItem(item));
    // remove person
    dbProvider.removePerson(widget.person);
  }
}
