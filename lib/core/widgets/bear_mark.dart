import 'package:flutter/material.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';

class BearMark extends StatelessWidget {
  const BearMark({super.key, this.size = 42, this.onDark = false});

  final double size;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final face = onDark ? PbColors.honey : PbColors.ink;
    final ear = onDark ? PbColors.honey : PbColors.honey;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: size * 0.02,
            top: 0,
            child: _ear(size * 0.34, ear),
          ),
          Positioned(
            right: size * 0.02,
            top: 0,
            child: _ear(size * 0.34, ear),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: size * 0.78,
              decoration: BoxDecoration(
                color: face,
                borderRadius: BorderRadius.circular(size * 0.28),
              ),
              alignment: Alignment.center,
              child: Text(
                'PB',
                style: PbText.body(
                  size * 0.28,
                  weight: FontWeight.w700,
                  color: onDark ? PbColors.ink : PbColors.cream,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ear(double earSize, Color color) {
    return Container(
      width: earSize,
      height: earSize,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
