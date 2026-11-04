import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:papa_bear_crm/core/format/pb_format.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/core/widgets/pb_modal.dart';
import 'package:papa_bear_crm/core/widgets/pb_toast.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';
import 'package:papa_bear_crm/features/receptionist/billing/bill_modal.dart';
import 'package:papa_bear_crm/features/receptionist/bookings/availability_modal.dart';

class BookingsPage extends ConsumerWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crmProvider);
    final people = state.activeStaff;
    return PbPage(
      kicker: 'Today by stylist',
      title: 'Bookings',
      subtitle: 'Online bookings from the PapaBear app and walk-ins on one board. Absent and leave staff stay off new walk-ins.',
      actions: [
        PbButton(label: 'Check availability', onPressed: () => showAvailabilityModal(context)),
      ],
      children: [
        SizedBox(
          height: 620,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: people.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final member = people[index];
              final rows = state.todayBookings.where((b) => b.staffId == member.id).toList();
              return SizedBox(
                width: 280,
                child: PbCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.name, style: PbText.display(22)),
                      const SizedBox(height: 4),
                      Text('${member.roleTitle} · ${member.today.label}', style: PbText.body(12.5, color: PbColors.muted)),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView(
                          children: [
                            for (final booking in rows)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _BookingCard(booking: booking),
                              ),
                            if (rows.isEmpty)
                              Text('Free through the day.', style: PbText.body(13, color: PbColors.muted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BookingCard extends ConsumerWidget {
  const _BookingCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = switch (booking.status) {
      BookingStatus.upcoming => PbColors.cream,
      BookingStatus.arrived => PbColors.mossSoft,
      BookingStatus.completed => PbColors.paper,
      BookingStatus.noShow => PbColors.claySoft,
      BookingStatus.cancelled => PbColors.cream,
    };
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _open(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(clock(booking.start), style: PbText.body(13, weight: FontWeight.w700)),
                  const Spacer(),
                  PbPill(label: booking.status.label, background: PbColors.ink, foreground: PbColors.cream),
                ],
              ),
              const SizedBox(height: 6),
              Text(booking.customerName, style: PbText.body(15, weight: FontWeight.w600)),
              Text('${booking.serviceName} · ${booking.source.label}', style: PbText.body(12.5, color: PbColors.inkSoft)),
            ],
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, WidgetRef ref) {
    showPbModal<void>(
      context: context,
      kicker: booking.source.label,
      title: booking.customerName,
      subtitle: '${booking.serviceName} · ${clock(booking.start)} to ${clock(booking.end)}',
      child: FormBody(
        footer: ModalFooter(
          children: [
            if (booking.status == BookingStatus.upcoming)
              PbButton(
                label: 'No-show',
                primary: false,
                onPressed: () {
                  ref.read(crmProvider.notifier).setBookingStatus(booking.id, BookingStatus.noShow);
                  Navigator.pop(context);
                },
              ),
            if (booking.status == BookingStatus.upcoming || booking.status == BookingStatus.arrived)
              PbButton(
                label: booking.status == BookingStatus.arrived ? 'Take payment' : 'Mark arrived',
                onPressed: () {
                  if (booking.status == BookingStatus.upcoming) {
                    ref.read(crmProvider.notifier).setBookingStatus(booking.id, BookingStatus.arrived);
                    showPbToast(context, 'Marked arrived. The slot stays held.');
                    Navigator.pop(context);
                    return;
                  }
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  showBillModal(
                    navigator.context,
                    seed: BillSeed(
                      bookingId: booking.id,
                      name: booking.customerName,
                      phone: booking.phone,
                      serviceId: booking.serviceId,
                      staffId: booking.staffId,
                    ),
                  );
                },
              ),
          ],
        ),
        children: [
          Text(booking.phone.isEmpty ? 'No phone yet' : booking.phone, style: PbText.body(15)),
          const SizedBox(height: 8),
          Text(
            'Mark arrived when they reach the chair. No-show frees the time for a walk-in.',
            style: PbText.body(13.5, color: PbColors.inkSoft),
          ),
        ],
      ),
    );
  }
}
