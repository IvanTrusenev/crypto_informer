import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class MarketSearchField extends StatelessWidget {
  const MarketSearchField({
    required this.controller,
    required this.l10n,
    required this.onChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController controller;
  final AppLocalizations l10n;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            hintText: l10n.marketSearchHint,
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: onClear,
                  ),
          ),
        );
      },
    );
  }
}
