import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'order_card.dart';
import 'order_dialog.dart';
import 'order_sort_utils.dart';

// Global orders list for persistence across navigation
final List<Map<String, dynamic>> orders = [];

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = jsonEncode(
      orders.map((order) {
        final copy = Map<String, dynamic>.from(order);
        // DateTime object cannot be encoded, so convert to string
        copy['datetimeObj'] = copy['datetimeObj']?.toIso8601String();
        return copy;
      }).toList(),
    );
    await prefs.setString('orders', ordersJson);
  }

  Future<void> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersString = prefs.getString('orders');
    if (ordersString != null) {
      final List<dynamic> decoded = jsonDecode(ordersString);
      orders.clear();
      orders.addAll(
        decoded.map((e) {
          final map = Map<String, dynamic>.from(e);
          if (map['datetimeObj'] != null) {
            map['datetimeObj'] = DateTime.parse(map['datetimeObj']);
          }
          return map;
        }),
      );
      setState(() {});
    }
  }

  void _addOrder(Map<String, dynamic> order, {int? editIndex}) {
    setState(() {
      if (editIndex == null) {
        orders.add(order);
      } else {
        orders[editIndex] = order;
      }
      sortOrdersByDeadline(orders);
    });
    _saveOrders();
  }

  void _showAddOrderDialog() {
    showDialog(
      context: context,
      builder: (context) => OrderDialog(onOrderSaved: _addOrder),
    );
  }

  void _showEditOrderDialog(int index) {
    showDialog(
      context: context,
      builder:
          (context) => OrderDialog(
            onOrderSaved: _addOrder,
            initialOrder: orders[index],
            editIndex: index,
          ),
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
          orders.isEmpty
              ? const Center(
                child: Text(
                  'No orders yet. Add your first order!',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
              : ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return OrderCard(
                    order: order,
                    onEdit: () => _showEditOrderDialog(index),
                    onDelete: () {
                      setState(() {
                        orders.removeAt(index);
                      });
                      _saveOrders();
                    },
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
