class ShoppingPerson {
  final String name;
  final bool selectAll;

  const ShoppingPerson({
    required this.name,
    required this.selectAll,
  });

  static const nameField = "name";
  static const selectAllField = "selectAll";

  Map<String, dynamic> toMap() => {
        nameField: name,
        selectAllField: selectAll ? 1 : 0,
      };

  factory ShoppingPerson.fromMap(Map<String, dynamic> value) => ShoppingPerson(
        name: value[nameField],
        selectAll: value[selectAllField] == 1 ? true : false,
      );
}
