import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../order/orders_page.dart'; // Import orders_page to access the global orders list
import '../order/completed_orders_page.dart'; // Import completed_orders_page to access the global completedOrders list
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences for explicit loading
import 'dart:convert'; // Import for JSON encoding/decoding

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _totalOrders = 0;
  String _todayOrdersStats = '0/0'; // Changed to String to hold the ratio
  String _nextOrderCountdown = '-';

  @override
  void initState() {
    super.initState();
    _updateDashboardStats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This is a simple way to update when navigating back.
    // For a more robust solution in a larger app, consider using Provider/Riverpod for state management.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateDashboardStats();
    });
  }

  // Modified to explicitly load data before updating stats
  Future<void> _updateDashboardStats() async {
    // Explicitly load data from SharedPreferences for both lists
    // This ensures the global 'orders' and 'completedOrders' lists are up-to-date
    // before calculations.
    final prefs = await SharedPreferences.getInstance();

    // Load active orders
    final String? ordersString = prefs.getString('orders');
    orders.clear();
    if (ordersString != null && ordersString.isNotEmpty) {
      // Add check for null and empty string
      try {
        final List<dynamic> decoded = jsonDecode(ordersString);
        orders.addAll(
          decoded.map((e) {
            final map = Map<String, dynamic>.from(e);
            if (map['datetimeObj'] != null) {
              map['datetimeObj'] = DateTime.parse(map['datetimeObj']);
            }
            return map;
          }),
        );
      } catch (e) {
        print('Error decoding orders from SharedPreferences: $e');
        // Optionally, clear invalid data or show a message to the user
      }
    }

    // Load completed orders
    final String? completedOrdersString = prefs.getString('completedOrders');
    completedOrders.clear();
    if (completedOrdersString != null && completedOrdersString.isNotEmpty) {
      // Add check for null and empty string
      try {
        final List<dynamic> decoded = jsonDecode(completedOrdersString);
        completedOrders.addAll(
          decoded.map((e) {
            final map = Map<String, dynamic>.from(e);
            if (map['datetimeObj'] != null) {
              map['datetimeObj'] = DateTime.parse(map['datetimeObj']);
            }
            return map;
          }),
        );
      } catch (e) {
        print('Error decoding completed orders from SharedPreferences: $e');
        // Optionally, clear invalid data or show a message to the user
      }
    }

    setState(() {
      _totalOrders = orders.length;

      final now = DateTime.now();
      int todayActiveOrders = 0;
      int todayCompletedOrders = 0;

      for (var order in orders) {
        final dateTimeObj = order['datetimeObj'] as DateTime?;
        if (dateTimeObj != null &&
            dateTimeObj.year == now.year &&
            dateTimeObj.month == now.month &&
            dateTimeObj.day == now.day) {
          todayActiveOrders++;
        }
      }
      for (var order in completedOrders) {
        final dateTimeObj = order['datetimeObj'] as DateTime?;
        if (dateTimeObj != null &&
            dateTimeObj.year == now.year &&
            dateTimeObj.month == now.month &&
            dateTimeObj.day == now.day) {
          todayCompletedOrders++;
        }
      }

      int totalTodayOrders = todayActiveOrders + todayCompletedOrders;
      _todayOrdersStats = '$todayCompletedOrders/$totalTodayOrders';

      // Calculate Next Order Countdown
      DateTime? nearestFutureOrderTime;
      for (var order in orders) {
        final dateTimeObj = order['datetimeObj'] as DateTime?;
        if (dateTimeObj != null && dateTimeObj.isAfter(now)) {
          if (nearestFutureOrderTime == null ||
              dateTimeObj.isBefore(nearestFutureOrderTime)) {
            nearestFutureOrderTime = dateTimeObj;
          }
        }
      }

      if (nearestFutureOrderTime != null) {
        final difference = nearestFutureOrderTime.difference(now);
        if (difference.inDays > 0) {
          _nextOrderCountdown = '${difference.inDays} hari';
        } else if (difference.inHours > 0) {
          _nextOrderCountdown = '${difference.inHours} jam';
        } else if (difference.inMinutes > 0) {
          _nextOrderCountdown = '${difference.inMinutes} menit';
        } else {
          _nextOrderCountdown = 'sebentar lagi';
        }
      } else {
        _nextOrderCountdown = 'null';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white, // Ensure text is visible
      ),
      body: RefreshIndicator(
        // Wrap the body with RefreshIndicator
        onRefresh:
            _updateDashboardStats, // Call _updateDashboardStats when pulled down
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard(
                    'Total Orders',
                    _totalOrders.toString(),
                    Icons.shopping_cart,
                    context,
                  ),
                  _buildStatCard(
                    'Today',
                    _todayOrdersStats,
                    Icons.calendar_today,
                    context,
                  ),
                  _buildStatCard(
                    'Next Order in',
                    _nextOrderCountdown,
                    Icons.watch_later,
                    context,
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(16),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(
                    context,
                    'Orders',
                    Icons.shopping_cart,
                    () => Navigator.pushNamed(
                      context,
                      '/orders',
                    ).then((_) => _updateDashboardStats()),
                  ),
                  _buildDashboardCard(
                    context,
                    'Products',
                    Icons.inventory,
                    () => Navigator.pushNamed(
                      context,
                      '/products',
                    ).then((_) => _updateDashboardStats()),
                  ),
                  _buildDashboardCard(
                    context,
                    'Customers',
                    Icons.people,
                    () => Navigator.pushNamed(
                      context,
                      '/customers',
                    ).then((_) => _updateDashboardStats()),
                  ),
                  _buildDashboardCard(
                    context,
                    'Settings',
                    Icons.settings,
                    () => Navigator.pushNamed(
                      context,
                      '/settings',
                    ).then((_) => _updateDashboardStats()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    BuildContext context,
  ) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon at the top
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8), // Spacing between icon and title
              // Title text
              Text(
                title,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8), // Spacing between title and value
              // Value text at the bottom
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
