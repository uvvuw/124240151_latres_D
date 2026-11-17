import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Tombol +/- jumlah. Dipakai di halaman Detail dan Cart.
class QtyStepper extends StatelessWidget {
  final int qty;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final bool compact;

  const QtyStepper({
    super.key,
    required this.qty,
    required this.min,
    required this.max,
    required this.onChanged,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.soft,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Kurangi',
            visualDensity: compact
                ? VisualDensity.compact
                : VisualDensity.standard,
            iconSize: compact ? 20 : 22,
            icon: const Icon(Icons.remove),
            onPressed: qty > min ? () => onChanged(qty - 1) : null,
          ),
          SizedBox(
            width: compact ? 26 : 34,
            child: Text(
              '$qty',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: compact ? 15 : 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Tambah',
            visualDensity: compact
                ? VisualDensity.compact
                : VisualDensity.standard,
            iconSize: compact ? 20 : 22,
            icon: const Icon(Icons.add),
            onPressed: qty < max ? () => onChanged(qty + 1) : null,
          ),
        ],
      ),
    );
  }
}
