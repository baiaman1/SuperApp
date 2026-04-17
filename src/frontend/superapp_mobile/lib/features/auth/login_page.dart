import 'package:flutter/material.dart';
import 'package:superapp_mobile/features/home/app_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: 'demo@superapp.local');
    _passwordController = TextEditingController(text: 'Demo123!');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 880;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _PreviewPanel(
                            baseUrl: widget.controller.apiBaseUrl,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(child: _buildFormCard(theme)),
                      ],
                    )
                  : Column(
                      children: [
                        _PreviewPanel(baseUrl: widget.controller.apiBaseUrl),
                        const SizedBox(height: 16),
                        _buildFormCard(theme),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(ThemeData theme) {
    return DecoratedBox(
      decoration: _cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Вход', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Локальный вход для разработки Flutter-клиента и проверки сценариев.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'demo@superapp.local',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Укажи email.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  hintText: 'Demo123!',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Укажи пароль.';
                  }

                  return null;
                },
              ),
              if (widget.controller.authError != null) ...[
                const SizedBox(height: 14),
                _InlineError(message: widget.controller.authError!),
              ],
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: widget.controller.isAuthenticating ? null : _submit,
                icon: widget.controller.isAuthenticating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_rounded),
                label: Text(
                  widget.controller.isAuthenticating
                      ? 'Входим...'
                      : 'Продолжить',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _applyPreset(
                        email: 'demo@superapp.local',
                        password: 'Demo123!',
                      ),
                      child: const Text('Demo'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _applyPreset(
                        email: 'admin@superapp.local',
                        password: 'Admin123!',
                      ),
                      child: const Text('Admin'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Тестовые доступы'),
                      SizedBox(height: 10),
                      Text('demo@superapp.local / Demo123!'),
                      SizedBox(height: 6),
                      Text('admin@superapp.local / Admin123!'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await widget.controller.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _applyPreset({required String email, required String password}) {
    _emailController.text = email;
    _passwordController.text = password;
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({required this.baseUrl});

  final String baseUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: _cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF111318),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.wallet_rounded, color: Colors.white),
            ),
            const SizedBox(height: 18),
            Text(
              'Спокойный учет денег без визуального шума.',
              style: theme.textTheme.displaySmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Фокус на простом сценарии: быстро открыть, добавить операцию и сразу понять картину по деньгам.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: const [
                  _PreviewMetric(label: 'Баланс', value: '1 214 500 сом'),
                  SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _PreviewStat(
                          label: 'Доход',
                          value: '+570 000 сом',
                          tone: Color(0xFF047857),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _PreviewStat(
                          label: 'Расход',
                          value: '-158 200 сом',
                          tone: Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _featureChip(context, 'Быстрое добавление'),
                _featureChip(context, 'Хороший контраст'),
                _featureChip(context, 'Несколько счетов'),
                _featureChip(context, 'Графики и диаграммы'),
              ],
            ),
            const SizedBox(height: 18),
            Text('Backend: $baseUrl', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _featureChip(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

class _PreviewMetric extends StatelessWidget {
  const _PreviewMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        Text(value, style: theme.textTheme.headlineMedium),
      ],
    );
  }
}

class _PreviewStat extends StatelessWidget {
  const _PreviewStat({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(color: tone),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Color(0xFFB42318)),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(28),
    border: Border.all(color: const Color(0xFFE5E7EB)),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0A111827),
        blurRadius: 24,
        offset: Offset(0, 10),
      ),
    ],
  );
}
