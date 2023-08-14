import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_list/models/shop_person.dart';
import 'package:shopping_list/tools/database_helper.dart';
import 'package:shopping_list/tools/my_tools.dart';
import 'package:shopping_list/widgets/person_tile.dart';

class PersonListScreen extends StatefulWidget {
  const PersonListScreen({super.key});

  @override
  State<PersonListScreen> createState() => _PersonListScreenState();
}

class _PersonListScreenState extends State<PersonListScreen> {
  late DatabaseHelper dbProvider;
  late Future<List<ShoppingPerson>> personList;

  Future<List<ShoppingPerson>> getPersonList() async {
    return await dbProvider.getAllPerson();
  }

  @override
  void initState() {
    dbProvider = Provider.of<DatabaseHelper>(context, listen: false);
    personList = getPersonList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: addPerson,
        child: const Icon(
          Icons.person_add,
          color: Colors.white,
        ),
      ),
      body: personListFetcher(),
    );
  }

  Widget personListFetcher() {
    return FutureBuilder(
      future: personList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          return Consumer<DatabaseHelper>(
            builder: (context, db, child) {
              final pList = db.people;
              return buildPersonList(pList);
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget buildPersonList(List<ShoppingPerson> pList) {
    if (pList.isEmpty) {
      return const Center(
        child: Text(
          "請新增購買人",
          style: TextStyle(
            fontSize: 30,
          ),
        ),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: pList.length,
      itemBuilder: (context, index) {
        final person = pList[index];
        return PersonTile(
          key: ValueKey(person.name),
          person: person,
        );
      },
    );
  }

  void addPerson() async {
    // ask name using dialog
    String? name = await askName();
    if (name == null) return;
    if (!checkName(name)) {
      if (!mounted) return;
      MyTools.info(context, "名稱不可為空或已被使用");
      return;
    }

    // create person
    final person = ShoppingPerson(
      name: name,
      selectAll: true,
    );

    // save person to database
    dbProvider.addPerson(person);
  }

  // check if name is available or not
  bool checkName(String name) {
    if (name.isEmpty) {
      return false;
    }
    if (dbProvider.hasPerson(name)) {
      return false;
    }
    return true;
  }

  // ask for person name using dialog
  Future<String?> askName() async {
    final nameController = TextEditingController();

    return await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("新增人物"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "人物名稱",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(nameController.text);
              },
              child: const Text("OK"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}
