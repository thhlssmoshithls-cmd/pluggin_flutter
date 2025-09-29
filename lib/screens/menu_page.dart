// lib/screens/menu_page.dart
import 'package:flutter/material.dart';
import '../repository.dart';
import '../models/item.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Item> items = [];
  Map<int, int> quantities = {}; // itemId -> qty
  String search = "";

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    final all = await Repo.instance.getAllItems();
    setState(() {
      items = all;
    });
  }

  Future<void> doSearch(String q) async {
    if (q.trim().isEmpty) {
      await loadItems();
      return;
    }
    final res = await Repo.instance.searchItems(q.trim());
    setState(() {
      items = res;
    });
  }

  int get totalQuantity => quantities.values.fold(0, (a, b) => a + b);
  int get totalPrice {
    int s = 0;
    for (var e in quantities.entries) {
      final it = items.firstWhere((i) => i.id == e.key, orElse: () => Item(id: e.key, name: '', price: 0, category: ''));
      s += (it.price) * e.value;
    }
    return s;
  }

  void resetOrders() {
    setState(() {
      quantities.clear();
    });
  }

  void goToTransaction() {
    // pass selected items to transaction screen
    final selected = quantities.entries
        .where((e) => e.value > 0)
        .map((e) => {
              'item_id': e.key,
              'qty': e.value,
              'price': items.firstWhere((i) => i.id == e.key).price,
            })
        .toList();
    Navigator.pushNamed(context, '/transaction', arguments: selected);
  }

  @override
  Widget build(BuildContext context) {
    // categorize
    final makanan = items.where((i) => i.category.toLowerCase() == 'makanan').toList();
    final minuman = items.where((i) => i.category.toLowerCase() == 'minuman').toList();

    Widget buildCategory(String title, List<Item> list) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ...list.map((item) {
            final qty = quantities[item.id] ?? 0;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(qty.toString(), style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item.name, style: const TextStyle(fontSize: 16))),
                  Text("Rp. ${item.price}", style: const TextStyle(fontSize: 16)),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (qty > 0) quantities[item.id!] = qty - 1;
                            if (quantities[item.id] == 0) quantities.remove(item.id);
                          });
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            quantities[item.id!] = (quantities[item.id] ?? 0) + 1;
                          });
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("MENUS"),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/report'),
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Laporan Transaksi',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: "Cari menu..."),
              onChanged: (v) {
                search = v;
                doSearch(v);
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildCategory("Makanan", makanan),
                  buildCategory("Minuman", minuman),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text("Jumlah Pesanan: $totalQuantity  |  Total: Rp. $totalPrice", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(onPressed: goToTransaction, child: const Text("Transaction")),
            ElevatedButton(onPressed: resetOrders, child: const Text("Reset")),
          ],
        ),
      ),
    );
  }
}
