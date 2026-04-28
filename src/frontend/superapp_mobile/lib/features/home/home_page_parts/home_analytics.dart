part of '../home_page.dart';

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.transactions, required this.currencyCode});

  final List<TransactionItem> transactions;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final points = _buildDailyActivity(transactions);

    return _SectionSurface(
      title: 'Активность за 7 дней',
      subtitle: 'Доходы и расходы по дням.',
      child: Column(
        children: [
          Row(
            children: const [
              _LegendDot(color: Color(0xFF16C784), label: 'Доход'),
              SizedBox(width: 12),
              _LegendDot(color: Color(0xFFFF9F0A), label: 'Расход'),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 208,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: points
                  .map(
                    (point) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _DayActivityBar(point: point),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SoftValueCard(
                  label: 'За 7 дней пришло',
                  value: formatMoney(
                    points.fold(0.0, (sum, point) => sum + point.income),
                    currencyCode: currencyCode,
                  ),
                  tone: const Color(0xFF16C784),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SoftValueCard(
                  label: 'За 7 дней ушло',
                  value: formatMoney(
                    points.fold(0.0, (sum, point) => sum + point.expense),
                    currencyCode: currencyCode,
                  ),
                  tone: const Color(0xFFFF9F0A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _DayActivityBar extends StatelessWidget {
  const _DayActivityBar({required this.point});

  final _DailyActivityPoint point;

  @override
  Widget build(BuildContext context) {
    final maxValue = point.maxReference <= 0 ? 1.0 : point.maxReference;
    final incomeHeight = point.income <= 0
        ? 6.0
        : math.max(12.0, 128.0 * point.income / maxValue).toDouble();
    final expenseHeight = point.expense <= 0
        ? 6.0
        : math.max(12.0, 128.0 * point.expense / maxValue).toDouble();

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 18,
                    height: incomeHeight,
                    decoration: BoxDecoration(
                      color: point.income > 0
                          ? const Color(0xFF16C784)
                          : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 18,
                    height: expenseHeight,
                    decoration: BoxDecoration(
                      color: point.expense > 0
                          ? const Color(0xFFFF9F0A)
                          : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(point.label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _SoftValueCard extends StatelessWidget {
  const _SoftValueCard({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: tone),
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdownCard extends StatelessWidget {
  const _CategoryBreakdownCard({
    required this.transactions,
    required this.currencyCode,
  });

  final List<TransactionItem> transactions;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final items = _buildCategoryBreakdown(transactions);

    return _SectionSurface(
      title: 'Диаграмма расходов',
      // subtitle: 'Самые заметные категории в текущем списке операций.',
      child: items.isEmpty
          ? const Text(
              'Добавь расходы, и здесь появится диаграмма по категориям.',
            )
          : Column(
              children: items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _CategoryBar(
                        item: item,
                        currencyCode: currencyCode,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({required this.item, required this.currencyCode});

  final _CategoryBreakdownItem item;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.name,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Text(
              formatMoney(item.amount, currencyCode: currencyCode),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Stack(
            children: [
              Container(height: 10, color: const Color(0xFFE5E7EB)),
              FractionallySizedBox(
                widthFactor: item.share.clamp(0, 1),
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFF111318), item.color],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TransactionsCard extends StatelessWidget {
  const _TransactionsCard({
    required this.controller,
    required this.page,
    required this.currencyCode,
  });

  final AppController controller;
  final TransactionPage page;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return _SectionSurface(
      title: 'Операции',
      subtitle: '${page.totalCount} записей в текущем срезе.',
      child: page.items.isEmpty
          ? const Text('Пока нет операций по выбранному фильтру.')
          : Column(
              children: page.items
                  .map(
                    (transaction) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TransactionTile(
                        transaction: transaction,
                        currencyCode: currencyCode,
                        trailing: _buildTransactionActions(
                          context,
                          controller,
                          transaction,
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.currencyCode,
    this.trailing,
  });

  final TransactionItem transaction;
  final String currencyCode;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isPositive =
        transaction.entryType == TransactionEntryType.income ||
        transaction.entryType == TransactionEntryType.transferIn;
    final accent = switch (transaction.entryType) {
      TransactionEntryType.income => const Color(0xFF047857),
      TransactionEntryType.expense => const Color(0xFFB45309),
      TransactionEntryType.transferOut ||
      TransactionEntryType.transferIn => const Color(0xFF475467),
    };
    final signedAmount = isPositive ? transaction.amount : -transaction.amount;
    final note = transaction.note?.trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Icon(switch (transaction.entryType) {
              TransactionEntryType.income => Icons.south_west_rounded,
              TransactionEntryType.expense => Icons.north_east_rounded,
              TransactionEntryType.transferOut ||
              TransactionEntryType.transferIn => Icons.compare_arrows_rounded,
            }, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.categoryName ?? transaction.entryType.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.accountName} · ${formatShortDate(transaction.occurredAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (note != null && note.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(note, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatMoney(
                  signedAmount,
                  currencyCode: currencyCode,
                  signed: true,
                ),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: accent),
              ),
              if (trailing != null) ...[const SizedBox(height: 8), trailing!],
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionSurface(
      title: 'Данные не загрузились',
      subtitle: 'Проверь backend или попробуй перезагрузить контент.',
      child: FilledButton.icon(
        onPressed: controller.refreshHome,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Обновить'),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFFB45309)),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _SectionSurface extends StatelessWidget {
  const _SectionSurface({this.title, this.subtitle, required this.child});

  final String? title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _surfaceDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 6),
          ],
          if (subtitle != null) ...[
            Text(subtitle!, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 18),
          ],
          child,
        ],
      ),
    );
  }
}
