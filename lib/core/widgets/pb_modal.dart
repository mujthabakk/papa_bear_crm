import 'package:flutter/material.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';

/// Ledger panel. Wide screens dock a floating card on the right.
/// Narrow screens lift a ticket-style sheet. This is the only dialog
/// surface in the app, so forms never fall back to a stock alert.
Future<T?> showPbModal<T>({
  required BuildContext context,
  required String kicker,
  required String title,
  String? subtitle,
  required Widget child,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: const Color(0xC41A120C),
    transitionDuration: const Duration(milliseconds: 340),
    pageBuilder: (context, animation, secondary) {
      return PbModalFrame(
        kicker: kicker,
        title: title,
        subtitle: subtitle,
        child: child,
      );
    },
    transitionBuilder: (context, animation, secondary, child) {
      final wide = MediaQuery.sizeOf(context).width >= 840;
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: wide ? const Offset(0.18, 0) : const Offset(0, 0.12),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class PbModalFrame extends StatelessWidget {
  const PbModalFrame({
    super.key,
    required this.kicker,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String kicker;
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final wide = media.size.width >= 840;
    final inset = media.viewInsets.bottom;
    final height = wide ? media.size.height - 36 - inset : media.size.height * 0.92 - inset;

    final panel = DecoratedBox(
      decoration: BoxDecoration(
        color: PbColors.paper,
        borderRadius: BorderRadius.circular(wide ? 28 : 32),
        border: Border.all(color: const Color(0xFFF0E2C8)),
        boxShadow: const [
          BoxShadow(color: Color(0x66000000), blurRadius: 40, offset: Offset(0, 18)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(wide ? 28 : 32),
        child: Column(
          children: [
            const SizedBox(height: 5, child: ColoredBox(color: PbColors.honey)),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 14, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: 6, right: 12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: PbColors.honeyDeep, width: 2),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kicker.toUpperCase(),
                          style: PbText.body(11, weight: FontWeight.w600, color: PbColors.honeyDeep, letterSpacing: 1.3),
                        ),
                        const SizedBox(height: 4),
                        Text(title, style: PbText.display(28, weight: 580)),
                        if (subtitle != null) ...[
                          const SizedBox(height: 6),
                          Text(subtitle!, style: PbText.body(13.5, color: PbColors.inkSoft)),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: PbColors.ink),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: PbColors.line),
            Expanded(child: child),
          ],
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(wide ? 18 : 10, wide ? 18 : 0, wide ? 18 : 10, (wide ? 18 : 10) + inset),
      child: Align(
        alignment: wide ? Alignment.centerRight : Alignment.bottomCenter,
        child: SizedBox(
          width: wide ? 468 : double.infinity,
          height: height.clamp(280, media.size.height),
          child: panel,
        ),
      ),
    );
  }
}
