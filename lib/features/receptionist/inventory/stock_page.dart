import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:papa_bear_crm/core/format/pb_format.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/core/widgets/pb_modal.dart';
import 'package:papa_bear_crm/core/widgets/pb_toast.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';
import 'package:papa_bear_crm/core/navigation/role_path.dart';

void showStockInModal(BuildContext context) {
  showPbModal<void>(
    context: context,
    kicker: 'Stock in',
    title: 'New stock arrived',
    subtitle: 'Supplier, purchase price and bill number stay with the entry.',
    child: const _StockInForm(),
  );
}

void showStockOutModal(BuildContext context) {
  showPbModal<void>(
    context: context,
    kicker: 'Stock out',
    title: 'Used, damaged or expired',
    subtitle: 'Sold items leave stock from the bill. Use this for the rest.',
    child: const _StockOutForm(),
  );
}

class StockPage extends ConsumerWidget {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(crmProvider.select((state) => state.products));
    final owner = ref.watch(crmProvider.select((state) => state.session?.isOwner == true));
    return PbPage(
      kicker: 'Inventory',
      title: 'Stock',
      subtitle: 'Retail products can be billed. In-shop products are used in services.',
      actions: [
        PbButton(label: 'Stock in', onPressed: () => showStockInModal(context)),
        PbButton(label: 'Stock out', primary: false, onPressed: () => showStockOutModal(context)),
      ],
      children: [
        PbSearch(
          hint: 'Search product, brand or category',
          results: (query) {
            final visible = products.where((product) {
              final haystack = '${product.name} ${product.brand} ${product.category}'.toLowerCase();
              return query.isEmpty || haystack.contains(query);
            }).toList();
            if (visible.isEmpty) return Text('No products match that search.', style: PbText.body(14, color: PbColors.muted));
            return LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 900 ? 3 : constraints.maxWidth > 560 ? 2 : 1;
            final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final product in visible)
                  SizedBox(
                    width: width,
                    child: PbCard(
                      onTap: () => context.go(rolePath(context, '/stock/${product.id}')),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(product.name, style: PbText.body(16, weight: FontWeight.w700))),
                              if (product.low) const PbPill(label: 'Low', background: PbColors.claySoft, foreground: PbColors.clay),
                            ],
                          ),
                          Text('${product.brand} · ${product.use.label}', style: PbText.body(12.5, color: PbColors.muted)),
                          const SizedBox(height: 10),
                          Text('${product.qty.toStringAsFixed(0)} ${product.unit}', style: PbText.display(28)),
                          Text('Min ${product.minimum.toStringAsFixed(0)} · value ${inr(product.stockValue)}', style: PbText.body(12.5, color: PbColors.inkSoft)),
                          if (owner) ...[
                            const SizedBox(height: 8),
                            Text('Tap for history and a count correction.', style: PbText.body(12, color: PbColors.muted)),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        );
          },
        ),
      ],
    );
  }
}

class _StockInForm extends ConsumerStatefulWidget {
  const _StockInForm();

  @override
  ConsumerState<_StockInForm> createState() => _StockInFormState();
}

class _StockInFormState extends ConsumerState<_StockInForm> {
  String? _productId;
  final _qty = TextEditingController();
  final _supplier = TextEditingController();
  final _price = TextEditingController();
  final _bill = TextEditingController();

  @override
  void dispose() {
    _qty.dispose();
    _supplier.dispose();
    _price.dispose();
    _bill.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(crmProvider.select((state) => state.products));
    return FormBody(
      footer: ModalFooter(
        children: [
          PbButton(
            label: 'Add stock',
            onPressed: () {
              if (_productId == null) return;
              final error = ref.read(crmProvider.notifier).stockIn(
                productId: _productId!,
                qty: double.tryParse(_qty.text) ?? 0,
                supplier: _supplier.text,
                purchasePrice: double.tryParse(_price.text) ?? 0,
                billNumber: _bill.text,
              );
              if (error != null) {
                showPbToast(context, error);
                return;
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final product in products)
              PbChoice(label: product.name, selected: _productId == product.id, onTap: () => setState(() => _productId = product.id)),
          ],
        ),
        const SizedBox(height: 12),
        PbField(label: 'Quantity', controller: _qty, number: true),
        const SizedBox(height: 8),
        PbField(label: 'Supplier', controller: _supplier),
        const SizedBox(height: 8),
        PbField(label: 'Purchase price', controller: _price, number: true),
        const SizedBox(height: 8),
        PbField(label: 'Bill number', controller: _bill),
      ],
    );
  }
}

class _StockOutForm extends ConsumerStatefulWidget {
  const _StockOutForm();

  @override
  ConsumerState<_StockOutForm> createState() => _StockOutFormState();
}

class _StockOutFormState extends ConsumerState<_StockOutForm> {
  String? _productId;
  StockReason _reason = StockReason.used;
  final _qty = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _qty.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(crmProvider.select((state) => state.products));
    return FormBody(
      footer: ModalFooter(
        children: [
          PbButton(
            label: 'Record stock out',
            onPressed: () {
              if (_productId == null) return;
              final error = ref.read(crmProvider.notifier).stockOut(
                productId: _productId!,
                qty: double.tryParse(_qty.text) ?? 0,
                reason: _reason,
                note: _note.text,
              );
              if (error != null) {
                showPbToast(context, error);
                return;
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final product in products)
              PbChoice(label: product.name, selected: _productId == product.id, onTap: () => setState(() => _productId = product.id)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            for (final reason in [StockReason.used, StockReason.damaged, StockReason.expired])
              PbChoice(label: reason.label, selected: _reason == reason, onTap: () => setState(() => _reason = reason)),
          ],
        ),
        const SizedBox(height: 12),
        PbField(label: 'Quantity', controller: _qty, number: true),
        const SizedBox(height: 8),
        PbField(label: 'Note', controller: _note),
      ],
    );
  }
}
