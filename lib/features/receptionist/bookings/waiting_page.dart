import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:papa_bear_crm/core/format/pb_format.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';
import 'package:papa_bear_crm/features/receptionist/billing/bill_modal.dart';

class WaitingPage extends ConsumerWidget {
  const WaitingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waiting = ref.watch(crmProvider.select((state) => state.waiting));
    return PbPage(
      kicker: 'When nobody is free',
      title: 'Waiting list',
      subtitle: 'Seat them when a stylist opens up. The expected wait is a guide, not a promise.',
      children: [
        PbSearch(
          hint: 'Search name, phone or service',
          results: (query) {
            final visible = waiting.where((entry) {
              final haystack = '${entry.name} ${entry.phone} ${entry.serviceName}'.toLowerCase();
              return query.isEmpty || haystack.contains(query) || entry.phone.contains(digits(query));
            }).toList();
            if (visible.isEmpty) {
              return Text(waiting.isEmpty ? 'The bench is empty.' : 'No one matches that search.', style: PbText.body(15, color: PbColors.muted));
            }
            return Column(
              children: [
                for (final entry in visible)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PbCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.name, style: PbText.display(24)),
                    Text('${entry.serviceName} · ${entry.phone}', style: PbText.body(13.5, color: PbColors.inkSoft)),
                    Text('Waiting since ${clock(entry.at)} · ${entry.expected}', style: PbText.body(13, color: PbColors.muted)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        PbButton(
                          label: 'Seat and bill',
                          onPressed: () {
                            ref.read(crmProvider.notifier).removeWaiting(entry.id);
                            showBillModal(
                              context,
                              seed: BillSeed(name: entry.name, phone: entry.phone, serviceId: entry.serviceId),
                            );
                          },
                        ),
                        PbButton(
                          label: 'Remove',
                          primary: false,
                          onPressed: () => ref.read(crmProvider.notifier).removeWaiting(entry.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
              ],
            );
          },
        ),
      ],
    );
  }
}
