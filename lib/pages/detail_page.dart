import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/notification_service.dart';
import '../services/session_service.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/product_image.dart';
import '../widgets/qty_stepper.dart';
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
  String _username = '';

  @override
  void initState() {
    super.initState();
    SessionService.getUsername().then((u) {
      if (mounted) setState(() => _username = u ?? '');
    });
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartPage()),
    );
  }

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
        // SnackBar yang punya action tidak hilang sendiri kecuali persist: false
        persist: false,
        duration: const Duration(seconds: 4),
        content: Text(message),
        action: SnackBarAction(label: 'Lihat keranjang', onPressed: _openCart),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final scheme = Theme.of(context).colorScheme;
    final lowStock = p.stock > 0 && p.stock <= 10;

    final infoRows = <MapEntry<String, String>>[
      MapEntry('SKU', p.sku),
      MapEntry('Brand', p.brand),
      MapEntry('Kategori', prettyCategory(p.category)),
      MapEntry(
        'Diskon',
        p.discountPercentage > 0
            ? '${p.discountPercentage.toStringAsFixed(1)}%'
            : '',
      ),
      MapEntry('Ketersediaan', p.availability),
      MapEntry('Garansi', p.warranty),
      MapEntry('Pengiriman', p.shipping),
      MapEntry('Kebijakan retur', p.returnPolicy),
    ].where((e) => e.value.isNotEmpty && e.value != '-').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        actions: [
          ValueListenableBuilder(
            valueListenable: Hive.box('cart').listenable(),
            builder: (context, box, _) {
              final count = _username.isEmpty
                  ? 0
                  : CartService.count(_username);
              return IconButton(
                tooltip: 'Keranjang',
                onPressed: _openCart,
                icon: Badge.count(
                  count: count,
                  isLabelVisible: count > 0,
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Gallery(product: p),
          const SizedBox(height: 20),
          Text(
            p.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            p.brand == '-'
                ? prettyCategory(p.category)
                : '${p.brand} - ${prettyCategory(p.category)}',
            style: const TextStyle(color: AppTheme.muted),
          ),
          const SizedBox(height: 12),
          Text(
            money(p.price),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.star_rounded,
                label: p.reviews.isEmpty
                    ? 'Rating ${p.rating.toStringAsFixed(1)}'
                    : 'Rating ${p.rating.toStringAsFixed(1)} (${p.reviews.length} ulasan)',
                color: AppTheme.warning,
              ),
              _InfoChip(
                icon: Icons.inventory_2_outlined,
                label: p.stock == 0
                    ? 'Stok habis'
                    : lowStock
                    ? 'Stok menipis: ${p.stock}'
                    : 'Stok: ${p.stock}',
                color: p.stock == 0 || lowStock
                    ? AppTheme.danger
                    : AppTheme.success,
              ),
            ],
          ),
          ValueListenableBuilder(
            valueListenable: Hive.box('cart').listenable(),
            builder: (context, box, _) {
              final inCart = _username.isEmpty
                  ? 0
                  : CartService.qtyOf(_username, p.id);
              if (inCart == 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _InfoChip(
                    icon: Icons.shopping_cart_checkout,
                    label: 'Sudah di keranjang: $inCart',
                    color: scheme.primary,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          _Section(
            title: 'Deskripsi',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.description,
                  style: const TextStyle(height: 1.5, color: AppTheme.ink),
                ),
                if (p.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final t in p.tags)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.soft,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '#$t',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (infoRows.isNotEmpty) ...[
            const SizedBox(height: 12),
            _Section(
              title: 'Informasi Produk',
              child: Column(
                children: [
                  for (int i = 0; i < infoRows.length; i++) ...[
                    if (i > 0)
                      const Divider(height: 16, color: AppTheme.border),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            infoRows[i].key,
                            style: const TextStyle(color: AppTheme.muted),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            infoRows[i].value,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (p.reviews.isNotEmpty) ...[
            const SizedBox(height: 12),
            _Section(
              title: 'Ulasan',
              child: Column(
                children: [
                  for (int i = 0; i < p.reviews.length && i < 3; i++) ...[
                    if (i > 0)
                      const Divider(height: 20, color: AppTheme.border),
                    _ReviewTile(review: p.reviews[i]),
                  ],
                ],
              ),
            ),
          ],
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  QtyStepper(
                    qty: _qty,
                    min: 1,
                    max: p.stock,
                    onChanged: (v) => setState(() => _qty = v),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Subtotal',
                        style: TextStyle(fontSize: 12, color: AppTheme.muted),
                      ),
                      Text(
                        money(p.price * _qty),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
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
                  label: Text(p.stock > 0 ? 'Add to Cart' : 'Stok habis'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Gallery extends StatefulWidget {
  final Product product;
  const _Gallery({required this.product});

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final imgs = p.images.isEmpty ? [p.thumbnail] : p.images;

    return Column(
      children: [
        Container(
          height: 280,
          decoration: AppTheme.card(radius: 20),
          clipBehavior: Clip.antiAlias,
          child: PageView.builder(
            itemCount: imgs.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) {
              final img = Padding(
                padding: const EdgeInsets.all(16),
                child: ProductImage(url: imgs[i], cacheWidth: 700),
              );
              return i == 0 ? Hero(tag: 'product-${p.id}', child: img) : img;
            },
          ),
        ),
        if (imgs.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < imgs.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _page ? AppTheme.seed : AppTheme.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                review.reviewerName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.ink,
                ),
              ),
            ),
            for (int i = 0; i < 5; i++)
              Icon(
                i < review.rating
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                size: 16,
                color: AppTheme.star,
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          review.comment,
          style: const TextStyle(color: AppTheme.ink, height: 1.4),
        ),
      ],
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
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
