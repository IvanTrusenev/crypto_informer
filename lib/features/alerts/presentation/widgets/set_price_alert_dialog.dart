import 'dart:async';

import 'package:crypto_informer/core/extensions/context_extensions.dart';
import 'package:crypto_informer/features/alerts/domain/price_alert.dart';
import 'package:crypto_informer/features/alerts/presentation/cubit/price_alert_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
/// Dialog for setting / removing a price alert on a specific coin.
Future<void> showSetPriceAlertDialog(
  BuildContext context, {
  required String coinId,
  required String coinName,
  required double currentPrice,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => BlocProvider.value(
      value: context.read<PriceAlertCubit>(),
      child: _SetPriceAlertDialog(
        coinId: coinId,
        coinName: coinName,
        currentPrice: currentPrice,
      ),
    ),
  );
}

class _SetPriceAlertDialog extends StatefulWidget {
  const _SetPriceAlertDialog({
    required this.coinId,
    required this.coinName,
    required this.currentPrice,
  });

  final String coinId;
  final String coinName;
  final double currentPrice;

  @override
  State<_SetPriceAlertDialog> createState() => _SetPriceAlertDialogState();
}

class _SetPriceAlertDialogState extends State<_SetPriceAlertDialog> {
  late final TextEditingController _controller;
  bool _isAbove = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final existing = context.read<PriceAlertCubit>().state.alertFor(
      widget.coinId,
    );
    if (existing != null) {
      _controller = TextEditingController(
        text: existing.thresholdPrice.toString(),
      );
      _isAbove = existing.isAbove;
    } else {
      _controller = TextEditingController();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = double.tryParse(_controller.text.replaceAll(',', '.'));
    if (value == null || value <= 0) {
      setState(() => _errorText = context.l10n.alertInvalidPrice);
      return;
    }
    final alert = PriceAlert(
      coinId: widget.coinId,
      coinName: widget.coinName,
      thresholdPrice: value,
      isAbove: _isAbove,
    );
    unawaited(context.read<PriceAlertCubit>().setAlert(alert));
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.alertSetConfirmation(widget.coinName)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _remove() {
    unawaited(context.read<PriceAlertCubit>().removeAlert(widget.coinId));
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.alertRemovedConfirmation),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final priceFormat = context.usdCurrencyFormat;
    final hasExisting =
        context.read<PriceAlertCubit>().state.alertFor(widget.coinId) != null;

    return AlertDialog(
      title: Text(l10n.alertDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.alertCurrentPrice(priceFormat.format(widget.currentPrice)),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.alertThresholdLabel,
              prefixText: r'$ ',
              errorText: _errorText,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) {
              if (_errorText != null) setState(() => _errorText = null);
            },
          ),
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(
                value: true,
                label: Text(l10n.alertDirectionAbove),
                icon: const Icon(Icons.trending_up, size: 18),
              ),
              ButtonSegment(
                value: false,
                label: Text(l10n.alertDirectionBelow),
                icon: const Icon(Icons.trending_down, size: 18),
              ),
            ],
            selected: {_isAbove},
            onSelectionChanged: (s) => setState(() => _isAbove = s.first),
          ),
        ],
      ),
      actions: [
        if (hasExisting)
          TextButton(
            onPressed: _remove,
            child: Text(
              l10n.alertRemoveAction,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.alertCancelAction),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(l10n.alertSetAction),
        ),
      ],
    );
  }
}
