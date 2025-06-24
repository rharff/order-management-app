import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'order_card.dart';
import 'order_dialog.dart';
import 'order_sort_utils.dart';
import 'completed_orders_page.dart';
import 'order_notification_service.dart'; // Import the notification service

// Global orders list for persistence across navigation
final List<Map<String, dynamic>> orders = [];

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String _searchQuery = '';
  late OrderNotificationService _notificationService; // Declare the service

  @override
  void initState() {
    super.initState();
    _notificationService = OrderNotificationService(); // Initialize the service
    _loadOrders();
    _loadCompletedOrdersFromPreferences();
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

  Future<void> _saveCompletedOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = jsonEncode(
      completedOrders.map((order) {
        final copy = Map<String, dynamic>.from(order);
        copy['datetimeObj'] = copy['datetimeObj']?.toIso8601String();
        return copy;
      }).toList(),
    );
    await prefs.setString('completedOrders', ordersJson);
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
      sortOrdersByDeadline(orders);
      setState(() {});
      _scheduleNotificationsForExistingOrders(); // Schedule notifications on load
    }
  }

  void _scheduleNotificationsForExistingOrders() {
    _notificationService
        .cancelAllNotifications(); // Clear existing notifications to avoid duplicates
    for (int i = 0; i < orders.length; i++) {
      final order = orders[i];
      if (order['datetimeObj'] != null &&
          order['customer'] != null &&
          order['product'] != null) {
        _notificationService.scheduleOrderNotification(
          i, // Use index as ID for simplicity, consider a more robust unique ID for production
          order['customer'],
          order['product'],
          order['datetimeObj'],
        );
      }
    }
  }

  // A dedicated load function for completed orders to be used internally
  Future<void> _loadCompletedOrdersFromPreferences() async {
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
      setState(() {}); // Update the state if completed orders are loaded
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
    // Schedule notification for the new/edited order
    if (order['datetimeObj'] != null &&
        order['customer'] != null &&
        order['product'] != null) {
      _notificationService.scheduleOrderNotification(
        editIndex ?? orders.indexOf(order), // Use existing index or new index
        order['customer'],
        order['product'],
        order['datetimeObj'],
      );
    }
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

  void _completeOrder(int index) {
    setState(() {
      final completedOrder = orders.removeAt(index);
      completedOrders.add(completedOrder);
      sortOrdersByDeadline(completedOrders); // Optional: sort completed orders
    });
    _saveOrders();
    _saveCompletedOrders();
    _notificationService
        .cancelAllNotifications(); // Reschedule all notifications after an order is completed
    _scheduleNotificationsForExistingOrders();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Order marked as completed!')));
  }

  void _uncompleteOrder(Map<String, dynamic> orderToUncomplete) {
    setState(() {
      // Find and remove the order from completedOrders
      completedOrders.removeWhere(
        (order) =>
            order['customer'] == orderToUncomplete['customer'] &&
            order['product'] == orderToUncomplete['product'] &&
            order['datetime'] == orderToUncomplete['datetime'],
      ); // Use a more robust unique identifier if available

      // Add it back to the main orders list
      orders.add(orderToUncomplete);
      sortOrdersByDeadline(orders);
    });
    _saveOrders();
    _saveCompletedOrders();
    _notificationService
        .cancelAllNotifications(); // Reschedule all notifications after an order is uncompleted
    _scheduleNotificationsForExistingOrders();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order re-checked and moved back to active orders.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter orders by search query
    List<Map<String, dynamic>> filteredOrders =
        orders.where((order) {
          final customer = (order['customer'] ?? '').toString().toLowerCase();
          final product = (order['product'] ?? '').toString().toLowerCase();
          final date =
              order['datetimeObj'] != null
                  ? DateFormat('yyyy-MM-dd').format(order['datetimeObj'])
                  : (order['datetime'] ?? '').toString();
          final query = _searchQuery.toLowerCase();
          return customer.contains(query) ||
              product.contains(query) ||
              date.contains(query);
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            tooltip: 'View Completed Orders',
            onPressed: () async {
              // When navigating to CompletedOrdersPage, wait for result if an order was uncompleted
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CompletedOrdersPage(),
                ),
              );
              if (result != null && result['action'] == 'uncomplete') {
                _uncompleteOrder(result['order']);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by customer, product, or date',
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
                filteredOrders.isEmpty
                    ? const Center(
                      child: Text(
                        'No orders found.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        final originalIndex = orders.indexOf(order);
                        return OrderCard(
                          order: order,
                          onEdit: () => _showEditOrderDialog(originalIndex),
                          onDelete: () {
                            setState(() {
                              orders.removeAt(originalIndex);
                            });
                            _saveOrders();
                            _notificationService
                                .cancelAllNotifications(); // Reschedule all notifications after deletion
                            _scheduleNotificationsForExistingOrders();
                          },
                          onToggleComplete: () => _completeOrder(originalIndex),
                          isCompleted: false,
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOrderDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
