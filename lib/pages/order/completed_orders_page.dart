// lib/pages/order/completed_orders_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'order_card.dart';
import 'order_sort_utils.dart'; // Make sure this is still relevant for sorting if needed

// Global list for persistence across navigation for completed orders
final List<Map<String, dynamic>> completedOrders = [];

class CompletedOrdersPage extends StatefulWidget {
  const CompletedOrdersPage({super.key});

  @override
  State<CompletedOrdersPage> createState() => _CompletedOrdersPageState();
}

class _CompletedOrdersPageState extends State<CompletedOrdersPage> {
  @override
  void initState() {
    super.initState();
    _loadCompletedOrders();
  }

  Future<void> _saveCompletedOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = jsonEncode(
      completedOrders.map((order) {
        final copy = Map<String, dynamic>.from(order);
        // DateTime object cannot be encoded, so convert to string
        copy['datetimeObj'] = copy['datetimeObj']?.toIso8601String();
        return copy;
      }).toList(),
    );
    await prefs.setString('completedOrders', ordersJson);
  }

  Future<void> _loadCompletedOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersString = prefs.getString('completedOrders');
    if (ordersString != null) {
      final List<dynamic> decoded = jsonDecode(ordersString);
      completedOrders.clear();
      completedOrders.addAll(
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

  void _uncompleteOrder(int index, Map<String, dynamic> order) {
    setState(() {
      final movedOrder = completedOrders.removeAt(index);
      Navigator.of(context).pop({'action': 'uncomplete', 'order': movedOrder});
    });
    _saveCompletedOrders();
  }

  void _deleteOrder(int index) {
    setState(() {
      completedOrders.removeAt(index);
    });
    _saveCompletedOrders();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order removed from completed orders.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Orders'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body:
          completedOrders.isEmpty
              ? const Center(
                child: Text(
                  'No completed orders yet.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
              : ListView.builder(
                itemCount: completedOrders.length,
                itemBuilder: (context, index) {
                  final order = completedOrders[index];
                  return OrderCard(
                    order: order,
                    isCompleted: true, // Mark as completed
                    onEdit: () {
                      // No edit functionality for completed orders, or you can implement if needed
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Cannot edit completed orders directly.',
                          ),
                        ),
                      );
                    },
                    onDelete: () => _deleteOrder(index),
                    onToggleComplete:
                        () => _uncompleteOrder(
                          index,
                          order,
                        ), // Renamed for clarity
                  );
                },
              ),
    );
  }
}
