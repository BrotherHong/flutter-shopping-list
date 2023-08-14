import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:shopping_list/models/shop_person.dart';
import 'package:shopping_list/models/shop_item.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper extends ChangeNotifier {
  // make it Singleton
  DatabaseHelper._privateConstructor();
  static final _instance = DatabaseHelper._privateConstructor();

  factory DatabaseHelper() => _instance;

  static Database? _database;

  // in-app memory
  List<ShoppingPerson> _people = [];
  List<ShoppingPerson> get people => _people;

  List<ShoppingItem> _items = [];
  List<ShoppingItem> get items => _items;

  // database getter
  Future<Database> get database async => _database ??= await _initDb();

  // file and table name constant
  static const dbFile = "shopping_list.db";
  static const personTable = "shopping_person";
  static const itemTable = "shopping_item";

  static const version = 1;

  // initialize database
  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final filePath = join(dbPath, dbFile);

    return await openDatabase(
      filePath,
      version: version,
      onCreate: _onDbCreate,
    );
  }

  // what to do when database first create
  void _onDbCreate(Database db, int version) {
    // create shopping person table
    db.execute("""CREATE TABLE $personTable (
      ${ShoppingPerson.nameField} TEXT PRIMARY KEY,
      ${ShoppingPerson.selectAllField} INTEGER
    )
    """);

    // create shopping item table
    db.execute("""CREATE TABLE $itemTable (
      ${ShoppingItem.idField} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${ShoppingItem.nameField} TEXT,
      ${ShoppingItem.priceField} REAL,
      ${ShoppingItem.amountField} INTEGER,
      ${ShoppingItem.selectedField} INTEGER,
      ${ShoppingItem.belongField} TEXT
    )
    """);
  }

  /*
   * Shopping Person
   */

  // add shopping person
  Future<void> addPerson(ShoppingPerson person) async {
    final db = await database;

    await db
        .insert(
      personTable,
      person.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    )
        .then((value) {
      _people.add(person);
      notifyListeners();
    });
  }

  // update person
  Future<void> updatePerson(
      ShoppingPerson person, ShoppingPerson newPerson) async {
    final db = await database;

    db.update(
      personTable,
      newPerson.toMap(),
      where: "${ShoppingPerson.nameField} = ?",
      whereArgs: [person.name],
    ).then((value) {
      int index = _people.indexWhere((p) => p.name == person.name);
      _people[index] = newPerson;
      notifyListeners();
    });
  }

  // update person selectall
  Future<void> updatePersonSelectAll(
      ShoppingPerson person, bool selectAll) async {
    // create new person
    final newPerson = ShoppingPerson(
      name: person.name,
      selectAll: selectAll,
    );

    // update person
    await updatePerson(person, newPerson);
  }

  // remove shopping person
  Future<void> removePerson(ShoppingPerson person) async {
    final db = await database;

    await db.delete(
      personTable,
      where: "${ShoppingPerson.nameField} = ?",
      whereArgs: [person.name],
    ).then((value) {
      _people.removeWhere((p) => p.name == person.name);
      notifyListeners();
    });
  }

  // get all shopping person
  Future<List<ShoppingPerson>> getAllPerson() async {
    final db = await database;

    // get all data as a list of map
    List<Map<String, dynamic>> result = await db.query(personTable);

    // mapping each element to ShoppingPerson
    List<ShoppingPerson> personList =
        result.map((p) => ShoppingPerson.fromMap(p)).toList();

    _people = personList;

    return personList;
  }

  // has person (name)
  bool hasPerson(String name) {
    return _people.indexWhere((p) => p.name == name) != -1;
  }

  /*
   * Shopping Item
   */

  // add shopping item
  Future<void> addItem(ShoppingItem item) async {
    final db = await database;

    await db
        .insert(
      itemTable,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    )
        .then((id) {
      final newItem = ShoppingItem(
        id: id,
        name: item.name,
        price: item.price,
        amount: item.amount,
        selected: item.selected,
        belongsTo: item.belongsTo,
      );
      _items.add(newItem);
      notifyListeners();
    });
  }

  // update item
  Future<void> updateItem(ShoppingItem item, ShoppingItem newItem) async {
    final db = await database;

    await db.update(
      itemTable,
      newItem.toMap(),
      where: "${ShoppingItem.idField} = ?",
      whereArgs: [item.id],
    ).then((value) {
      int index = _items.indexWhere((element) => element.id == item.id);
      _items[index] = newItem;
      notifyListeners();
    });
  }

  // update shopping item's price
  Future<void> updateItemPrice(ShoppingItem item, double newPrice) async {
    // create new item
    final newItem = ShoppingItem(
      id: item.id,
      name: item.name,
      price: newPrice,
      amount: item.amount,
      selected: item.selected,
      belongsTo: item.belongsTo,
    );

    await updateItem(item, newItem);
  }

  // update shopping item's amount
  Future<void> updateItemAmount(ShoppingItem item, int newAmount) async {
    // create new item
    final newItem = ShoppingItem(
      id: item.id,
      name: item.name,
      price: item.price,
      amount: newAmount,
      selected: item.selected,
      belongsTo: item.belongsTo,
    );

    await updateItem(item, newItem);
  }

  // update shopping item's selected
  Future<void> updateItemSelected(ShoppingItem item, bool newSelected) async {
    // create new item
    final newItem = ShoppingItem(
      id: item.id,
      name: item.name,
      price: item.price,
      amount: item.amount,
      selected: newSelected,
      belongsTo: item.belongsTo,
    );

    await updateItem(item, newItem);
  }

  // remove shopping item
  Future<void> removeItem(ShoppingItem item) async {
    final db = await database;

    await db.delete(
      itemTable,
      where: "${ShoppingItem.idField} = ?",
      whereArgs: [item.id],
    ).then((value) {
      _items.removeWhere((element) => element.id == item.id);
      notifyListeners();
    });
  }

  // get all items of ? person
  Future<List<ShoppingItem>> getItems() async {
    final db = await database;

    // query for the data
    List<Map<String, dynamic>> result = await db.query(itemTable);

    // map the list to shopping items
    List<ShoppingItem> itemList =
        result.map((i) => ShoppingItem.fromMap(i)).toList();

    _items = itemList;

    return itemList;
  }
}
