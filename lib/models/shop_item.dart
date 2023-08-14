class ShoppingItem {
  final int id;
  final String name;
  final double price;
  final int amount;
  final bool selected;
  final String belongsTo;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.price,
    required this.amount,
    required this.selected,
    required this.belongsTo,
  });

  double get total {
    return price * amount * (selected ? 1 : 0);
  }

  static const idField = "id";
  static const nameField = "name";
  static const priceField = "price";
  static const amountField = "amount";
  static const selectedField = "selected";
  static const belongField = "belong";

  Map<String, dynamic> toMap() => {
        nameField: name,
        priceField: price,
        amountField: amount,
        selectedField: selected ? 1 : 0,
        belongField: belongsTo,
      };

  factory ShoppingItem.fromMap(Map<String, dynamic> value) => ShoppingItem(
        id: value[idField],
        name: value[nameField],
        price: value[priceField],
        amount: value[amountField],
        selected: value[selectedField] == 1 ? true : false,
        belongsTo: value[belongField],
      );
}
