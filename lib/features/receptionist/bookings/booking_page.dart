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
import 'package:papa_bear_crm/features/receptionist/billing/bill_modal.dart';

class BookingPage extends ConsumerWidget {
  const BookingPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crmProvider);
    final matches = state.bookings.where((booking) => booking.id == id);
    if (matches.isEmpty) {
      return PbPage(
        kicker: 'Booking',
        title: 'Not on this branch',
        actions: [
          PbButton(label: 'Bookings', primary: false, onPressed: () => context.go(rolePath(context, '/bookings'))),
        ],
        children: [Text('This booking is not on ${state.desk.name}.', style: PbText.body(15))],
      );
    }
    final booking = matches.first;
    final staff = state.staffById(booking.staffId)?.name ?? 'Unassigned';
    return PbPage(
      kicker: booking.source.label,
      title: booking.customerName,
      subtitle: '${booking.serviceName} · ${clock(booking.start)} to ${clock(booking.end)}',
      actions: [
        PbButton(label: 'Bookings', primary: false, onPressed: () => context.go(rolePath(context, '/bookings'))),
        if (booking.status == BookingStatus.upcoming)
          PbButton(
            label: 'No-show',
            primary: false,
            onPressed: () {
              ref.read(crmProvider.notifier).setBookingStatus(booking.id, BookingStatus.noShow);
              showPbToast(context, 'Marked no-show. The time is free for a walk-in.');
            },
          ),
        if (booking.status == BookingStatus.upcoming)
          PbButton(
            label: 'Mark arrived',
            onPressed: () {
              ref.read(crmProvider.notifier).setBookingStatus(booking.id, BookingStatus.arrived);
              showPbToast(context, 'Marked arrived. The slot stays held.');
            },
          ),
        if (booking.status == BookingStatus.arrived)
          PbButton(
            label: 'Take payment',
            onPressed: () => showBillModal(
              context,
              seed: BillSeed(
                bookingId: booking.id,
                name: booking.customerName,
                phone: booking.phone,
                serviceId: booking.serviceId,
                staffId: booking.staffId,
              ),
            ),
          ),
      ],
      children: [
        PbCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fullDate(booking.start), style: PbText.body(13, color: PbColors.muted)),
              const SizedBox(height: 6),
              Text('${clock(booking.start)} – ${clock(booking.end)}', style: PbText.display(28)),
              const SizedBox(height: 8),
              Text('$staff · ${booking.minutes} min', style: PbText.body(15)),
              const SizedBox(height: 4),
              Text(booking.phone.isEmpty ? 'No phone yet' : booking.phone, style: PbText.body(15)),
              const SizedBox(height: 12),
              PbPill(label: booking.status.label, background: PbColors.ink, foreground: PbColors.cream),
            ],
          ),
        ),
        if (state.session?.isOwner == true) ...[
          const SizedBox(height: 12),
          PbButton(label: 'Open stylist', primary: false, onPressed: () => context.go(rolePath(context, '/staff/${booking.staffId}'))),
        ],
      ],
    );
  }
}
