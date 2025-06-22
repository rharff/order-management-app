import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'order_card.dart';
import 'order_dialog.dart';
import 'orders_data.dart';

// Global orders list for persistence across navigation
final List<Map<String, dynamic>> orders = [];

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  void _addOrder(Map<String, dynamic> order, {int? editIndex}) {
    setState(() {
      if (editIndex == null) {
        orders.add(order);
      } else {
        orders[editIndex] = order;
      }
      sortOrdersByDeadline();
    });
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
                    onTap: () => _showEditOrderDialog(index),
                    onDelete: () {
                      setState(() {
                        orders.removeAt(index);
                      });
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
