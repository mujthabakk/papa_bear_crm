import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:papa_bear_crm/core/format/pb_format.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';
import 'package:papa_bear_crm/core/navigation/role_path.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crmProvider);
    final maxMode = [state.cashFromBillsToday, state.upiToday, state.cardToday].fold<double>(1, (a, b) => a > b ? a : b);
    return PbPage(
      kicker: fullDate(shopNow()),
      title: state.desk.name,
      subtitle: 'Sales, cash, people and stock for this branch. Switch branches from the sidebar.',
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final tile = constraints.maxWidth > 900 ? (constraints.maxWidth - 36) / 4 : (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(width: tile, child: MetricTile(label: 'Today sales', value: inr(state.todaySales), onTap: () => context.go(rolePath(context, '/bills')))),
                SizedBox(width: tile, child: MetricTile(label: 'This month', value: inr(state.monthSales), onTap: () => context.go(rolePath(context, '/reports/monthly-sales')))),
                SizedBox(width: tile, child: MetricTile(label: 'Cash in hand', value: inr(state.expectedCash), onTap: () => context.go(rolePath(context, '/cash')))),
                SizedBox(width: tile, child: MetricTile(label: 'Month expenses', value: inr(state.monthExpenses), onTap: () => context.go(rolePath(context, '/reports/expenses')))),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        PbCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Today by payment', style: PbText.display(22)),
              const SizedBox(height: 12),
              _bar('Cash', state.cashFromBillsToday, maxMode),
              _bar('UPI', state.upiToday, maxMode),
              _bar('Card', state.cardToday, maxMode),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 320,
              child: PbCard(
                onTap: () => context.go(rolePath(context, '/leave')),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pending leave', style: PbText.body(13, weight: FontWeight.w600, color: PbColors.muted)),
                    const SizedBox(height: 6),
                    Text('${state.pendingLeaves.length}', style: PbText.display(32)),
                    for (final leave in state.pendingLeaves.take(2))
                      Text('${state.staffById(leave.staffId)?.name ?? ''} · ${leave.type.label}', style: PbText.body(13)),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 320,
              child: PbCard(
                onTap: () => context.go(rolePath(context, '/stock')),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Low stock', style: PbText.body(13, weight: FontWeight.w600, color: PbColors.muted)),
                    const SizedBox(height: 6),
                    Text('${state.lowStock.length}', style: PbText.display(32)),
                    Text(state.lowStock.map((p) => p.name).join(', '), style: PbText.body(13)),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 320,
              child: PbCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Simple month profit', style: PbText.body(13, weight: FontWeight.w600, color: PbColors.muted)),
                    const SizedBox(height: 6),
                    Text(inr(state.monthProfit), style: PbText.display(32)),
                    Text('Sales minus expenses, stock purchases and paid salaries.', style: PbText.body(12.5, color: PbColors.inkSoft)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Who is in', style: PbText.display(22)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final member in state.activeStaff)
              PbPill(
                label: '${member.name} · ${member.today.label}',
                background: member.today == AttendanceMark.present ? PbColors.mossSoft : PbColors.cream,
                foreground: member.today == AttendanceMark.present ? PbColors.moss : PbColors.inkSoft,
              ),
          ],
        ),
      ],
    );
  }

  Widget _bar(String label, double amount, double max) {
    final fraction = (amount / max).clamp(0, 1).toDouble();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: PbText.body(13, weight: FontWeight.w600)),
              const Spacer(),
              Text(inr(amount), style: PbText.body(13, weight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: fraction == 0 ? 0.02 : fraction,
                backgroundColor: PbColors.cream,
                color: PbColors.honeyDeep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
