import 'package:flutter/material.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample product data
    final products = [
      {'name': 'Laptop', 'stock': 5, 'price': 1200.0},
      {'name': 'Mouse', 'stock': 20, 'price': 25.5},
      {'name': 'Keyboard', 'stock': 15, 'price': 45.0},
      {'name': 'Monitor', 'stock': 7, 'price': 300.0},
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.inventory),
              title: Text(product['name'] as String),
              subtitle: Text('Stock: ${product['stock']}'),
              trailing: Text(
                '\$${(product['price'] as double).toStringAsFixed(2)}',
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement new product creation
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
