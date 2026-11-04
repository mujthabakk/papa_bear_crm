import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:papa_bear_crm/core/format/pb_format.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/core/widgets/pb_modal.dart';
import 'package:papa_bear_crm/core/widgets/pb_toast.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';

void showBranchSwitcher(BuildContext context) {
  showPbModal<void>(
    context: context,
    kicker: 'This device',
    title: 'Switch branch',
    subtitle: 'The counter, cash and staff follow the branch you pick.',
    child: const _BranchSwitchList(),
  );
}

class BranchesPage extends ConsumerWidget {
  const BranchesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crmProvider);
    return PbPage(
      kicker: 'Company',
      title: 'Branches',
      subtitle: '${state.shop.name} keeps one login. Each branch has its own counter, stock, cash and staff.',
      actions: [
        PbButton(label: 'Add branch', icon: Icons.add_rounded, onPressed: () => _edit(context, ref)),
      ],
      children: [
        for (final branch in state.branches)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: PbCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(branch.name, style: PbText.display(24))),
                      PbPill(
                        label: branch.id == state.activeBranchId ? 'On this device' : branch.open ? 'Open' : 'Paused',
                        background: branch.id == state.activeBranchId ? PbColors.ink : PbColors.cream,
                        foreground: branch.id == state.activeBranchId ? PbColors.honey : PbColors.ink,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${branch.address} · ${branch.phone}', style: PbText.body(13, color: PbColors.inkSoft)),
                  Text('Manager ${branch.manager}', style: PbText.body(13, color: PbColors.muted)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 18,
                    runSpacing: 8,
                    children: [
                      _stat('Today', inr(_todaySales(branch))),
                      _stat('Cash', inr(_expectedCash(branch))),
                      _stat('Present', '${_present(branch)}'),
                      _stat('Low stock', '${branch.products.where((product) => product.low).length}'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      PbButton(
                        label: branch.id == state.activeBranchId ? 'Working here' : 'Switch here',
                        primary: branch.id != state.activeBranchId,
                        onPressed: branch.id == state.activeBranchId ? null : () => _switch(context, ref, branch.id),
                      ),
                      PbButton(label: 'Edit', primary: false, onPressed: () => _edit(context, ref, branch: branch)),
                      PbButton(
                        label: branch.open ? 'Pause' : 'Open',
                        primary: false,
                        onPressed: () {
                          final error = ref.read(crmProvider.notifier).setBranchOpen(branch.id, !branch.open);
                          if (context.mounted && error != null) showPbToast(context, error);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _switch(BuildContext context, WidgetRef ref, String id) {
    final error = ref.read(crmProvider.notifier).switchBranch(id);
    showPbToast(context, error ?? 'Counter moved to this branch');
  }

  void _edit(BuildContext context, WidgetRef ref, {BranchDesk? branch}) {
    final name = TextEditingController(text: branch?.name ?? '');
    final address = TextEditingController(text: branch?.address ?? '');
    final phone = TextEditingController(text: branch?.phone ?? '');
    final manager = TextEditingController(text: branch?.manager ?? '');
    showPbModal<void>(
      context: context,
      kicker: branch == null ? 'New counter' : 'Branch',
      title: branch == null ? 'Add a branch' : branch.name,
      subtitle: 'A new branch starts with an empty drawer, no staff and no stock.',
      child: FormBody(
        footer: ModalFooter(
          children: [
            PbButton(label: 'Cancel', primary: false, onPressed: () => Navigator.of(context).pop()),
            PbButton(
              label: branch == null ? 'Add' : 'Save',
              onPressed: () {
                final error = branch == null
                    ? ref.read(crmProvider.notifier).addBranch(
                        name: name.text,
                        address: address.text,
                        phone: phone.text,
                        manager: manager.text,
                      )
                    : ref.read(crmProvider.notifier).updateBranch(
                        id: branch.id,
                        name: name.text,
                        address: address.text,
                        phone: phone.text,
                        manager: manager.text,
                      );
                if (error != null) {
                  showPbToast(context, error);
                  return;
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        children: [
          PbField(label: 'Branch name', controller: name, hint: 'Panampilly Nagar'),
          const SizedBox(height: 12),
          PbField(label: 'Address', controller: address),
          const SizedBox(height: 12),
          PbField(label: 'Phone', controller: phone, keyboard: TextInputType.phone),
          const SizedBox(height: 12),
          PbField(label: 'Manager', controller: manager),
        ],
      ),
    );
  }
}

class _BranchSwitchList extends ConsumerWidget {
  const _BranchSwitchList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crmProvider);
    final owner = state.session?.isOwner ?? false;
    final branches = owner ? state.branches : state.branches.where((branch) => branch.open).toList();
    return FormBody(
      children: [
        for (final branch in branches)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PbCard(
              onTap: branch.id == state.activeBranchId
                  ? null
                  : () {
                      final error = ref.read(crmProvider.notifier).switchBranch(branch.id);
                      if (error != null) {
                        showPbToast(context, error);
                        return;
                      }
                      Navigator.of(context).pop();
                    },
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(branch.name, style: PbText.body(16, weight: FontWeight.w700)),
                        Text(
                          branch.open ? '${branch.address} · ${inr(_todaySales(branch))} today' : 'Paused · ${branch.address}',
                          style: PbText.body(12.5, color: PbColors.inkSoft),
                        ),
                      ],
                    ),
                  ),
                  if (branch.id == state.activeBranchId)
                    const PbPill(label: 'Here', background: PbColors.ink, foreground: PbColors.honey)
                  else
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

Widget _stat(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label.toUpperCase(), style: PbText.body(10, weight: FontWeight.w700, color: PbColors.muted, letterSpacing: 0.8)),
      Text(value, style: PbText.body(15, weight: FontWeight.w700)),
    ],
  );
}

double _todaySales(BranchDesk desk) {
  return desk.bills.where((bill) => !bill.voided && sameDay(bill.at, shopNow())).fold(0.0, (sum, bill) => sum + bill.total);
}

double _expectedCash(BranchDesk desk) {
  final bills = desk.bills.where((bill) => !bill.voided && sameDay(bill.at, shopNow()));
  final cashBills = bills.fold(0.0, (sum, bill) => sum + bill.tender.cash);
  final manualIn = desk.cashEntries.where((entry) => entry.kind == CashKind.cashIn && sameDay(entry.at, shopNow())).fold(0.0, (sum, entry) => sum + entry.amount);
  final manualOut = desk.cashEntries.where((entry) => entry.kind == CashKind.cashOut && sameDay(entry.at, shopNow())).fold(0.0, (sum, entry) => sum + entry.amount);
  return desk.openingCash + cashBills + manualIn - manualOut;
}

int _present(BranchDesk desk) {
  return desk.staff.where((person) => person.active && (person.today == AttendanceMark.present || person.today == AttendanceMark.halfDay)).length;
}
