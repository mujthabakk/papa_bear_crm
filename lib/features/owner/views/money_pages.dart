import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:papa_bear_crm/core/format/pb_format.dart';
import 'package:papa_bear_crm/core/navigation/role_path.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';
import 'package:papa_bear_crm/data/mock/crm_state.dart';
import 'package:papa_bear_crm/features/owner/reports/report_catalog.dart';

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _HubPage(
      kicker: 'Owner',
      title: 'Sales',
      subtitle: 'Open a report to see the bills, services, products and payment modes behind the total.',
      base: '/sales',
      ids: const ['daily-sales', 'monthly-sales', 'service-sales', 'product-sales', 'staff-sales', 'payment-mode', 'discounts', 'pending-dues'],
    );
  }
}

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _HubPage(
      kicker: 'Owner',
      title: 'Expenses',
      subtitle: 'Cash leaving the shop, grouped by the categories you set.',
      base: '/expenses',
      ids: const ['expenses', 'cashbook'],
    );
  }
}

class ProfitPage extends ConsumerWidget {
  const ProfitPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crmProvider);
    return PbPage(
      kicker: 'Owner',
      title: 'Simple profit',
      subtitle: 'Sales minus expenses, stock purchases and salaries paid this month.',
      children: [
        _ProfitLine(title: 'Sales', value: inr(state.monthSales), path: '/profit/sales'),
        _ProfitLine(title: 'Expenses', value: inr(state.monthExpenses), path: '/profit/expenses'),
        _ProfitLine(title: 'Stock purchases', value: inr(state.monthStockPurchases), path: '/profit/stock'),
        _ProfitLine(title: 'Salaries paid', value: inr(state.monthSalariesPaid), path: '/profit/salaries'),
        _ProfitLine(title: 'Simple profit', value: inr(state.monthProfit), path: '/profit/result', emphasize: true),
      ],
    );
  }
}

class _ProfitLine extends StatelessWidget {
  const _ProfitLine({required this.title, required this.value, required this.path, this.emphasize = false});

  final String title;
  final String value;
  final String path;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PbCard(
        onTap: () => context.go(rolePath(context, path)),
        child: Row(
          children: [
            Expanded(child: Text(title, style: PbText.body(15, weight: FontWeight.w600))),
            Text(value, style: PbText.body(14, weight: FontWeight.w700, color: emphasize ? PbColors.ink : PbColors.inkSoft)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 18, color: PbColors.muted),
          ],
        ),
      ),
    );
  }
}

class ProfitPartPage extends ConsumerWidget {
  const ProfitPartPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crmProvider);
    final title = switch (id) {
      'sales' => 'Sales',
      'expenses' => 'Expenses',
      'stock' => 'Stock purchases',
      'salaries' => 'Salaries paid',
      'result' => 'Simple profit',
      _ => 'Profit',
    };
    return PbPage(
      kicker: 'Simple profit',
      title: title,
      subtitle: switch (id) {
        'sales' => 'Bills counted in this month’s sales.',
        'expenses' => 'Cash out this month, without salary and staff advances.',
        'stock' => 'Purchase deliveries this month, at the product’s buy price.',
        'salaries' => 'Salary slips marked paid in this month.',
        'result' => 'Sales minus expenses, stock purchases and salaries paid.',
        _ => 'This part is not on the profit page.',
      },
      actions: [
        PbButton(label: 'Profit', primary: false, onPressed: () => context.go(rolePath(context, '/profit'))),
      ],
      children: switch (id) {
        'sales' => _bills(context, state),
        'expenses' => _expenses(state),
        'stock' => _stock(context, state),
        'salaries' => _salaries(context, state),
        'result' => _result(context, state),
        _ => [Text('Unknown profit line.', style: PbText.body(14, color: PbColors.muted))],
      },
    );
  }

  List<Widget> _bills(BuildContext context, CrmState state) {
    final bills = state.liveBills.where((bill) => sameMonth(bill.at, shopNow())).toList();
    if (bills.isEmpty) return [_empty('No bills this month.')];
    return [
      for (final bill in bills)
        _row(
          title: bill.number,
          meta: '${bill.customerName} · ${dayLabel(bill.at)}',
          value: inr(bill.total),
          onTap: () => context.go(rolePath(context, '/bills/${bill.id}')),
        ),
    ];
  }

  List<Widget> _expenses(CrmState state) {
    final rows = state.cashEntries.where((entry) {
      return entry.kind == CashKind.cashOut &&
          sameMonth(entry.at, shopNow()) &&
          entry.category != 'Salary' &&
          entry.category != 'Staff advance';
    }).toList();
    if (rows.isEmpty) return [_empty('No expenses recorded this month.')];
    return [
      for (final entry in rows)
        _row(
          title: entry.reason,
          meta: '${entry.category} · ${dayLabel(entry.at)} · ${entry.actor}',
          value: inr(entry.amount),
        ),
    ];
  }

  List<Widget> _stock(BuildContext context, CrmState state) {
    final rows = state.stockMoves.where((move) => move.reason == StockReason.purchase && sameMonth(move.at, shopNow())).toList();
    if (rows.isEmpty) return [_empty('No stock purchases this month.')];
    return [
      for (final move in rows)
        _row(
          title: state.products.where((product) => product.id == move.productId).map((product) => product.name).join(),
          meta: '${move.supplier ?? 'Supplier'} · ${dayLabel(move.at)}',
          value: inr(move.qty.abs() * _price(state, move.productId)),
          onTap: () => context.go(rolePath(context, '/stock/${move.productId}')),
        ),
    ];
  }

  List<Widget> _salaries(BuildContext context, CrmState state) {
    final rows = state.salaries.where((slip) => sameMonth(slip.month, shopNow()) && slip.status == SalaryStatus.paid).toList();
    if (rows.isEmpty) {
      return [
        _empty('No salary has been marked paid this month.'),
        const SizedBox(height: 12),
        PbButton(label: 'Open salary', primary: false, onPressed: () => context.go(rolePath(context, '/salary'))),
      ];
    }
    return [
      for (final slip in rows)
        _row(
          title: state.staffById(slip.staffId)?.name ?? 'Staff',
          meta: '${slip.payKind.label} · ${monthLabel(slip.month)}',
          value: inr(slip.net),
          onTap: () => context.go(rolePath(context, '/salary/${slip.id}')),
        ),
    ];
  }

  List<Widget> _result(BuildContext context, CrmState state) {
    return [
      _ProfitLine(title: 'Sales', value: inr(state.monthSales), path: '/profit/sales'),
      _ProfitLine(title: 'Expenses', value: '− ${inr(state.monthExpenses)}', path: '/profit/expenses'),
      _ProfitLine(title: 'Stock purchases', value: '− ${inr(state.monthStockPurchases)}', path: '/profit/stock'),
      _ProfitLine(title: 'Salaries paid', value: '− ${inr(state.monthSalariesPaid)}', path: '/profit/salaries'),
      PbCard(
        child: Row(
          children: [
            Expanded(child: Text('Simple profit', style: PbText.body(15, weight: FontWeight.w700))),
            Text(inr(state.monthProfit), style: PbText.body(16, weight: FontWeight.w700)),
          ],
        ),
      ),
    ];
  }

  double _price(CrmState state, String productId) {
    final matches = state.products.where((product) => product.id == productId);
    if (matches.isEmpty) return 0;
    return matches.first.purchasePrice;
  }

  Widget _empty(String message) {
    return PbCard(child: Text(message, style: PbText.body(15)));
  }

  Widget _row({required String title, required String meta, required String value, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PbCard(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: PbText.body(15, weight: FontWeight.w600)),
                  if (meta.isNotEmpty) Text(meta, style: PbText.body(12.5, color: PbColors.muted)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(value, style: PbText.body(14, weight: FontWeight.w700)),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 18, color: PbColors.muted),
            ],
          ],
        ),
      ),
    );
  }
}

class _HubPage extends StatelessWidget {
  const _HubPage({
    required this.kicker,
    required this.title,
    required this.subtitle,
    required this.base,
    required this.ids,
  });

  final String kicker;
  final String title;
  final String subtitle;
  final String base;
  final List<String> ids;

  @override
  Widget build(BuildContext context) {
    return PbPage(
      kicker: kicker,
      title: title,
      subtitle: subtitle,
      children: [
        for (final id in ids)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PbCard(
              onTap: () => context.go(rolePath(context, '$base/$id')),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(reportCatalog.firstWhere((report) => report.id == id).title, style: PbText.body(15, weight: FontWeight.w700)),
                        Text(reportCatalog.firstWhere((report) => report.id == id).blurb, style: PbText.body(13, color: PbColors.inkSoft)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_rounded, size: 18, color: PbColors.muted),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
