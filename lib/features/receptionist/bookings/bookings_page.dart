import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:papa_bear_crm/core/navigation/role_path.dart';
import 'package:papa_bear_crm/core/format/pb_format.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';
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
        PbSearch(
          hint: 'Search customer, phone or stylist',
          results: (query) {
            final columns = people.where((member) {
              if (query.isEmpty) return true;
              if (member.name.toLowerCase().contains(query)) return true;
              return state.todayBookings.any(
                (booking) =>
                    booking.staffId == member.id &&
                    (booking.customerName.toLowerCase().contains(query) || booking.phone.contains(digits(query))),
              );
            }).toList();
            if (columns.isEmpty) return Text('No bookings match that search.', style: PbText.body(14, color: PbColors.muted));
            return SizedBox(
          height: 620,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: columns.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final member = columns[index];
              final staffHit = query.isEmpty || member.name.toLowerCase().contains(query);
              final rows = state.todayBookings.where((booking) {
                if (booking.staffId != member.id) return false;
                if (staffHit) return true;
                return booking.customerName.toLowerCase().contains(query) || booking.phone.contains(digits(query));
              }).toList();
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
        );
          },
        ),
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
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
        onTap: () => context.go(rolePath(context, '/bookings/${booking.id}')),
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
}
