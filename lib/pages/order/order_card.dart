// order_card.dart
import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    String formatRupiah(num amount) {
      final str = amount.toStringAsFixed(0);
      final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
      return 'Rp ' + str.replaceAllMapped(reg, (match) => '.');
    }

    // Fungsi untuk memisahkan tanggal dan jam dari datetime
    Map<String, String> parseDatetime(String? datetime) {
      if (datetime == null || datetime == '-') {
        return {'date': '-', 'time': '-'};
      }

      // Assuming datetime format is like "2024-01-15 14:30:00" or similar
      final parts = datetime.split(' ');
      if (parts.length >= 2) {
        return {
          'date': parts[0],
          'time': parts[1].substring(0, 5), // Only take HH:MM part
        };
      } else {
        return {'date': datetime, 'time': '-'};
      }
    }

    final datetimeParts = parseDatetime(order['datetime']);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row untuk tanggal di kiri dan jam di kanan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    datetimeParts['date']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    datetimeParts['time']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Menggunakan Column dengan spacing konsisten untuk alignment seperti tab
              Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          'Customer',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Text(
                        ': ${order['customer']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          'Product',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Text(
                        ': ${order['product'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          'Quantity',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Text(
                        ': ${order['quantity'] ?? '-'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Menampilkan jumlah yang diformat menggunakan fungsi formatRupiah.
                  Text(
                    formatRupiah(order['amount'] ?? 0),
                    style: const TextStyle(fontSize: 16),
                  ),
                  // Tombol hapus untuk pesanan.
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 28),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
