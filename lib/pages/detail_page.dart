import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/notification_service.dart';
import '../services/session_service.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/product_image.dart';
import 'cart_page.dart';

class DetailPage extends StatefulWidget {
  final Product product;
  const DetailPage({super.key, required this.product});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int _qty = 1;
  bool _adding = false;

  Future<void> _addToCart() async {
    if (_adding) return;
    setState(() => _adding = true);

    final p = widget.product;
    final username = await SessionService.getUsername();
    if (username == null || username.isEmpty) {
      if (mounted) setState(() => _adding = false);
      return;
    }

    final before = CartService.qtyOf(username, p.id);
    final after = await CartService.add(username, p, _qty);
    final added = after - before;

    if (added > 0) {
      try {
        await NotificationService().show(
          title: 'Masuk keranjang',
          body: '${p.title} x$added ditambahkan oleh $username',
        );
      } catch (_) {
        // Notifikasi gagal tidak boleh menggagalkan Add to Cart
      }
    }

    if (!mounted) return;
    setState(() => _adding = false);

    final message = added == 0
        ? 'Keranjang sudah berisi stok maksimal ($after)'
        : added < _qty
        ? 'Hanya $added yang ditambahkan, stok maksimal tercapai'
        : '${p.title} masuk keranjang';

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Lihat keranjang',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartPage()),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final scheme = Theme.of(context).colorScheme;
    final lowStock = p.stock > 0 && p.stock <= 10;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 260,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
            ),
            padding: const EdgeInsets.all(16),
            child: Hero(
              tag: 'product-${p.id}',
              child: ProductImage(url: p.thumbnail),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            p.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            '${p.brand} - ${prettyCategory(p.category)}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          Text(
            money(p.price),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.star_rounded,
                label: 'Rating ${p.rating.toStringAsFixed(1)}',
                color: Colors.amber.shade800,
              ),
              _InfoChip(
                icon: Icons.inventory_2_outlined,
                label: p.stock == 0
                    ? 'Stok habis'
                    : lowStock
                    ? 'Stok menipis: ${p.stock}'
                    : 'Stok: ${p.stock}',
                color: p.stock == 0 || lowStock
                    ? Colors.red.shade600
                    : Colors.green.shade700,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Deskripsi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            p.description,
            style: TextStyle(height: 1.5, color: Colors.grey.shade800),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.soft,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Kurangi',
                      icon: const Icon(Icons.remove),
                      onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                    ),
                    SizedBox(
                      width: 28,
                      child: Text(
                        '$_qty',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Tambah',
                      icon: const Icon(Icons.add),
                      onPressed: _qty < p.stock
                          ? () => setState(() => _qty++)
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: p.stock > 0 && !_adding ? _addToCart : null,
                  icon: _adding
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add_shopping_cart),
                  label: const Text('Add to Cart'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
