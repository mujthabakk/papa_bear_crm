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

class ProductPage extends ConsumerWidget {
  const ProductPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crmProvider);
    final matches = state.products.where((product) => product.id == id);
    if (matches.isEmpty) return const Center(child: Text('Product missing'));
    final product = matches.first;
    final moves = state.stockMoves.where((move) => move.productId == id).toList();
    return PbPage(
      kicker: product.category,
      title: product.name,
      subtitle: '${product.brand} · ${product.supplier} · ${product.use.label}',
      actions: [
        PbButton(label: 'Back', primary: false, onPressed: () => context.go(rolePath(context, '/stock'))),
        if (state.session?.isOwner == true)
          PbButton(label: 'Correct count', onPressed: () => _correct(context, ref, product.qty)),
      ],
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(width: 180, child: MetricTile(label: 'On hand', value: product.qty.toStringAsFixed(0), hint: product.unit)),
            SizedBox(width: 180, child: MetricTile(label: 'Stock value', value: inr(product.stockValue))),
            SizedBox(width: 180, child: MetricTile(label: 'Selling price', value: product.sellingPrice == 0 ? 'Not sold' : inr(product.sellingPrice))),
          ],
        ),
        const SizedBox(height: 16),
        Text('History', style: PbText.display(22)),
        const SizedBox(height: 8),
        for (final move in moves)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PbCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(move.reason.label, style: PbText.body(14, weight: FontWeight.w700)),
                        Text('${dayLabel(move.at)} · ${move.actor} · ${move.note}', style: PbText.body(12.5, color: PbColors.muted)),
                      ],
                    ),
                  ),
                  Text(move.qty.toStringAsFixed(0), style: PbText.body(16, weight: FontWeight.w700)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _correct(BuildContext context, WidgetRef ref, double current) {
    final qty = TextEditingController(text: current.toStringAsFixed(0));
    final note = TextEditingController();
    showPbModal<void>(
      context: context,
      kicker: 'Physical count',
      title: 'Set the real quantity',
      subtitle: 'Only the owner can correct stock after a count.',
      child: FormBody(
        footer: ModalFooter(
          children: [
            PbButton(
              label: 'Save count',
              onPressed: () {
                final error = ref.read(crmProvider.notifier).correctStock(id, double.tryParse(qty.text) ?? -1, note.text);
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
          PbField(label: 'Counted quantity', controller: qty, number: true),
          const SizedBox(height: 8),
          PbField(label: 'Note', controller: note),
        ],
      ),
    );
  }
}
