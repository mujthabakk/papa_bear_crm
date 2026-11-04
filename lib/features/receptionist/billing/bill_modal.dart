import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:papa_bear_crm/core/format/pb_format.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/core/widgets/pb_modal.dart';
import 'package:papa_bear_crm/core/widgets/pb_toast.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';

class BillSeed {
  const BillSeed({this.bookingId, this.name, this.phone, this.serviceId, this.staffId});

  final String? bookingId;
  final String? name;
  final String? phone;
  final String? serviceId;
  final String? staffId;
}

void showBillModal(BuildContext context, {BillSeed? seed}) {
  showPbModal<void>(
    context: context,
    kicker: 'Quick bill',
    title: 'Customer and payment',
    subtitle: 'Find them by phone. Only free staff can be chosen from availability.',
    child: BillForm(seed: seed),
  );
}

class BillForm extends ConsumerStatefulWidget {
  const BillForm({super.key, this.seed});

  final BillSeed? seed;

  @override
  ConsumerState<BillForm> createState() => _BillFormState();
}

class _BillFormState extends ConsumerState<BillForm> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _discount;
  late final TextEditingController _cash;
  late final TextEditingController _upi;
  late final TextEditingController _card;
  late final TextEditingController _note;
  String? _staffId;
  String? _gender;
  final List<BillLine> _lines = [];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.seed?.name ?? '');
    _phone = TextEditingController(text: widget.seed?.phone ?? '');
    _discount = TextEditingController(text: '0');
    _cash = TextEditingController();
    _upi = TextEditingController();
    _card = TextEditingController();
    _note = TextEditingController();
    _staffId = widget.seed?.staffId;
    final serviceId = widget.seed?.serviceId;
    if (serviceId != null) {
      final state = ref.read(crmProvider);
      final service = state.serviceById(serviceId);
      final staff = _staffId == null ? null : state.staffById(_staffId!);
      if (service != null) {
        _lines.add(
          BillLine(
            name: service.name,
            qty: 1,
            price: service.price,
            staffName: staff?.name ?? 'Unassigned',
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _discount.dispose();
    _cash.dispose();
    _upi.dispose();
    _card.dispose();
    _note.dispose();
    super.dispose();
  }

  double get _subtotal => _lines.fold(0, (sum, line) => sum + line.amount);
  double get _discountValue => double.tryParse(_discount.text) ?? 0;
  double get _total => (_subtotal - _discountValue).clamp(0, 9999999);

  void _lookup() {
    final customer = ref.read(crmProvider).customerByPhone(_phone.text);
    if (customer == null) {
      showPbToast(context, 'New number. Fill the name to save them.');
      return;
    }
    setState(() {
      _name.text = customer.name;
      _gender = customer.gender;
    });
    showPbToast(context, 'Last visit ${customer.lastVisit == null ? 'unknown' : dayLabel(customer.lastVisit!)} · ${inr(customer.spend)} spent');
  }

  void _addService(ServiceOffer service) {
    final state = ref.read(crmProvider);
    final staff = _staffId == null ? null : state.staffById(_staffId!);
    if (staff == null) {
      showPbToast(context, 'Choose the stylist first.');
      return;
    }
    setState(() {
      _lines.add(BillLine(name: service.name, qty: 1, price: service.price, staffName: staff.name));
    });
  }

  void _addProduct(ProductItem product) {
    setState(() {
      _lines.add(
        BillLine(
          name: product.name,
          qty: 1,
          price: product.sellingPrice == 0 ? product.purchasePrice : product.sellingPrice,
          staffName: 'Counter',
          isProduct: true,
          productId: product.id,
        ),
      );
    });
  }

  void _save() {
    final error = ref.read(crmProvider.notifier).createBill(
      name: _name.text,
      phone: _phone.text,
      gender: _gender,
      lines: _lines,
      discount: _discountValue,
      tender: Tender(
        cash: double.tryParse(_cash.text) ?? 0,
        upi: double.tryParse(_upi.text) ?? 0,
        card: double.tryParse(_card.text) ?? 0,
      ),
      bookingId: widget.seed?.bookingId,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
    );
    if (error != null) {
      showPbToast(context, error);
      return;
    }
    showPbToast(context, 'Bill saved');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(crmProvider);
    final limit = _subtotal * state.shop.discountLimitPercent / 100;
    return FormBody(
      footer: ModalFooter(
        children: [
          PbButton(label: 'Close', primary: false, onPressed: () => Navigator.of(context).pop()),
          PbButton(label: 'Save bill  ${inr(_total)}', onPressed: _save),
        ],
      ),
      children: [
        PbField(label: 'Phone', controller: _phone, hint: '10-digit mobile', keyboard: TextInputType.phone),
        const SizedBox(height: 8),
        PbButton(label: 'Find by phone', primary: false, icon: Icons.search_rounded, onPressed: _lookup),
        const SizedBox(height: 12),
        PbField(label: 'Name', controller: _name, hint: 'Customer name'),
        const SizedBox(height: 12),
        Text('Gender, optional', style: PbText.body(12.5, weight: FontWeight.w600, color: PbColors.inkSoft)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: [
            for (final option in ['Female', 'Male', 'Other'])
              PbChoice(label: option, selected: _gender == option, onTap: () => setState(() => _gender = option)),
          ],
        ),
        const SizedBox(height: 14),
        Text('Stylist', style: PbText.body(12.5, weight: FontWeight.w600, color: PbColors.inkSoft)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final member in state.activeStaff.where((s) => s.today == AttendanceMark.present || s.today == AttendanceMark.halfDay))
              PbChoice(
                label: member.name,
                selected: _staffId == member.id,
                onTap: () => setState(() => _staffId = member.id),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Text('Add a service', style: PbText.body(12.5, weight: FontWeight.w600, color: PbColors.inkSoft)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final service in state.services)
              PbChoice(label: '${service.name}  ${inr(service.price)}', selected: false, onTap: () => _addService(service)),
          ],
        ),
        const SizedBox(height: 12),
        Text('Add a product', style: PbText.body(12.5, weight: FontWeight.w600, color: PbColors.inkSoft)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final product in state.products.where((item) => item.use == ProductUse.retail))
              PbChoice(label: product.name, selected: false, onTap: () => _addProduct(product)),
          ],
        ),
        const SizedBox(height: 14),
        if (_lines.isEmpty)
          Text('Nothing on the bill yet.', style: PbText.body(13, color: PbColors.muted))
        else
          for (var i = 0; i < _lines.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: PbCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_lines[i].name, style: PbText.body(14, weight: FontWeight.w600)),
                          Text('${_lines[i].staffName} · qty ${_lines[i].qty}', style: PbText.body(12, color: PbColors.muted)),
                        ],
                      ),
                    ),
                    Text(inr(_lines[i].amount), style: PbText.body(14, weight: FontWeight.w600)),
                    IconButton(
                      onPressed: () => setState(() => _lines.removeAt(i)),
                      icon: const Icon(Icons.close_rounded, size: 18),
                    ),
                  ],
                ),
              ),
            ),
        const SizedBox(height: 8),
        PbField(label: 'Discount amount', controller: _discount, number: true, hint: '0'),
        const SizedBox(height: 6),
        Text(
          state.session?.isOwner == true
              ? 'Owner can discount any amount up to the bill.'
              : 'Reception limit ${state.shop.discountLimitPercent.toStringAsFixed(0)}% · ${inr(limit)} on this bill.',
          style: PbText.body(12.5, color: PbColors.inkSoft),
        ),
        const SizedBox(height: 12),
        Text('Split payment', style: PbText.body(12.5, weight: FontWeight.w600, color: PbColors.inkSoft)),
        const SizedBox(height: 8),
        PbField(label: 'Cash', controller: _cash, number: true, hint: '0'),
        const SizedBox(height: 8),
        PbField(label: 'UPI', controller: _upi, number: true, hint: '0'),
        const SizedBox(height: 8),
        PbField(label: 'Card', controller: _card, number: true, hint: '0'),
        const SizedBox(height: 8),
        PbField(label: 'Note', controller: _note, hint: 'Optional'),
        const SizedBox(height: 10),
        Text('To pay  ${inr(_total)}', style: PbText.display(22)),
      ],
    );
  }
}
