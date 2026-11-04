import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/core/widgets/pb_modal.dart';
import 'package:papa_bear_crm/core/widgets/pb_toast.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';

void showShopForm(BuildContext context, WidgetRef ref) {
  final shop = ref.read(crmProvider).shop;
  final name = TextEditingController(text: shop.name);
  final address = TextEditingController(text: shop.address);
  final phone = TextEditingController(text: shop.phone);
  showPbModal<void>(
    context: context,
    kicker: 'Shop details',
    title: 'Name on the bill',
    child: FormBody(
      footer: ModalFooter(
        children: [
          PbButton(
            label: 'Save shop',
            onPressed: () {
              ref.read(crmProvider.notifier).updateShop(name: name.text, address: address.text, phone: phone.text);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      children: [
        PbField(label: 'Shop name', controller: name),
        const SizedBox(height: 8),
        PbField(label: 'Address', controller: address),
        const SizedBox(height: 8),
        PbField(label: 'Phone', controller: phone),
      ],
    ),
  );
}

void showServiceForm(BuildContext context, WidgetRef ref, String id) {
  final service = ref.read(crmProvider).serviceById(id)!;
  final price = TextEditingController(text: service.price.toStringAsFixed(0));
  final minutes = TextEditingController(text: '${service.minutes}');
  showPbModal<void>(
    context: context,
    kicker: 'Price list',
    title: service.name,
    subtitle: 'Duration is what the availability check uses.',
    child: FormBody(
      footer: ModalFooter(
        children: [
          PbButton(
            label: 'Update service',
            onPressed: () {
              final error = ref.read(crmProvider.notifier).updateService(
                service.id,
                price: double.tryParse(price.text) ?? 0,
                minutes: int.tryParse(minutes.text) ?? 0,
              );
              if (error != null) {
                showPbToast(context, error);
                return;
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
      children: [
        PbField(label: 'Price', controller: price, number: true),
        const SizedBox(height: 8),
        PbField(label: 'Minutes', controller: minutes, number: true),
      ],
    ),
  );
}

void showNewServiceForm(BuildContext context, WidgetRef ref) {
  final name = TextEditingController();
  final price = TextEditingController();
  final minutes = TextEditingController();
  showPbModal<void>(
    context: context,
    kicker: 'Price list',
    title: 'New service',
    child: FormBody(
      footer: ModalFooter(
        children: [
          PbButton(
            label: 'Add service',
            onPressed: () {
              final error = ref.read(crmProvider.notifier).addService(
                name: name.text,
                price: double.tryParse(price.text) ?? 0,
                minutes: int.tryParse(minutes.text) ?? 0,
              );
              if (error != null) {
                showPbToast(context, error);
                return;
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
      children: [
        PbField(label: 'Name', controller: name),
        const SizedBox(height: 8),
        PbField(label: 'Price', controller: price, number: true),
        const SizedBox(height: 8),
        PbField(label: 'Minutes', controller: minutes, number: true),
      ],
    ),
  );
}

void showDiscountForm(BuildContext context, WidgetRef ref) {
  final current = ref.read(crmProvider).shop.discountLimitPercent;
  final value = TextEditingController(text: current.toStringAsFixed(0));
  showPbModal<void>(
    context: context,
    kicker: 'Desk limit',
    title: 'How much can reception discount?',
    child: FormBody(
      footer: ModalFooter(
        children: [
          PbButton(
            label: 'Save limit',
            onPressed: () {
              ref.read(crmProvider.notifier).setDiscountLimit(double.tryParse(value.text) ?? current);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      children: [
        PbField(label: 'Percent', controller: value, number: true),
      ],
    ),
  );
}

void showCategoryForm(BuildContext context, WidgetRef ref) {
  final name = TextEditingController();
  showPbModal<void>(
    context: context,
    kicker: 'Cash out',
    title: 'New expense category',
    child: FormBody(
      footer: ModalFooter(
        children: [
          PbButton(
            label: 'Add',
            onPressed: () {
              ref.read(crmProvider.notifier).addCategory(name.text);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      children: [
        PbField(label: 'Category', controller: name),
      ],
    ),
  );
}

void showPasswordForm(BuildContext context, WidgetRef ref, {required bool owner}) {
  final password = TextEditingController();
  showPbModal<void>(
    context: context,
    kicker: 'Access',
    title: owner ? 'Owner password' : 'Receptionist password',
    child: FormBody(
      footer: ModalFooter(
        children: [
          PbButton(
            label: 'Update password',
            onPressed: () {
              final error = ref.read(crmProvider.notifier).setPassword(owner: owner, password: password.text);
              if (error != null) {
                showPbToast(context, error);
                return;
              }
              showPbToast(context, 'Password updated for the next sign-in.');
              Navigator.pop(context);
            },
          ),
        ],
      ),
      children: [
        PbField(label: 'New password', controller: password),
      ],
    ),
  );
}
