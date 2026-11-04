import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:papa_bear_crm/core/format/pb_format.dart';
import 'package:papa_bear_crm/core/navigation/role_path.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/core/widgets/pb_toast.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';
import 'package:papa_bear_crm/features/owner/settings/settings_forms.dart';

class ShopSettingsPage extends ConsumerWidget {
  const ShopSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shop = ref.watch(crmProvider).shop;
    return PbPage(
      kicker: 'Settings',
      title: 'Shop details',
      subtitle: 'The brand line shared by every branch. Each branch address is edited under Branches.',
      actions: [
        PbButton(label: 'Edit', onPressed: () => showShopForm(context, ref)),
      ],
      children: [
        PbCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(shop.name, style: PbText.display(28)),
              Text(shop.address, style: PbText.body(15)),
              Text(shop.phone, style: PbText.body(15, color: PbColors.inkSoft)),
            ],
          ),
        ),
      ],
    );
  }
}

class ServicesSettingsPage extends ConsumerWidget {
  const ServicesSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(crmProvider).services;
    return PbPage(
      kicker: 'Settings',
      title: 'Services and prices',
      subtitle: 'Duration blocks a walk-in when the next online booking is too close.',
      actions: [
        PbButton(label: 'Add service', onPressed: () => showNewServiceForm(context, ref)),
      ],
      children: [
        for (final service in services)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PbCard(
              onTap: () => showServiceForm(context, ref, service.id),
              child: Row(
                children: [
                  Expanded(child: Text('${service.name} · ${service.minutes} min', style: PbText.body(15, weight: FontWeight.w600))),
                  Text(inr(service.price), style: PbText.body(15, weight: FontWeight.w700)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class SkillsSettingsPage extends ConsumerWidget {
  const SkillsSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staff = ref.watch(crmProvider).activeStaff;
    return PbPage(
      kicker: 'Settings',
      title: 'Skills and hours',
      subtitle: 'A stylist is offered for a walk-in only when the service is on this list and they are on the floor.',
      children: [
        for (final member in staff)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PbCard(
              onTap: () => context.go(rolePath(context, '/staff/${member.id}')),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name, style: PbText.body(16, weight: FontWeight.w700)),
                  Text('${member.roleTitle} · ${member.startHour}:00–${member.endHour}:00', style: PbText.body(13, color: PbColors.muted)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final skill in member.skills)
                        PbPill(label: skill, background: PbColors.cream, foreground: PbColors.ink),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class AccessSettingsPage extends ConsumerWidget {
  const AccessSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shop = ref.watch(crmProvider).shop;
    return PbPage(
      kicker: 'Settings',
      title: 'Logins',
      subtitle: 'Two logins only. Staff do not get their own password in this version.',
      children: [
        PbCard(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  shop.receptionistEnabled ? 'Receptionist login is on' : 'Receptionist login is disabled',
                  style: PbText.body(15, weight: FontWeight.w600),
                ),
              ),
              PbButton(
                label: shop.receptionistEnabled ? 'Disable' : 'Enable',
                primary: false,
                onPressed: () => ref.read(crmProvider.notifier).setReceptionistEnabled(!shop.receptionistEnabled),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        PbButton(label: 'Change receptionist password', primary: false, onPressed: () => showPasswordForm(context, ref, owner: false)),
        const SizedBox(height: 8),
        PbButton(label: 'Change owner password', primary: false, onPressed: () => showPasswordForm(context, ref, owner: true)),
      ],
    );
  }
}

class CategoriesSettingsPage extends ConsumerWidget {
  const CategoriesSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(crmProvider).shop.expenseCategories;
    return PbPage(
      kicker: 'Settings',
      title: 'Expense categories',
      subtitle: 'These are the reasons on cash out.',
      actions: [
        PbButton(label: 'Add category', onPressed: () => showCategoryForm(context, ref)),
      ],
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final category in categories)
              PbPill(label: category, background: PbColors.paper, foreground: PbColors.ink),
          ],
        ),
      ],
    );
  }
}

class RulesSettingsPage extends ConsumerWidget {
  const RulesSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shop = ref.watch(crmProvider).shop;
    return PbPage(
      kicker: 'Settings',
      title: 'Salary rules',
      subtitle: 'Used when the month-end salary run is calculated.',
      actions: [
        PbButton(label: 'Discount limit', primary: false, onPressed: () => showDiscountForm(context, ref)),
      ],
      children: [
        PbCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Desk discount limit ${shop.discountLimitPercent.toStringAsFixed(0)}%', style: PbText.body(16, weight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('${shop.workingDays} working days · weekly off ${shop.weeklyOff}', style: PbText.body(14)),
              Text('Overtime ${inr(shop.overtimeRate)} / hour · ${shop.paidLeavePerYear} paid leaves a year', style: PbText.body(14)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        PbCard(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  shop.commissionEnabled ? 'Commission ${shop.commissionPercent.toStringAsFixed(0)}% is on' : 'Commission is off',
                  style: PbText.body(15, weight: FontWeight.w600),
                ),
              ),
              PbButton(
                label: shop.commissionEnabled ? 'Turn off' : 'Turn on',
                primary: false,
                onPressed: () => ref.read(crmProvider.notifier).setCommission(!shop.commissionEnabled, shop.commissionPercent),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BackupSettingsPage extends ConsumerWidget {
  const BackupSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crmProvider);
    return PbPage(
      kicker: 'Settings',
      title: 'Backup',
      subtitle: 'A full file download comes with the live shop book. This page shows what would be included.',
      actions: [
        PbButton(
          label: 'Prepare export',
          onPressed: () => showPbToast(context, 'Export is ready as a layout. The file download is the next stage.'),
        ),
      ],
      children: [
        _line('Bills', '${state.bills.length}'),
        _line('Customers', '${state.customers.length}'),
        _line('Staff', '${state.staff.length}'),
        _line('Products', '${state.products.length}'),
        _line('Cash entries', '${state.cashEntries.length}'),
        _line('Activity rows', '${state.activity.length}'),
      ],
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PbCard(
        child: Row(
          children: [
            Expanded(child: Text(label, style: PbText.body(15, weight: FontWeight.w600))),
            Text(value, style: PbText.body(15, weight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
