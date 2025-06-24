import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Customer {
  final String name;
  final String phone;

  Customer({required this.name, required this.phone});

  Map<String, dynamic> toJson() {
    return {'name': name, 'phone': phone};
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(name: json['name'], phone: json['phone']);
  }
}

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final List<Customer> _customers = [];
  String _searchQuery = '';
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadCustomers();
  }

  void _loadCustomers() {
    final String? customersJson = _prefs.getString('customers');
    if (customersJson != null) {
      final List<dynamic> customerMaps = jsonDecode(customersJson);
      setState(() {
        _customers.clear();
        _customers.addAll(
          customerMaps.map((map) => Customer.fromJson(map)).toList(),
        );
      });
    }
  }

  Future<void> _saveCustomers() async {
    final List<Map<String, dynamic>> customerMaps =
        _customers.map((customer) => customer.toJson()).toList();
    final String customersJson = jsonEncode(customerMaps);
    await _prefs.setString('customers', customersJson);
  }

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
                    _saveCustomers();
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

  void _openWhatsApp(BuildContext context, String phone) async {
    String cleanedPhoneNumber = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanedPhoneNumber.startsWith('0')) {
      cleanedPhoneNumber = '62${cleanedPhoneNumber.substring(1)}';
    } else if (!cleanedPhoneNumber.startsWith('62')) {
      cleanedPhoneNumber = '62$cleanedPhoneNumber';
    }
    final url = Uri.parse('https://wa.me/$cleanedPhoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tidak dapat membuka WhatsApp. Pastikan aplikasi WhatsApp terinstal.',
          ),
        ),
      );
    }
  }

  void _showWhatsAppDialog(BuildContext context, String phone) async {
    showDialog(
      context: context,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            title: const Text('Hubungi via WhatsApp'),
            content: const Text('Pergi ke WhatsApp customer?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _openWhatsApp(context, phone);
                },
                child: const Text('Hubungi'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
