import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../services/cart_service.dart';
import '../services/session_service.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/product_image.dart';
import '../widgets/qty_stepper.dart';

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

  Future<void> _remove(Map<String, dynamic> item) async {
    final user = _username!;
    await CartService.remove(user, item['productId']);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        // SnackBar yang punya action tidak hilang sendiri kecuali persist: false
        persist: false,
        duration: const Duration(seconds: 4),
        content: Text('${item['title']} dihapus dari keranjang'),
        action: SnackBarAction(
          label: 'Urungkan',
          onPressed: () => CartService.restore(user, item),
        ),
      ),
    );
  }

  Future<void> _clearAll() async {
    final user = _username!;
    final items = CartService.getItems(user);
    if (items.isEmpty) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kosongkan keranjang?'),
        content: Text('${items.length} produk akan dihapus dari keranjang.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(90, 42),
              backgroundColor: AppTheme.danger,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kosongkan'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await CartService.clear(user);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        // SnackBar yang punya action tidak hilang sendiri kecuali persist: false
        persist: false,
        duration: const Duration(seconds: 4),
        content: const Text('Keranjang dikosongkan'),
        action: SnackBarAction(
          label: 'Urungkan',
          onPressed: () async {
            for (final it in items) {
              await CartService.restore(user, it);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        actions: [
          if (_username != null)
            ValueListenableBuilder(
              valueListenable: Hive.box('cart').listenable(),
              builder: (context, box, _) {
                final has = CartService.count(_username!) > 0;
                if (!has) return const SizedBox.shrink();
                return IconButton(
                  tooltip: 'Kosongkan keranjang',
                  icon: const Icon(Icons.delete_sweep_outlined),
                  onPressed: _clearAll,
                );
              },
            ),
        ],
      ),
      body: _username == null
          ? const Center(child: CircularProgressIndicator())
          : ValueListenableBuilder(
              valueListenable: Hive.box('cart').listenable(),
              builder: (context, box, _) {
                final items = CartService.getItems(_username!);
                if (items.isEmpty) return _buildEmpty(context);

                final total = items.fold<double>(
                  0,
                  (s, e) => s + (e['price'] as num) * (e['qty'] as num),
                );
                final totalQty = items.fold<int>(
                  0,
                  (s, e) => s + (e['qty'] as int),
                );

                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final it = items[i];
                          return _CartTile(
                            item: it,
                            onQtyChanged: (q) => CartService.setQty(
                              _username!,
                              it['productId'],
                              q,
                            ),
                            onDelete: () => _remove(it),
                          );
                        },
                      ),
                    ),
                    _TotalBar(
                      total: total,
                      totalQty: totalQty,
                      itemCount: items.length,
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 48,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Keranjang masih kosong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Pilih produk di Home, lalu tekan Add to Cart.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.muted),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: const Size(180, 48)),
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('Mulai belanja'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final ValueChanged<int> onQtyChanged;
  final VoidCallback onDelete;

  const _CartTile({
    required this.item,
    required this.onQtyChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final price = item['price'] as num;
    final qty = item['qty'] as int;
    // Item lama (sebelum ada field stock) dianggap tanpa batas
    final maxQty = (item['stock'] as int?) ?? 9999;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.card(),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.soft,
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: ProductImage(
                  url: item['thumbnail'],
                  width: 72,
                  height: 72,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${money(price)} per barang',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      money(price * qty),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppTheme.border),
          const SizedBox(height: 8),
          Row(
            children: [
              QtyStepper(
                qty: qty,
                min: 1,
                max: maxQty,
                compact: true,
                onChanged: onQtyChanged,
              ),
              const Spacer(),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.danger,
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 20),
                label: const Text(
                  'Hapus',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TotalBar extends StatelessWidget {
  final double total;
  final int totalQty;
  final int itemCount;

  const _TotalBar({
    required this.total,
    required this.totalQty,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppTheme.ink,
                  ),
                ),
                Text(
                  '$itemCount produk, $totalQty barang',
                  style: const TextStyle(fontSize: 12, color: AppTheme.muted),
                ),
              ],
            ),
            Text(
              money(total),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.success,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
