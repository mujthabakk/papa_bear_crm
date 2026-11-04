import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';

class PbButton extends StatelessWidget {
  const PbButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.primary = true,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool primary;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: primary ? PbColors.cream : PbColors.ink),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: PbText.body(
              14.5,
              weight: FontWeight.w600,
              color: primary ? PbColors.cream : PbColors.ink,
            ),
          ),
        ),
      ],
    );

    final button = DecoratedBox(
      decoration: BoxDecoration(
        color: onPressed == null
            ? PbColors.line
            : primary
            ? PbColors.ink
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: primary ? null : Border.all(color: PbColors.line),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: child,
          ),
        ),
      ),
    );
    if (!expand) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

class PbField extends StatelessWidget {
  const PbField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboard,
    this.maxLines = 1,
    this.number = false,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboard;
  final int maxLines;
  final bool number;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: PbText.body(12.5, weight: FontWeight.w600, color: PbColors.inkSoft)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          maxLines: maxLines,
          inputFormatters: number ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))] : null,
          style: PbText.body(15),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

class PbChoice extends StatelessWidget {
  const PbChoice({super.key, required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? PbColors.ink : PbColors.cream,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: PbText.body(13, weight: FontWeight.w600, color: selected ? PbColors.cream : PbColors.ink),
          ),
        ),
      ),
    );
  }
}

class PbPill extends StatelessWidget {
  const PbPill({super.key, required this.label, required this.background, required this.foreground});

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: PbText.body(12, weight: FontWeight.w600, color: foreground)),
    );
  }
}

class PbCard extends StatelessWidget {
  const PbCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.color = PbColors.paper, this.onTap});

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: PbColors.line),
      ),
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: card,
      ),
    );
  }
}

class PbPage extends StatelessWidget {
  const PbPage({
    super.key,
    required this.kicker,
    required this.title,
    required this.children,
    this.subtitle,
    this.actions = const [],
  });

  final String kicker;
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 980;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(wide ? 28 : 16, wide ? 22 : 8, wide ? 28 : 16, 28),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(
                kicker.toUpperCase(),
                style: PbText.body(11, weight: FontWeight.w600, color: PbColors.honeyDeep, letterSpacing: 1.4),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: PbText.display(wide ? 36 : 30)),
                        if (subtitle != null) ...[
                          const SizedBox(height: 6),
                          Text(subtitle!, style: PbText.body(14.5, color: PbColors.inkSoft)),
                        ],
                      ],
                    ),
                  ),
                  if (actions.isNotEmpty) Wrap(spacing: 8, runSpacing: 8, children: actions),
                ],
              ),
              const SizedBox(height: 18),
              ...children,
            ]),
          ),
        ),
      ],
    );
  }
}

class MetricTile extends StatelessWidget {
  const MetricTile({super.key, required this.label, required this.value, this.hint, this.onTap});

  final String label;
  final String value;
  final String? hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PbCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: PbText.body(12.5, weight: FontWeight.w600, color: PbColors.muted)),
          const SizedBox(height: 8),
          Text(value, style: PbText.display(26, weight: 600)),
          if (hint != null) ...[
            const SizedBox(height: 6),
            Text(hint!, style: PbText.body(12.5, color: PbColors.inkSoft)),
          ],
        ],
      ),
    );
  }
}

class ModalFooter extends StatelessWidget {
  const ModalFooter({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      decoration: const BoxDecoration(
        color: PbColors.paper,
        border: Border(top: BorderSide(color: PbColors.line)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: children[i]),
          ],
        ],
      ),
    );
  }
}

class FormBody extends StatelessWidget {
  const FormBody({super.key, required this.children, this.footer});

  final List<Widget> children;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            children: children,
          ),
        ),
        ?footer,
      ],
    );
  }
}
