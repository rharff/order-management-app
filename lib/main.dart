import 'package:flutter/material.dart';
import 'pages/dashboard_page.dart';
import 'pages/orders_page.dart';
import 'pages/products_page.dart';
import 'pages/customers_page.dart';
import 'pages/settings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Order Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardPage(),
        '/orders': (context) => const OrdersPage(),
        '/products': (context) => const ProductsPage(),
        '/customers': (context) => const CustomersPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
