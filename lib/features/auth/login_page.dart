import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/bear_mark.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/core/widgets/pb_toast.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  UserRole _role = UserRole.receptionist;
  final _password = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _enter() {
    final error = ref.read(crmProvider.notifier).login(_role, _password.text);
    if (error != null) {
      setState(() => _error = error);
      showPbToast(context, error);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final shop = ref.watch(crmProvider.select((state) => state.shop));
    final wide = MediaQuery.sizeOf(context).width >= 960;

    final brand = Container(
      color: PbColors.ink,
      padding: EdgeInsets.all(wide ? 48 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BearMark(size: 52, onDark: true),
          const SizedBox(height: 22),
          Text('PapaBear', style: PbText.display(wide ? 64 : 46, color: PbColors.cream, weight: 560)),
          Text('Shop CRM', style: PbText.display(wide ? 36 : 28, color: PbColors.honey, weight: 500)),
          const SizedBox(height: 16),
          Text(
            'Two logins for every branch. The counter works one branch. The owner manages all of them.',
            style: PbText.body(16, color: const Color(0xFFE7D8C6)),
          ),
          const SizedBox(height: 28),
          Text(shop.name, style: PbText.body(14, weight: FontWeight.w600, color: PbColors.honey)),
          Text(shop.address, style: PbText.body(13, color: const Color(0xFFCBB8A4))),
        ],
      ),
    );

    final form = ColoredBox(
      color: PbColors.cream,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SIGN IN', style: PbText.body(11, weight: FontWeight.w600, color: PbColors.honeyDeep, letterSpacing: 1.4)),
                const SizedBox(height: 8),
                Text('Who is at the desk?', style: PbText.display(34)),
                const SizedBox(height: 18),
                _RoleCard(
                  title: 'Reception',
                  detail: 'Bills, cash, attendance, leave requests and stock.',
                  selected: _role == UserRole.receptionist,
                  passwordHint: 'desk1234',
                  onTap: () => setState(() => _role = UserRole.receptionist),
                ),
                const SizedBox(height: 10),
                _RoleCard(
                  title: 'Owner / Manager',
                  detail: 'Full shop view, leave, salary, reports and settings.',
                  selected: _role == UserRole.owner,
                  passwordHint: 'owner1234',
                  onTap: () => setState(() => _role = UserRole.owner),
                ),
                const SizedBox(height: 18),
                PbField(label: 'Password', controller: _password, hint: 'Preview password is on the card'),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: PbText.body(13, color: PbColors.clay)),
                ],
                const SizedBox(height: 16),
                PbButton(
                  label: _role == UserRole.owner ? 'Enter the office' : 'Enter the counter',
                  expand: true,
                  onPressed: _enter,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!wide) {
      return ColoredBox(
        color: PbColors.cream,
        child: SafeArea(
          child: Column(
            children: [
              brand,
              Expanded(child: form),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(flex: 6, child: brand),
        Expanded(flex: 5, child: form),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.detail,
    required this.selected,
    required this.passwordHint,
    required this.onTap,
  });

  final String title;
  final String detail;
  final bool selected;
  final String passwordHint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? PbColors.ink : PbColors.paper,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? PbColors.ink : PbColors.line),
          ),
          child: Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? PbColors.honey : Colors.transparent,
                  border: Border.all(color: selected ? PbColors.honey : PbColors.muted, width: 2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: PbText.body(16, weight: FontWeight.w600, color: selected ? PbColors.cream : PbColors.ink)),
                    const SizedBox(height: 2),
                    Text(detail, style: PbText.body(13, color: selected ? const Color(0xFFD9CBBC) : PbColors.inkSoft)),
                    const SizedBox(height: 6),
                    Text(
                      'Preview password  $passwordHint',
                      style: PbText.body(12, weight: FontWeight.w600, color: selected ? PbColors.honey : PbColors.honeyDeep),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
