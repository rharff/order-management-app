import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'dart:convert'; // Import for JSON encoding/decoding

// Kelas Customer untuk merepresentasikan data pelanggan
class Customer {
  final String name;
  final String phone;

  Customer({required this.name, required this.phone});

  // Method untuk mengkonversi objek Customer ke Map (untuk JSON)
  Map<String, dynamic> toJson() {
    return {'name': name, 'phone': phone};
  }

  // Factory method untuk membuat objek Customer dari Map (dari JSON)
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(name: json['name'], phone: json['phone']);
  }
}

// Halaman utama untuk menampilkan daftar pelanggan
class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  // Daftar pelanggan yang akan ditampilkan
  final List<Customer> _customers = [];
  String _searchQuery = '';
  late SharedPreferences _prefs; // Deklarasi SharedPreferences

  @override
  void initState() {
    super.initState();
    _initSharedPreferences(); // Inisialisasi SharedPreferences saat initState
  }

  // Fungsi untuk menginisialisasi SharedPreferences dan memuat data
  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadCustomers(); // Muat data setelah SharedPreferences siap
  }

  // Fungsi untuk memuat data pelanggan dari SharedPreferences
  void _loadCustomers() {
    final String? customersJson = _prefs.getString('customers');
    if (customersJson != null) {
      final List<dynamic> customerMaps = jsonDecode(customersJson);
      setState(() {
        _customers.clear(); // Bersihkan daftar sebelum memuat ulang
        _customers.addAll(
          customerMaps.map((map) => Customer.fromJson(map)).toList(),
        );
      });
    }
  }

  // Fungsi untuk menyimpan data pelanggan ke SharedPreferences
  Future<void> _saveCustomers() async {
    final List<Map<String, dynamic>> customerMaps =
        _customers.map((customer) => customer.toJson()).toList();
    final String customersJson = jsonEncode(customerMaps);
    await _prefs.setString('customers', customersJson);
  }

  /// Fungsi untuk menambahkan atau mengedit data pelanggan.
  /// Membuka dialog untuk input nama dan nomor telepon.
  ///
  /// [customer]: Objek Customer yang akan diedit (opsional).
  /// [index]: Indeks customer dalam daftar jika sedang mengedit (opsional).
  void _addOrEditCustomer({Customer? customer, int? index}) async {
    String name = customer?.name ?? '';
    String phone = customer?.phone ?? '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(customer == null ? 'Tambah Customer' : 'Edit Customer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Nama'),
                controller: TextEditingController(text: name),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'No. Telepon'),
                keyboardType: TextInputType.phone,
                controller: TextEditingController(text: phone),
                onChanged: (value) => phone = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.isNotEmpty && phone.isNotEmpty) {
                  setState(() {
                    if (customer == null) {
                      _customers.add(Customer(name: name, phone: phone));
                    } else if (index != null) {
                      _customers[index] = Customer(name: name, phone: phone);
                    }
                    _saveCustomers(); // Panggil fungsi simpan setelah perubahan
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  /// Fungsi untuk membuka WhatsApp dengan nomor telepon yang diformat.
  /// Memastikan nomor dimulai dengan '62' untuk Indonesia.
  ///
  /// [context]: BuildContext dari widget saat ini.
  /// [phone]: Nomor telepon yang akan dibuka di WhatsApp.
  void _openWhatsApp(BuildContext context, String phone) async {
    // Menghapus semua karakter non-digit dari nomor telepon
    String cleanedPhoneNumber = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // Memastikan nomor dimulai dengan '62'
    if (cleanedPhoneNumber.startsWith('0')) {
      // Jika dimulai dengan '0', ganti dengan '62'
      cleanedPhoneNumber = '62${cleanedPhoneNumber.substring(1)}';
    } else if (!cleanedPhoneNumber.startsWith('62')) {
      // Jika tidak dimulai dengan '0' atau '62', tambahkan '62' di awal
      cleanedPhoneNumber = '62$cleanedPhoneNumber';
    }

    // Membuat URI untuk WhatsApp
    final url = Uri.parse('https://wa.me/$cleanedPhoneNumber');

    // Memeriksa apakah URL dapat diluncurkan
    if (await canLaunchUrl(url)) {
      // Meluncurkan URL di aplikasi eksternal (WhatsApp)
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // Menampilkan SnackBar jika WhatsApp tidak dapat dibuka
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tidak dapat membuka WhatsApp. Pastikan aplikasi WhatsApp terinstal.',
          ),
        ),
      );
    }
  }

  /// Fungsi untuk menampilkan dialog konfirmasi sebelum membuka WhatsApp.
  ///
  /// [context]: BuildContext dari widget saat ini.
  /// [phone]: Nomor telepon yang akan dihubungi via WhatsApp.
  void _showWhatsAppDialog(BuildContext context, String phone) async {
    showDialog(
      context: context,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            // Menggunakan dialogContext untuk AlertDialog
            title: const Text('Hubungi via WhatsApp'),
            content: const Text('Pergi ke WhatsApp customer?'),
            actions: [
              TextButton(
                onPressed:
                    () =>
                        Navigator.of(
                          dialogContext,
                        ).pop(), // Menggunakan dialogContext
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop(); // Menggunakan dialogContext
                  _openWhatsApp(
                    context,
                    phone,
                  ); // Memastikan context diteruskan
                },
                child: const Text('Hubungi'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter customers by search query
    final filteredCustomers =
        _customers.where((customer) {
          final name = customer.name.toLowerCase();
          final phone = customer.phone.toLowerCase();
          final query = _searchQuery.toLowerCase();
          return name.contains(query) || phone.contains(query);
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari nama atau nomor telepon',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child:
                filteredCustomers.isEmpty
                    ? const Center(child: Text('Belum ada customer.'))
                    : ListView.builder(
                      itemCount: filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = filteredCustomers[index];
                        final originalIndex = _customers.indexOf(customer);
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(customer.name),
                            subtitle: Text(customer.phone),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed:
                                      () => _addOrEditCustomer(
                                        customer: customer,
                                        index: originalIndex,
                                      ),
                                ),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                            onTap:
                                () => _showWhatsAppDialog(
                                  context,
                                  customer.phone,
                                ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditCustomer(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
