import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:papa_bear_crm/core/format/pb_format.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/core/widgets/pb_modal.dart';
import 'package:papa_bear_crm/core/widgets/pb_toast.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';
import 'package:papa_bear_crm/data/mock/crm_state.dart';
import 'package:papa_bear_crm/features/receptionist/billing/bill_modal.dart';

void showAvailabilityModal(BuildContext context) {
  showPbModal<void>(
    context: context,
    kicker: 'Availability',
    title: 'Check before a walk-in',
    subtitle: 'Online bookings from the PapaBear app stay first. A walk-in is allowed only when the service fits.',
    child: const AvailabilityForm(),
  );
}

class AvailabilityForm extends ConsumerStatefulWidget {
  const AvailabilityForm({super.key});

  @override
  ConsumerState<AvailabilityForm> createState() => _AvailabilityFormState();
}

class _AvailabilityFormState extends ConsumerState<AvailabilityForm> {
  String? _serviceId;
  String? _staffId;
  Availability? _result;
  final _reason = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _check() {
    if (_serviceId == null) {
      showPbToast(context, 'Choose a service.');
      return;
    }
    setState(() {
      _result = ref.read(crmProvider).checkAvailability(serviceId: _serviceId!, staffId: _staffId);
    });
  }

  void _start(String staffId) {
    final navigator = Navigator.of(context);
    final id = ref.read(crmProvider.notifier).addArrivedWalkIn(
      serviceId: _serviceId!,
      staffId: staffId,
      name: _name.text.trim().isEmpty ? 'Walk-in' : _name.text.trim(),
      phone: _phone.text,
    );
    navigator.pop();
    showBillModal(
      navigator.context,
      seed: BillSeed(
        bookingId: id,
        serviceId: _serviceId,
        staffId: staffId,
        name: _name.text.trim().isEmpty ? null : _name.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      ),
    );
  }

  void _wait() {
    final error = ref.read(crmProvider.notifier).addWaiting(
      name: _name.text,
      phone: _phone.text,
      serviceId: _serviceId!,
      expected: _result?.options.isNotEmpty == true ? _result!.options.first.label : 'When someone is free',
    );
    if (error != null) {
      showPbToast(context, error);
      return;
    }
    showPbToast(context, 'Added to the waiting list');
    Navigator.of(context).pop();
  }

  void _override(String staffId) {
    final id = ref.read(crmProvider.notifier).overrideClash(
      serviceId: _serviceId!,
      staffId: staffId,
      reason: _reason.text,
      name: _name.text.trim().isEmpty ? 'Walk-in' : _name.text.trim(),
      phone: _phone.text,
    );
    if (id == null) {
      showPbToast(context, 'Add a reason. Only the owner can override a clash.');
      return;
    }
    final navigator = Navigator.of(context);
    navigator.pop();
    showBillModal(
      navigator.context,
      seed: BillSeed(bookingId: id, serviceId: _serviceId, staffId: staffId, name: _name.text, phone: _phone.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(crmProvider);
    final result = _result;
    return FormBody(
      footer: ModalFooter(
        children: [
          PbButton(label: 'Check availability', onPressed: _check),
        ],
      ),
      children: [
        Text('Service', style: PbText.body(12.5, weight: FontWeight.w600, color: PbColors.inkSoft)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final service in state.services)
              PbChoice(
                label: '${service.name} · ${service.minutes}m',
                selected: _serviceId == service.id,
                onTap: () => setState(() {
                  _serviceId = service.id;
                  _result = null;
                }),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Text('Staff, if the customer asked', style: PbText.body(12.5, weight: FontWeight.w600, color: PbColors.inkSoft)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            PbChoice(label: 'Anyone free', selected: _staffId == null, onTap: () => setState(() => _staffId = null)),
            for (final member in state.activeStaff)
              PbChoice(
                label: member.name,
                selected: _staffId == member.id,
                onTap: () => setState(() => _staffId = member.id),
              ),
          ],
        ),
        const SizedBox(height: 14),
        PbField(label: 'Customer name', controller: _name, hint: 'Optional until the bill'),
        const SizedBox(height: 8),
        PbField(label: 'Phone', controller: _phone, hint: 'Needed for the waiting list'),
        if (result != null) ...[
          const SizedBox(height: 16),
          PbCard(
            color: result.blocked ? PbColors.claySoft : PbColors.mossSoft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.headline, style: PbText.display(22)),
                const SizedBox(height: 6),
                Text(result.detail, style: PbText.body(14, color: PbColors.inkSoft)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final option in result.options)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: PbCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(option.staff.name, style: PbText.body(15, weight: FontWeight.w600)),
                          Text('${option.label} · ${clock(option.start)}', style: PbText.body(12.5, color: PbColors.muted)),
                        ],
                      ),
                    ),
                    PbButton(
                      label: option.now && !result.blocked ? 'Start bill' : 'Use this time',
                      onPressed: () => _start(option.staff.id),
                    ),
                  ],
                ),
              ),
            ),
          if (result.options.isEmpty)
            Text('No alternative inside working hours.', style: PbText.body(13, color: PbColors.muted)),
          const SizedBox(height: 8),
          PbButton(label: 'Add to waiting list', primary: false, expand: true, onPressed: _serviceId == null ? null : _wait),
          if (result.blocked && state.session?.isOwner == true && _staffId != null) ...[
            const SizedBox(height: 12),
            PbField(label: 'Override reason', controller: _reason, hint: 'Recorded in the activity log'),
            const SizedBox(height: 8),
            PbButton(label: 'Force this walk-in', expand: true, onPressed: () => _override(_staffId!)),
          ],
        ],
      ],
    );
  }
}
