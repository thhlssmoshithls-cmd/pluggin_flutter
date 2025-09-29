// lib/main.dart
import 'package:flutter/material.dart';
import 'repository.dart';
import 'models/item.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/menu_page.dart';
import 'screens/transaction_page.dart';
import 'screens/transaction_report_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Seed default menu items if DB empty
  final seed = [
    Item(name: "Nasi Goreng", price: 15000, category: "Makanan"),
    Item(name: "Mie Goreng", price: 12000, category: "Makanan"),
    Item(name: "Ayam Geprek", price: 18000, category: "Makanan"),
    Item(name: "Sate Ayam", price: 20000, category: "Makanan"),
    Item(name: "Bakso", price: 15000, category: "Makanan"),
    Item(name: "Es Teh Manis", price: 5000, category: "Minuman"),
    Item(name: "Es Jeruk", price: 7000, category: "Minuman"),
    Item(name: "Kopi Hitam", price: 8000, category: "Minuman"),
    Item(name: "Cappuccino", price: 12000, category: "Minuman"),
    Item(name: "Jus Alpukat", price: 15000, category: "Minuman"),
  ];
  await Repo.instance.seedItemsIfEmpty(seed);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Order App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/menu': (context) => const MenuPage(),
        '/transaction': (context) => const TransactionPage(),
        '/report': (context) => const TransactionReportPage(),
      },
    );
  }
}
