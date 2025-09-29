// lib/models/item.dart
class Item {
  final int? id;
  final String name;
  final int price;
  final String category;

  Item({
    this.id,
    required this.name,
    required this.price,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'price': price,
      'category': category,
    };
  }

  factory Item.fromMap(Map<String, dynamic> m) => Item(
    id: m['id'] as int?,
    name: m['name'],
    price: m['price'],
    category: m['category'],
  );
}
