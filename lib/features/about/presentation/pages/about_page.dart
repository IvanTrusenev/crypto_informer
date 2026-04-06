import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('О приложении')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Crypto Informer',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Курсовой проект OTUS: информер криптовалют.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Text(
            'Архитектура',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            '• Слои domain / data / presentation по фичам\n'
            '• Репозитории и use case-ы в domain, реализация и API в data\n'
            '• Riverpod для состояния и DI\n'
            '• go_router и StatefulShellRoute для навигации\n'
            '• Material 3',
          ),
          const SizedBox(height: 24),
          Text(
            'Данные',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Курсы и описания: публичный API CoinGecko (есть лимиты запросов).',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
