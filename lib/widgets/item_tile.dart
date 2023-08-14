import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_list/models/shop_item.dart';
import 'package:shopping_list/models/shop_person.dart';
import 'package:shopping_list/tools/database_helper.dart';
import 'package:shopping_list/tools/my_tools.dart';
import 'package:shopping_list/widgets/slidable_delete.dart';
import 'package:shopping_list/widgets/tappable.dart';

class ItemTile extends StatelessWidget {
  final ShoppingItem item;
  final bool isHeader;

  const ItemTile({
    super.key,
    required this.item,
    required this.isHeader,
  });

  @override
  Widget build(BuildContext context) {
    final dbProvider = Provider.of<DatabaseHelper>(context, listen: false);
    final person =
        dbProvider.people.firstWhere((p) => p.name == item.belongsTo);
    final items = dbProvider.items;

    const rightPadding = 20.0;
    final boxWidth = (MediaQuery.of(context).size.width - rightPadding) / 5;

    return SlidableDelete(
      enabled: isHeader ? false : true,
      onDeletePressed: () {
        dbProvider.removeItem(item);
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            // check box
            buildCheckbox(boxWidth, dbProvider, items, person),
            // item name
            buildName(boxWidth),
            // item price
            buildPrice(context, boxWidth),
            // item amount
            buildAmount(context, boxWidth),
            // item total
            buildTotal(boxWidth),
          ],
        ),
      ),
    );
  }

  Widget buildCheckbox(double boxWidth, DatabaseHelper dbProvider,
      List<ShoppingItem> items, ShoppingPerson person) {
    return Container(
      alignment: Alignment.center,
      width: boxWidth - 25,
      child: Opacity(
        opacity: isHeader ? 0 : 1,
        child: Checkbox(
          value: item.selected,
          onChanged: (newVal) async {
            if (isHeader) return;
            // update checkbox to new value
            await dbProvider.updateItemSelected(item, newVal!);
            // update selectAll checkbox if all items are selected
            bool allSelected = items
                .where((element) => element.belongsTo == person.name)
                .every((element) => element.selected);
            dbProvider.updatePersonSelectAll(person, allSelected);
          },
        ),
      ),
    );
  }

  Widget buildName(double boxWidth) {
    return Container(
      alignment: Alignment.center,
      width: boxWidth,
      child: Text(
        isHeader ? "品名" : item.name,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  Widget buildPrice(BuildContext context, double boxWidth) {
    return Tappable(
      onTap: () => editPrice(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        width: boxWidth + 20,
        child: Container(
          alignment: isHeader ? Alignment.center : Alignment.centerRight,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: isHeader ? null : Colors.grey[200],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            isHeader ? "單價" : MyTools.moneySymbol(item.price),
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }

  Widget buildAmount(BuildContext context, double boxWidth) {
    return Tappable(
      onTap: () => editAmount(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        width: boxWidth,
        child: Container(
          alignment: isHeader ? Alignment.center : Alignment.centerRight,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: isHeader ? null : Colors.grey[200],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            isHeader ? "數量" : item.amount.toString(),
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }

  Widget buildTotal(double boxWidth) {
    return Container(
      alignment: isHeader ? Alignment.center : Alignment.centerRight,
      width: boxWidth + 5,
      child: Text(
        isHeader ? "小計" : MyTools.moneySymbol(item.total),
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  void editPrice(BuildContext context) async {
    final dbProvider = Provider.of<DatabaseHelper>(context, listen: false);
    // show dialog
    double? newVal = await showDialog<double>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text("修改單價"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              label: Text("新單價"),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                double newVal = double.tryParse(controller.text) ?? item.price;
                Navigator.of(context).pop(newVal);
              },
              child: const Text("OK"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
    // save to database
    if (newVal == null) return;
    dbProvider.updateItemPrice(item, newVal);
  }

  void editAmount(BuildContext context) async {
    final dbProvider = Provider.of<DatabaseHelper>(context, listen: false);
    // show dialog
    int? newVal = await showDialog<int>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text("修改數量"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              label: Text("新數量"),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                int newVal = int.tryParse(controller.text) ?? item.amount;
                Navigator.of(context).pop(newVal);
              },
              child: const Text("OK"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
    // save to database
    if (newVal == null) return;
    dbProvider.updateItemAmount(item, newVal);
  }
}
