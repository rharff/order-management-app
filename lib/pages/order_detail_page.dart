import 'package:flutter/material.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;
  const OrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    // Placeholder data, replace with actual order details
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: $orderId',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Customer: John Doe'),
            const Text('Status: Uncompleted'),
            const Text('Scheduled: 2025-06-21'),
            const SizedBox(height: 24),
            const Text('Products:'),
            const ListTile(title: Text('Product A'), trailing: Text('x2')),
            const Spacer(),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // TODO: Mark as completed
                  },
                  child: const Text('Mark as Completed'),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Back'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
