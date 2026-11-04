import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:papa_bear_crm/core/format/pb_format.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';
import 'package:papa_bear_crm/features/receptionist/billing/bill_modal.dart';
import 'package:papa_bear_crm/features/receptionist/bookings/availability_modal.dart';
import 'package:papa_bear_crm/features/receptionist/cash/cash_modal.dart';
import 'package:papa_bear_crm/features/receptionist/leave/leave_page.dart';
import 'package:papa_bear_crm/features/receptionist/inventory/stock_page.dart';
import 'package:papa_bear_crm/core/navigation/role_path.dart';

class CounterPage extends ConsumerWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crmProvider);
    final next = state.todayBookings.where((b) => b.status == BookingStatus.upcoming).take(4).toList();
    return PbPage(
      kicker: fullDate(shopNow()),
      title: 'Counter',
      subtitle: '${state.desk.name} · shop clock ${clock(shopNow())}. Cash in hand stays on this screen all day.',
      actions: [
        PbButton(label: 'New bill', icon: Icons.add_rounded, onPressed: () => showBillModal(context)),
      ],
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final tile = width > 900 ? (width - 36) / 4 : (width - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(width: tile, child: MetricTile(label: 'Cash in hand', value: inr(state.expectedCash), hint: 'Opening ${inr(state.openingCash)}', onTap: () => context.go(rolePath(context, '/cash')))),
                SizedBox(width: tile, child: MetricTile(label: 'Sales so far', value: inr(state.todaySales), hint: '${state.todayBills.length} bills', onTap: () => context.go(rolePath(context, '/bills')))),
                SizedBox(width: tile, child: MetricTile(label: 'Online bookings', value: '${state.onlineToday}', hint: '${state.walkInToday} walk-in bills', onTap: () => context.go(rolePath(context, '/bookings')))),
                SizedBox(width: tile, child: MetricTile(label: 'On the floor', value: '${state.presentCount}', hint: '${state.absentCount} absent · ${state.leaveCount} leave', onTap: () => context.go(rolePath(context, '/attendance')))),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Text('Quick actions', style: PbText.display(22)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Action(icon: Icons.event_available_rounded, label: 'Check availability', onTap: () => showAvailabilityModal(context)),
            _Action(icon: Icons.receipt_long_rounded, label: 'New customer bill', onTap: () => showBillModal(context)),
            _Action(icon: Icons.south_west_rounded, label: 'Cash in', onTap: () => showCashModal(context, CashKind.cashIn)),
            _Action(icon: Icons.north_east_rounded, label: 'Cash out', onTap: () => showCashModal(context, CashKind.cashOut)),
            _Action(icon: Icons.how_to_reg_rounded, label: 'Attendance', onTap: () => context.go(rolePath(context, '/attendance'))),
            _Action(icon: Icons.event_busy_rounded, label: 'Leave request', onTap: () => showLeaveModal(context)),
            _Action(icon: Icons.inventory_2_rounded, label: 'Add stock', onTap: () => showStockInModal(context)),
          ],
        ),
        const SizedBox(height: 18),
        Text('Next bookings', style: PbText.display(22)),
        const SizedBox(height: 10),
        if (next.isEmpty)
          Text('No upcoming online bookings.', style: PbText.body(14, color: PbColors.muted))
        else
          for (final booking in next)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: PbCard(
                onTap: () => context.go(rolePath(context, '/bookings/${booking.id}')),
                child: Row(
                  children: [
                    SizedBox(width: 78, child: Text(clock(booking.start), style: PbText.body(14, weight: FontWeight.w700))),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(booking.customerName, style: PbText.body(15, weight: FontWeight.w600)),
                          Text('${booking.serviceName} · ${state.staffById(booking.staffId)?.name ?? ''}', style: PbText.body(12.5, color: PbColors.muted)),
                        ],
                      ),
                    ),
                    PbPill(label: booking.source.label, background: PbColors.tideSoft, foreground: PbColors.tide),
                  ],
                ),
              ),
            ),
        const SizedBox(height: 12),
        Text('Low stock', style: PbText.display(22)),
        const SizedBox(height: 10),
        if (state.lowStock.isEmpty)
          Text('Stock levels are fine.', style: PbText.body(14, color: PbColors.muted))
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final product in state.lowStock)
                PbPill(
                  label: '${product.name} · ${product.qty.toStringAsFixed(0)} ${product.unit}',
                  background: PbColors.claySoft,
                  foreground: PbColors.clay,
                  onTap: () => context.go(rolePath(context, '/stock/${product.id}')),
                ),
            ],
          ),
        if (state.waiting.isNotEmpty) ...[
          const SizedBox(height: 16),
          PbCard(
            color: PbColors.ink,
            onTap: () => context.go(rolePath(context, '/waiting')),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${state.waiting.length} customer${state.waiting.length == 1 ? '' : 's'} waiting',
                    style: PbText.body(15, weight: FontWeight.w600, color: PbColors.cream),
                  ),
                ),
                Text('Open list', style: PbText.body(13, weight: FontWeight.w600, color: PbColors.honey)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PbColors.paper,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 168,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: PbColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: PbColors.honeyDeep),
              const SizedBox(height: 12),
              Text(label, style: PbText.body(14, weight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
