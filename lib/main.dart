import 'package:flutter/material.dart';
import 'pages/dashboard_page.dart';
import 'pages/orders_page.dart';
import 'pages/products_page.dart';
import 'pages/customers_page.dart';
import 'pages/settings_page.dart';
import 'pages/order_detail_page.dart';

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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardPage(),
        '/orders': (context) => const OrdersPage(),
        '/products': (context) => const ProductsPage(),
        '/customers': (context) => const CustomersPage(),
        '/settings': (context) => const SettingsPage(),
        // Add order detail route with arguments
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/order_detail') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => OrderDetailPage(orderId: args['orderId']),
          );
        }
        return null;
      },
    );
  }
}
