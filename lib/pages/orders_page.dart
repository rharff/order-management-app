import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:order_management/pages/products_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final List<Map<String, dynamic>> _orders = [];

  int _orderCounter = 123;

  void _showAddOrderDialog() {
    final _quantityController = TextEditingController();
    final _dateController = TextEditingController();
    double _totalPrice = 0.0;
    String? _selectedProduct;

    // Helper to find product price by name - now uses the 'products' list from products_page.dart
    double _getProductPrice(String productName) {
      return products.firstWhere(
        (product) => product['name'] == productName,
      )['price'];
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void updateTotal() {
              double quantity =
                  double.tryParse(_quantityController.text) ?? 0.0;
              if (_selectedProduct != null) {
                _totalPrice = _getProductPrice(_selectedProduct!) * quantity;
              } else {
                _totalPrice = 0.0;
              }
              setDialogState(() {});
            }

            return AlertDialog(
              title: const Text('Add New Order'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedProduct,
                      decoration: const InputDecoration(
                        labelText: 'Product',
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Select a Product'),
                      items:
                          products.map((product) {
                            // <<< Using the top-level 'products' list
                            return DropdownMenuItem<String>(
                              value: product['name'],
                              child: Text(
                                '${product['name']} (Rp ${product['price'].toStringAsFixed(2)})',
                              ),
                            );
                          }).toList(),
                      onChanged: (newValue) {
                        setDialogState(() {
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
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setDialogState(() {
                            _dateController.text = DateFormat(
                              'dd/MM/yy',
                            ).format(pickedDate);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Total Price: Rp ${_totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedProduct != null &&
                        _quantityController.text.isNotEmpty &&
                        _dateController.text.isNotEmpty &&
                        _totalPrice > 0) {
                      setState(() {
                        _orders.add({
                          'id': _orderCounter.toString(),
                          'customer': 'Customer $_orderCounter',
                          'product': _selectedProduct,
                          'quantity':
                              int.tryParse(_quantityController.text) ?? 1,
                          'date': _dateController.text,
                          'amount': _totalPrice,
                        });
                        _orderCounter++;
                      });
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
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body:
          _orders.isEmpty
              ? const Center(
                child: Text(
                  'No orders yet. Add your first order!',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
              : ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order['id']}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Customer: ${order['customer']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Product: ${order['product'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Quantity: ${order['quantity'] ?? '-'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Date: ${order['date'] ?? '-'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Rp ${order['amount'].toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 28,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _orders.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOrderDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
