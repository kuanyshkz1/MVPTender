import 'package:flutter/material.dart';
import '../models/tender_model.dart';

class TenderDetailsScreen extends StatelessWidget {
  final Tender tender;
  const TenderDetailsScreen({super.key, required this.tender});

  @override
  Widget build(BuildContext context) {
    final bool isActive = tender.status == 'Прием заявок';
    final Color statusColor = isActive ? Colors.green : Colors.grey;

    return Scaffold(
      appBar: AppBar(title: const Text('Детали лота')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(tender.type.toUpperCase(), style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: statusColor.withOpacity(0.5))),
                  child: Text(tender.status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(tender.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(tender.number, style: const TextStyle(color: Colors.blue, fontSize: 16)),
            const SizedBox(height: 20),
            
            _infoRow('Заказчик:', tender.customer),
            _infoRow('БИН:', tender.bin),
            const Divider(height: 40),
            
            Text('Сумма закупки:', style: TextStyle(color: Colors.grey.shade600)),
            Text('${tender.price.toInt()} ₸', style: const TextStyle(fontSize: 28, color: Colors.green, fontWeight: FontWeight.bold)),
            
            const SizedBox(height: 30),
            _infoRow('Окончание приема заявок:', '${tender.endDate.day}.${tender.endDate.month}.${tender.endDate.year}'),
            
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(60), backgroundColor: Colors.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () {}, 
              child: const Text('Перейти к источнику', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}