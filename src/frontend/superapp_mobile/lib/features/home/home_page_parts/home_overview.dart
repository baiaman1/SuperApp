part of '../home_page.dart';

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = controller.currentUser;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: _surfaceDecoration(),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF111318),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.wallet_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Som',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF111318),
              ),
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            color: Colors.white,
            onSelected: (value) {
              if (value == 'logout') {
                controller.signOut();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(value: 'logout', child: Text('Выйти')),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    size: 18,
                    color: Color(0xFF111318),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user?.fullName.split(' ').first ?? 'Профиль',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: const Color(0xFF111318),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.summary, required this.currencyCode});

  final DashboardSummary summary;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final netTone = summary.net >= 0
        ? const Color(0xFF10B981)
        : const Color(0xFFF59E0B);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF111318),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Общий баланс',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFB7BDC9),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formatMoney(summary.totalBalance, currencyCode: currencyCode),
              style: theme.textTheme.displaySmall?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _OverviewMetric(
                    label: 'Доход',
                    value: formatMoney(
                      summary.totalIncome,
                      currencyCode: currencyCode,
                    ),
                    tone: const Color(0xFF34D399),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _OverviewMetric(
                    label: 'Расход',
                    value: formatMoney(
                      summary.totalExpense,
                      currencyCode: currencyCode,
                    ),
                    tone: const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _OverviewMetric(
                    label: 'Поток',
                    value: formatMoney(
                      summary.net,
                      currencyCode: currencyCode,
                      signed: true,
                    ),
                    tone: netTone,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({
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
        color: const Color(0xFF181C24),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFFB7BDC9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(color: tone),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _AccountsStrip extends StatelessWidget {
  const _AccountsStrip({
    required this.accounts,
    required this.selectedAccountId,
    required this.onSelect,
  });

  final List<MoneyAccount> accounts;
  final String? selectedAccountId;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    return _SectionSurface(
      title: 'Счета',
      subtitle: 'Остатки по основным кошелькам.',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: accounts
              .map(
                (account) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _AccountCard(
                    account: account,
                    selected: account.id == selectedAccountId,
                    onTap: () => onSelect(
                      account.id == selectedAccountId ? null : account.id,
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.account,
    required this.selected,
    required this.onTap,
  });

  final MoneyAccount account;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = selected
        ? const Color(0xFF111318)
        : const Color(0xFFF9FAFB);
    final foreground = selected ? Colors.white : const Color(0xFF111318);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? const Color(0xFF111318) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_accountIcon(account.kind), color: foreground),
            const SizedBox(height: 18),
            Text(
              account.name,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: foreground),
            ),
            const SizedBox(height: 4),
            Text(
              account.kind.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: selected
                    ? const Color(0xFFB7BDC9)
                    : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              formatMoney(account.balance, currencyCode: account.currencyCode),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}
