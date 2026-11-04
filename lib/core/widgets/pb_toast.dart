import 'package:flutter/material.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';

void showPbToast(BuildContext context, String message) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) {
      return Positioned(
        top: MediaQuery.paddingOf(context).top + 18,
        left: 16,
        right: 16,
        child: IgnorePointer(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: PbColors.ink,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: PbColors.honey, width: 1.2),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: PbColors.honey, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(message, style: PbText.body(14, color: PbColors.cream))),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
  overlay.insert(entry);
  Future<void>.delayed(const Duration(milliseconds: 2300), () {
    if (entry.mounted) entry.remove();
  });
}
