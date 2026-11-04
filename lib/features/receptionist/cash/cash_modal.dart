import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/core/widgets/pb_modal.dart';
import 'package:papa_bear_crm/core/widgets/pb_toast.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';

void showCashModal(BuildContext context, CashKind kind) {
  showPbModal<void>(
    context: context,
    kicker: kind.label,
    title: kind == CashKind.cashIn ? 'Money coming in' : 'Money leaving the drawer',
    subtitle: kind == CashKind.cashOut
        ? 'Tea, cleaning, supplier payment, staff advance or owner withdrawal.'
        : 'Other cash received, besides customer bills.',
    child: CashForm(kind: kind),
  );
}

class CashForm extends ConsumerStatefulWidget {
  const CashForm({super.key, required this.kind});

  final CashKind kind;

  @override
  ConsumerState<CashForm> createState() => _CashFormState();
}

class _CashFormState extends ConsumerState<CashForm> {
  final _amount = TextEditingController();
  final _reason = TextEditingController();
  String? _category;

  @override
  void dispose() {
    _amount.dispose();
    _reason.dispose();
    super.dispose();
  }

  void _save() {
    final categories = ref.read(crmProvider).shop.expenseCategories;
    final error = ref.read(crmProvider.notifier).addCash(
      kind: widget.kind,
      amount: double.tryParse(_amount.text) ?? 0,
      category: _category ?? (widget.kind == CashKind.cashIn ? 'Others' : categories.first),
      reason: _reason.text,
    );
    if (error != null) {
      showPbToast(context, error);
      return;
    }
    showPbToast(context, '${widget.kind.label} saved');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(crmProvider.select((state) => state.shop.expenseCategories));
    return FormBody(
      footer: ModalFooter(
        children: [
          PbButton(label: 'Cancel', primary: false, onPressed: () => Navigator.pop(context)),
          PbButton(label: 'Save entry', onPressed: _save),
        ],
      ),
      children: [
        PbField(label: 'Amount', controller: _amount, number: true, hint: '0'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final category in categories)
              PbChoice(label: category, selected: _category == category, onTap: () => setState(() => _category = category)),
          ],
        ),
        const SizedBox(height: 12),
        PbField(label: 'Reason', controller: _reason, hint: 'What is this for?', maxLines: 2),
      ],
    );
  }
}
