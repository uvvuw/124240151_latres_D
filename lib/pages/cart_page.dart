import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../services/cart_service.dart';
import '../services/session_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String? _username;

  @override
  void initState() {
    super.initState();
    SessionService.getUsername().then((u) {
      if (mounted) setState(() => _username = u ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _username == null
          ? const Center(child: CircularProgressIndicator())
          : ValueListenableBuilder(
              valueListenable: Hive.box('cart').listenable(),
              builder: (context, box, _) {
                final items = CartService.getItems(_username!);
                if (items.isEmpty) {
                  return const Center(child: Text('Keranjang kosong'));
                }
                final total = items.fold<double>(
                  0,
                  (s, e) => s + (e['price'] as num) * (e['qty'] as num),
                );
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (_, i) {
                          final it = items[i];
                          final subtotal =
                              (it['price'] as num) * (it['qty'] as num);
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: Image.network(
                                it['thumbnail'],
                                width: 50,
                              ),
                              title: Text(it['title']),
                              subtitle: Text(
                                'Qty: ${it['qty']} | \$${subtotal.toStringAsFixed(2)}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => CartService.remove(
                                  _username!,
                                  it['productId'],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
