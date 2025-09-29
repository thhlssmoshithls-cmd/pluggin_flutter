// lib/screens/transaction_report_page.dart
import 'package:flutter/material.dart';
import '../repository.dart';
import 'package:intl/intl.dart';

class TransactionReportPage extends StatefulWidget {
  const TransactionReportPage({super.key});

  @override
  State<TransactionReportPage> createState() => _TransactionReportPageState();
}

class _TransactionReportPageState extends State<TransactionReportPage> {
  List<Map<String, dynamic>> rows = [];

  @override
  void initState() {
    super.initState();
    loadReport();
  }

  Future<void> loadReport() async {
    final res = await Repo.instance.reportTotalPerDay();
    setState(() {
      rows = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('yyyy-MM-dd');
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Total Transaksi per Hari')),
      body: RefreshIndicator(
        onRefresh: loadReport,
        child: ListView.builder(
          itemCount: rows.length,
          itemBuilder: (context, idx) {
            final r = rows[idx];
            final day = r['day'];
            final total = r['total'] ?? 0;
            final txCount = r['tx_count'] ?? 0;
            return ListTile(
              leading: const Icon(Icons.date_range),
              title: Text('$day'),
              subtitle: Text('Transaksi: $txCount'),
              trailing: Text('Rp. $total', style: const TextStyle(fontWeight: FontWeight.bold)),
            );
          },
        ),
      ),
    );
  }
}
