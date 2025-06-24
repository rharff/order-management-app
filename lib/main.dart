import 'package:flutter/material.dart';
import 'pages/dashboard/dashboard_page.dart';
import 'pages/order/orders_page.dart';
import 'pages/product/products_page.dart';
import 'pages/customer/customers_page.dart';
import 'pages/settings/settings_page.dart';
import 'pages/order/completed_orders_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        '/completed_orders': (context) => const CompletedOrdersPage(),
      },
    );
  }
}
