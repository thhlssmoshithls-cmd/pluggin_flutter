// lib/screens/transaction_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '/repository.dart';
import '/models/txn.dart';


class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  List<Map<String, dynamic>> selectedItems = [];
  String usernameArg = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)!.settings.arguments;
    if (arg != null && arg is List<Map<String, dynamic>>) {
      selectedItems = List<Map<String, dynamic>>.from(arg);
    }
    final userArg = ModalRoute.of(context)!.settings.arguments;
    print("User argument: $userArg"); // supaya tidak warning

    // username is passed from login via routes; but in our navigation we passed only items
  }

  int get total {
    int s = 0;
    for (var it in selectedItems) {
      s += (it['price'] as int) * (it['qty'] as int);
    }
    return s;
  }

  Future<void> checkout() async {
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak ada item dipilih')));
      return;
    }
    final now = DateTime.now();
    final created = now.toIso8601String();
    // user_id left null for simplicity; you can extend to map username->id
    final txnId = await Repo.instance.createTxn(
      Txn(createdAt: created, total: total),
      selectedItems,
    );

    // generate PDF receipt
    final pdfPath = await _generatePdfReceipt(txnId, now);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transaksi berhasil. Struk disimpan di: $pdfPath')));

    // navigate back to menu
    Navigator.pushReplacementNamed(context, '/menu');
  }

  Future<String> _generatePdfReceipt(int txnId, DateTime when) async {
    final doc = pw.Document();
    final items = await Repo.instance.getTxnItems(txnId);
    final df = DateFormat('yyyy-MM-dd HH:mm');

    doc.addPage(pw.Page(
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Struk Transaksi', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Text('No Transaksi: $txnId'),
            pw.Text('Tanggal: ${df.format(when)}'),
            pw.SizedBox(height: 10),
            pw.Text('Items:'),
            pw.SizedBox(height: 6),
            pw.Table.fromTextArray(
              headers: ['Nama', 'Qty', 'Harga', 'Sub'],
              data: items.map((m) {
                final sub = (m['qty'] as int) * (m['price'] as int);
                return [m['name'], m['qty'].toString(), m['price'].toString(), sub.toString()];
              }).toList(),
            ),
            pw.SizedBox(height: 10),
            pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('Total: Rp. $total', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold))),
          ],
        );
      },
    ));

    final outDir = await getTemporaryDirectory();
    final file = File('${outDir.path}/struk_txn_$txnId.pdf');
    await file.writeAsBytes(await doc.save());
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Summary')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: selectedItems.map((it) {
                  return ListTile(
                    title: Text('Item ID: ${it['item_id']}'),
                    subtitle: Text('Qty: ${it['qty']}  |  Harga: Rp. ${it['price']}'),
                    trailing: Text('Subtotal: Rp. ${(it['price'] as int) * (it['qty'] as int)}'),
                  );
                }).toList(),
              ),
            ),
            Text('Total: Rp. $total', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: checkout, child: const Text('Bayar & Cetak Struk (PDF)')),
          ],
        ),
      ),
    );
  }
}
