import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OrderDialog extends StatefulWidget {
  final Function(Map<String, dynamic> order, {int? editIndex}) onOrderSaved;
  final Map<String, dynamic>? initialOrder;
  final int? editIndex;

  const OrderDialog({
    super.key,
    required this.onOrderSaved,
    this.initialOrder,
    this.editIndex,
  });

  @override
  State<OrderDialog> createState() => _OrderDialogState();
}

class _OrderDialogState extends State<OrderDialog> {
  late TextEditingController _quantityController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  double _totalPrice = 0.0;
  String? _selectedProduct;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _customers = [];
  String? _selectedCustomer;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCustomers();
    if (widget.initialOrder != null) {
      _quantityController = TextEditingController(
        text: widget.initialOrder!['quantity'].toString(),
      );
      _dateController = TextEditingController(
        text: widget.initialOrder!['datetime'].split(' ')[0],
      );
      _timeController = TextEditingController(
        text: widget.initialOrder!['datetime'].split(' ')[1],
      );
      _totalPrice = widget.initialOrder!['amount'];
      _selectedProduct = widget.initialOrder!['product'];
      _selectedCustomer = widget.initialOrder!['customer'];
      _selectedDate = DateFormat(
        'dd/MM/yy',
      ).parse(widget.initialOrder!['datetime'].split(' ')[0]);
      _selectedTime = TimeOfDay(
        hour: int.parse(
          widget.initialOrder!['datetime'].split(' ')[1].split(':')[0],
        ),
        minute: int.parse(
          widget.initialOrder!['datetime'].split(' ')[1].split(':')[1],
        ),
      );
    } else {
      _quantityController = TextEditingController();
      _dateController = TextEditingController();
      _timeController = TextEditingController();
    }
  }

  Future<void> _loadCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? customersString = prefs.getString('customers');
    if (customersString != null) {
      final List<dynamic> decoded = jsonDecode(customersString);
      setState(() {
        _customers = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    }
  }

  Future<void> _loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? productsString = prefs.getString('products');
    if (productsString != null) {
      final List<dynamic> decoded = jsonDecode(productsString);
      setState(() {
        _products = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    }
  }

  double _getProductPrice(String productName) {
    final product = _products.firstWhere(
      (p) => p['name'] == productName,
      orElse: () => {'price': 0.0},
    );
    return (product['price'] as num?)?.toDouble() ?? 0.0;
  }

  void updateTotal() {
    double quantity = double.tryParse(_quantityController.text) ?? 0.0;
    if (_selectedProduct != null) {
      _totalPrice = _getProductPrice(_selectedProduct!) * quantity;
    } else {
      _totalPrice = 0.0;
    }
    setState(() {});
  }

  String formatRupiah(num amount) {
    final str = amount.toStringAsFixed(0);
    final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return 'Rp ' + str.replaceAllMapped(reg, (match) => '.');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.editIndex == null ? 'Add New Order' : 'Edit Order'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCustomer,
              decoration: const InputDecoration(
                labelText: 'Customer',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Select a Customer'),
              items:
                  _customers.map((customer) {
                    return DropdownMenuItem<String>(
                      value: customer['name'],
                      child: Text('${customer['name']} (${customer['phone']})'),
                    );
                  }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedCustomer = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedProduct,
              decoration: const InputDecoration(
                labelText: 'Product',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Select a Product'),
              items:
                  _products.map((product) {
                    return DropdownMenuItem<String>(
                      value: product['name'],
                      child: Text(
                        '${product['name']} (${formatRupiah(product['price'])})',
                      ),
                    );
                  }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedProduct = newValue;
                  updateTotal();
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => updateTotal(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Date (DD/MM/YY)',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                    _dateController.text = DateFormat(
                      'dd/MM/yy',
                    ).format(pickedDate);
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(
                labelText: 'Time (HH:mm)',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.access_time),
              ),
              readOnly: true,
              onTap: () async {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime ?? TimeOfDay.now(),
                  builder: (context, child) {
                    return MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(alwaysUse24HourFormat: true),
                      child: child!,
                    );
                  },
                );
                if (pickedTime != null) {
                  setState(() {
                    _selectedTime = pickedTime;
                    final hour = pickedTime.hour.toString().padLeft(2, '0');
                    final minute = pickedTime.minute.toString().padLeft(2, '0');
                    _timeController.text = '$hour:$minute';
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Total Price: ${formatRupiah(_totalPrice)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (_selectedCustomer == null ||
                _selectedProduct == null ||
                _quantityController.text.isEmpty ||
                _dateController.text.isEmpty ||
                _timeController.text.isEmpty ||
                _totalPrice <= 0)
              const SizedBox(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_selectedCustomer != null &&
                _selectedProduct != null &&
                _quantityController.text.isNotEmpty &&
                _dateController.text.isNotEmpty &&
                _timeController.text.isNotEmpty &&
                _totalPrice > 0) {
              String orderDateTime =
                  '${_dateController.text} ${_timeController.text}';
              final order = {
                'customer': _selectedCustomer,
                'product': _selectedProduct,
                'quantity': int.tryParse(_quantityController.text) ?? 1,
                'datetime': orderDateTime,
                'amount': _totalPrice,
                'datetimeObj': DateFormat(
                  'dd/MM/yy HH:mm',
                ).parse(orderDateTime),
              };
              widget.onOrderSaved(order, editIndex: widget.editIndex);
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Please fill all required fields and ensure total price is calculated.',
                  ),
                ),
              );
            }
          },
          child: Text(widget.editIndex == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
