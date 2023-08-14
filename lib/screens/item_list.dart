import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';
import 'package:shopping_list/models/shop_item.dart';
import 'package:shopping_list/models/shop_person.dart';
import 'package:shopping_list/tools/database_helper.dart';
import 'package:shopping_list/tools/my_tools.dart';
import 'package:shopping_list/widgets/amount_selector.dart';
import 'package:shopping_list/widgets/item_tile.dart';
import 'package:shopping_list/widgets/slidable_delete.dart';

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  late DatabaseHelper dbPovider;
  late Future<List<ShoppingItem>> futureItems;

  FocusNode nameFocus = FocusNode();
  FocusNode priceFocus = FocusNode();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final amountController = TextEditingController(text: "1");
  String belongsTo = "";

  Future<List<ShoppingItem>> getFutureItems() async {
    return await dbPovider.getItems();
  }

  @override
  void initState() {
    super.initState();
    dbPovider = Provider.of<DatabaseHelper>(context, listen: false);
    futureItems = getFutureItems();
  }

  @override
  void dispose() {
    super.dispose();

    // dispose focus node
    nameFocus.dispose();
    priceFocus.dispose();

    // dispose controller
    nameController.dispose();
    priceController.dispose();
    amountController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final people = dbPovider.people;
    return Scaffold(
      body: people.isEmpty
          ? const Center(child: Text("請先新增購買人", style: TextStyle(fontSize: 30)))
          : Column(
              children: [
                // add item space
                SizedBox(
                  height: 190,
                  child: buildInputField(),
                ),
                // Divider
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 12.0),
                  color: Colors.grey,
                ),
                // total consumption
                Container(
                  margin: const EdgeInsets.all(4.0),
                  child: buildTotalConsumption(),
                ),
                // Divider
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 12.0),
                  color: Colors.grey,
                ),
                // item list view
                Expanded(
                  child: buildFutureItemList(),
                ),
              ],
            ),
    );
  }

  Widget buildTotalConsumption() {
    return Consumer<DatabaseHelper>(
      builder: (context, db, child) {
        final items = dbPovider.items;
        final totalConsumption = items.fold(
            0.0, ((previousValue, element) => previousValue + element.total));
        return Text(
          "全部總計: ${MyTools.moneySymbol(totalConsumption)}",
          style: const TextStyle(fontSize: 20),
        );
      },
    );
  }

  void addItem() {
    // create item
    final item = ShoppingItem(
      id: 0, // auto generated
      name: nameController.text,
      price: double.tryParse(priceController.text) ?? -1,
      amount: int.tryParse(amountController.text) ?? -1,
      selected: true,
      belongsTo: belongsTo,
    );

    // check if item is valid
    if (!isItemValid(item)) {
      MyTools.info(context, "輸入有誤");
      return;
    }

    // reset controller
    nameController.clear();
    priceController.clear();
    amountController.text = "1";

    // save item to database
    dbPovider.addItem(item);
  }

  bool isItemValid(ShoppingItem item) {
    if (item.name.isEmpty) {
      return false;
    }
    if (item.price == -1 || item.amount == -1) {
      return false;
    }
    return true;
  }

  Widget buildFutureItemList() {
    return FutureBuilder(
      future: futureItems,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else {
            return buildItemList();
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget buildItemList() {
    return Consumer<DatabaseHelper>(
      builder: (context, db, child) {
        final items = List.of(db.items);
        final people = db.people;
        if (items.isEmpty) {
          return const Center(
            child: Text(
              "尚未加入任何商品",
              style: TextStyle(fontSize: 30),
            ),
          );
        }
        // add header tile for each buyer
        final buyers = items.map((e) => e.belongsTo).toSet();
        for (String buyer in buyers) {
          items.add(ShoppingItem(
            id: -1,
            name: "",
            price: -1,
            amount: -1,
            selected: false,
            belongsTo: buyer,
          ));
        }
        // return grouped list
        return GroupedListView<ShoppingItem, ShoppingPerson>(
          elements: items,
          groupBy: (item) => people.firstWhere((p) => p.name == item.belongsTo),
          groupComparator: (p1, p2) => p1.name.compareTo(p2.name),
          useStickyGroupSeparators: true,
          physics: const BouncingScrollPhysics(),
          groupSeparatorBuilder: (person) {
            return buildGroupSeparator(person);
          },
          itemComparator: (item1, item2) {
            return item1.id.compareTo(item2.id);
          },
          itemBuilder: (context, item) {
            return ItemTile(
              key: ValueKey(item.id),
              item: item,
              isHeader: item.id == -1,
            );
          },
        );
      },
    );
  }

  Widget buildGroupSeparator(ShoppingPerson person) {
    final personItems =
        dbPovider.items.where((element) => element.belongsTo == person.name);
    final consumption = personItems.fold(0.0, ((previousValue, element) {
      return previousValue + element.total;
    }));

    return SlidableDelete(
      fadeOut: false,
      onDeletePressed: () {
        // remove all items of the buyer
        for (var item in personItems) {
          dbPovider.removeItem(item);
        }
      },
      child: Container(
        color: Colors.grey[300],
        child: Row(
          children: [
            // check box (select all)
            Checkbox(
              value: person.selectAll,
              onChanged: (newVal) {
                // update selectAll
                dbPovider.updatePersonSelectAll(person, newVal!);
                // make all sub checkbox to newVal
                for (var element in personItems) {
                  dbPovider.updateItemSelected(element, newVal);
                }
              },
            ),
            // name
            Expanded(
                child: Text(person.name, style: const TextStyle(fontSize: 20))),
            // person consumption
            SizedBox(
              width: 150,
              child: Text(
                "總計: ${MyTools.moneySymbol(consumption)}",
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInputField() {
    final pList = dbPovider.people;
    belongsTo = pList.first.name;
    return Container(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
      child: Column(
        children: [
          // choose buyer
          Expanded(
            child: buildBuyerSection(pList),
          ),
          // name, price, amount row
          Expanded(
            child: buildDataInputSection(),
          ),
          // add button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: buildAddButton(),
          ),
        ],
      ),
    );
  }

  Widget buildBuyerSection(List<ShoppingPerson> pList) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "購買人",
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 10),
        buildBuyerDropdown(pList),
      ],
    );
  }

  StatefulBuilder buildBuyerDropdown(List<ShoppingPerson> pList) {
    return StatefulBuilder(
      builder: (context, setState) {
        return DropdownButton<String>(
          alignment: AlignmentDirectional.center,
          value: belongsTo,
          items: pList
              .map(
                (e) => DropdownMenuItem(
                  value: e.name,
                  child: Text(e.name, style: const TextStyle(fontSize: 20)),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => belongsTo = value);
          },
        );
      },
    );
  }

  Widget buildDataInputSection() {
    return Row(
      children: [
        // name
        Expanded(
          child: TextField(
            controller: nameController,
            focusNode: nameFocus,
            decoration: const InputDecoration(
              label: Text("品名"),
            ),
          ),
        ),

        // space
        const SizedBox(width: 10),

        // price
        Expanded(
          child: TextField(
            controller: priceController,
            focusNode: priceFocus,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              label: Text("單價"),
              prefixText: MyTools.symbol,
            ),
          ),
        ),

        // space
        const SizedBox(width: 10),

        // amount
        Expanded(
          child: AmountSelector(
            controller: amountController,
            title: Text(
              "數量",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildAddButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // unfocus text fields
          nameFocus.unfocus();
          priceFocus.unfocus();

          // add item
          addItem();
        },
        child: const Text(
          "加入",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
