import 'package:flutter/material.dart';
import '../../data/models/tender_model.dart';

class TenderCard extends StatelessWidget {
  final Tender tender;
  const TenderCard({super.key, required this.tender});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tender.type.toUpperCase(), style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(tender.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Заказчик: ${tender.customer} (БИН: ${tender.bin})', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${tender.price.toStringAsFixed(0)} ₸', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                Text('До: ${tender.endDate.day}.${tender.endDate.month}', style: const TextStyle(color: Colors.red)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}