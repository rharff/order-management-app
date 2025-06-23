// order_card.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import for launching URLs
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'dart:convert'; // Import for JSON encoding/decoding

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onEdit; // Tambahkan parameter untuk tombol edit
  final VoidCallback onDelete;

  const OrderCard({
    super.key,
    required this.order,
    required this.onEdit, // Tambahkan ke konstruktor
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

    // Fungsi untuk mengambil nomor WhatsApp customer dari SharedPreferences
    Future<String?> _getCustomerPhone(String customerName) async {
      final prefs = await SharedPreferences.getInstance();
      final String? customersJson = prefs.getString('customers');
      if (customersJson != null) {
        final List<dynamic> customerMaps = jsonDecode(customersJson);
        for (var map in customerMaps) {
          if (map['name'] == customerName) {
            return map['phone'];
          }
        }
      }
      return null;
    }

    // Fungsi untuk membuka WhatsApp dengan dialog konfirmasi
    void _showWhatsAppDialog(BuildContext context, String customerName) async {
      final phone = await _getCustomerPhone(customerName);
      if (phone == null || phone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nomor WhatsApp customer tidak ditemukan.'),
          ),
        );
        return;
      }
      showDialog(
        context: context,
        builder:
            (BuildContext dialogContext) => AlertDialog(
              title: const Text('Hubungi via WhatsApp'),
              content: Text(
                'Customer ${order['customer']} memesan ${order['product'] ?? 'N/A'}',
                style: const TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    // Format nomor telepon seperti di customers_page.dart
                    String cleanedPhoneNumber = phone.replaceAll(
                      RegExp(r'[^0-9]'),
                      '',
                    );
                    if (cleanedPhoneNumber.startsWith('0')) {
                      cleanedPhoneNumber =
                          '62${cleanedPhoneNumber.substring(1)}';
                    } else if (!cleanedPhoneNumber.startsWith('62')) {
                      cleanedPhoneNumber = '62$cleanedPhoneNumber';
                    }
                    final url = Uri.parse('https://wa.me/$cleanedPhoneNumber');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Tidak dapat membuka WhatsApp. Pastikan aplikasi WhatsApp terinstal.',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Hubungi'),
                ),
              ],
            ),
      );
    }

    return GestureDetector(
      onTap: () => _showWhatsAppDialog(context, order['customer'] ?? ''),
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
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.blue,
                          size: 28,
                        ),
                        onPressed: onEdit,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 28,
                        ),
                        onPressed: onDelete,
                      ),
                    ],
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
