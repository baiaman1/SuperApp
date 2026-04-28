part of '../home_page.dart';

class _CategoryIconOption {
  const _CategoryIconOption({
    required this.key,
    required this.label,
    required this.icon,
  });

  final String key;
  final String label;
  final IconData icon;
}

class _CategoryColorOption {
  const _CategoryColorOption({
    required this.hex,
    required this.label,
    required this.color,
  });

  final String hex;
  final String label;
  final Color color;
}

const _categoryIconOptions = [
  _CategoryIconOption(
    key: 'restaurant',
    label: 'Еда',
    icon: Icons.restaurant_rounded,
  ),
  _CategoryIconOption(
    key: 'directions_car',
    label: 'Такси',
    icon: Icons.local_taxi,
  ),
  _CategoryIconOption(key: 'home', label: 'Дом', icon: Icons.home_rounded),
  _CategoryIconOption(
    key: 'favorite',
    label: 'Здоровье',
    icon: Icons.favorite_rounded,
  ),
  _CategoryIconOption(
    key: 'movie',
    label: 'Развлечения',
    icon: Icons.movie_rounded,
  ),
  _CategoryIconOption(
    key: 'payments',
    label: 'Зарплата',
    icon: Icons.payments_rounded,
  ),
  _CategoryIconOption(key: 'work', label: 'Работа', icon: Icons.work_rounded),
  _CategoryIconOption(
    key: 'redeem',
    label: 'Подарок',
    icon: Icons.redeem_rounded,
  ),
  _CategoryIconOption(
    key: 'savings',
    label: 'Накопления',
    icon: Icons.savings_rounded,
  ),
  _CategoryIconOption(
    key: 'shopping_bag',
    label: 'Покупки',
    icon: Icons.shopping_bag_rounded,
  ),
  _CategoryIconOption(key: 'people', label: 'Люди', icon: Icons.people),
  _CategoryIconOption(
    key: 'bus',
    label: 'Проездные',
    icon: Icons.directions_bus,
  ),
  _CategoryIconOption(key: 'ligth', label: 'Коммуналка', icon: Icons.tungsten),
  _CategoryIconOption(key: 'money', label: 'Деньги', icon: Icons.local_atm),
  _CategoryIconOption(key: 'cut', label: 'Красота', icon: Icons.content_cut),
  _CategoryIconOption(key: 'woman', label: 'Женское', icon: Icons.woman),
  _CategoryIconOption(
    key: 'basket',
    label: 'Корзина',
    icon: Icons.local_grocery_store,
  ),
  _CategoryIconOption(key: 'car', label: 'Авто', icon: Icons.directions_car),
  _CategoryIconOption(
    key: 'description',
    label: 'Список',
    icon: Icons.description,
  ),
  _CategoryIconOption(key: 'school', label: 'Школа', icon: Icons.school),
];

const _categoryColorOptions = [
  _CategoryColorOption(
    hex: '#E76F51',
    label: 'Коралл',
    color: Color(0xFFE76F51),
  ),
  _CategoryColorOption(
    hex: '#F4A261',
    label: 'Песочный',
    color: Color(0xFFF4A261),
  ),
  _CategoryColorOption(
    hex: '#E9C46A',
    label: 'Золото',
    color: Color(0xFFE9C46A),
  ),
  _CategoryColorOption(hex: '#2A9D8F', label: 'Мята', color: Color(0xFF2A9D8F)),
  _CategoryColorOption(
    hex: '#457B9D',
    label: 'Синий',
    color: Color(0xFF457B9D),
  ),
  _CategoryColorOption(
    hex: '#6D597A',
    label: 'Слива',
    color: Color(0xFF6D597A),
  ),
  _CategoryColorOption(
    hex: '#264653',
    label: 'Графит',
    color: Color(0xFF264653),
  ),
  _CategoryColorOption(
    hex: '#8AB17D',
    label: 'Олива',
    color: Color(0xFF8AB17D),
  ),
];

String _defaultCategoryIconKey(CategoryKind kind) =>
    kind == CategoryKind.income ? 'payments' : 'restaurant';

String _defaultCategoryColorHex(CategoryKind kind) =>
    kind == CategoryKind.income ? '#2A9D8F' : '#E76F51';

String _normalizeCategoryIconKey(String? key, CategoryKind kind) {
  final normalized = key?.trim();
  if (normalized != null &&
      _categoryIconOptions.any((option) => option.key == normalized)) {
    return normalized;
  }

  return _defaultCategoryIconKey(kind);
}

String _normalizeCategoryColorHex(String? color, CategoryKind kind) {
  final normalized = color?.trim().toUpperCase();
  if (normalized != null &&
      _categoryColorOptions.any(
        (option) => option.hex.toUpperCase() == normalized,
      )) {
    return normalized;
  }

  return _defaultCategoryColorHex(kind);
}

IconData _iconByCategoryKey(String key) {
  return _categoryIconOptions
      .firstWhere(
        (option) => option.key == key,
        orElse: () => _categoryIconOptions.first,
      )
      .icon;
}

Color _colorByCategoryHex(String hex) {
  return _categoryColorOptions
      .firstWhere(
        (option) => option.hex.toUpperCase() == hex.toUpperCase(),
        orElse: () => _categoryColorOptions.first,
      )
      .color;
}

IconData _categoryIcon(CategoryModel category) {
  final iconKey = category.icon?.trim();
  if (iconKey != null && iconKey.isNotEmpty) {
    return _iconByCategoryKey(
      _normalizeCategoryIconKey(iconKey, category.kind),
    );
  }

  final name = category.name.toLowerCase();

  if (name.contains('еда') || name.contains('food')) {
    return Icons.restaurant_rounded;
  }
  if (name.contains('транспорт')) return Icons.directions_car_filled_rounded;
  if (name.contains('дом')) return Icons.home_rounded;
  if (name.contains('развлеч')) return Icons.movie_rounded;
  if (name.contains('зарплат')) return Icons.badge_rounded;
  if (name.contains('фриланс')) return Icons.laptop_mac_rounded;
  if (name.contains('кэш') || name.contains('cashback')) {
    return Icons.savings_rounded;
  }

  return category.kind == CategoryKind.income
      ? Icons.arrow_downward_rounded
      : Icons.circle_outlined;
}

class _DailyActivityPoint {
  const _DailyActivityPoint({
    required this.label,
    required this.income,
    required this.expense,
    required this.maxReference,
  });

  final String label;
  final double income;
  final double expense;
  final double maxReference;
}

class _CategoryBreakdownItem {
  const _CategoryBreakdownItem({
    required this.name,
    required this.amount,
    required this.share,
    required this.color,
  });

  final String name;
  final double amount;
  final double share;
  final Color color;
}

class _PeriodBounds {
  const _PeriodBounds({
    required this.start,
    required this.end,
    required this.label,
  });

  final DateTime start;
  final DateTime end;
  final String label;
}

class _TransactionTotals {
  const _TransactionTotals({required this.income, required this.expense});

  final double income;
  final double expense;
}

class _CategoryCatalogItem {
  const _CategoryCatalogItem({
    required this.name,
    required this.amount,
    required this.count,
    required this.color,
    required this.icon,
    required this.transactions,
  });

  final String name;
  final double amount;
  final int count;
  final Color color;
  final IconData icon;
  final List<TransactionItem> transactions;
}

List<_DailyActivityPoint> _buildDailyActivity(
  List<TransactionItem> transactions,
) {
  final today = DateUtils.dateOnly(DateTime.now());
  final labels = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
  final start = today.subtract(const Duration(days: 6));
  final buckets = <String, ({double income, double expense})>{};

  for (var index = 0; index < 7; index++) {
    final date = start.add(Duration(days: index));
    buckets[_dayKey(date)] = (income: 0, expense: 0);
  }

  for (final transaction in transactions) {
    final date = DateUtils.dateOnly(transaction.occurredAt);
    final key = _dayKey(date);
    if (!buckets.containsKey(key)) continue;
    final current = buckets[key]!;

    switch (transaction.entryType) {
      case TransactionEntryType.income:
        buckets[key] = (
          income: current.income + transaction.amount,
          expense: current.expense,
        );
      case TransactionEntryType.expense:
        buckets[key] = (
          income: current.income,
          expense: current.expense + transaction.amount,
        );
      case TransactionEntryType.transferOut:
      case TransactionEntryType.transferIn:
        break;
    }
  }

  final maxValue = buckets.values.fold<double>(
    0,
    (maxSoFar, value) =>
        math.max(maxSoFar, math.max(value.income, value.expense)),
  );

  return List.generate(7, (index) {
    final date = start.add(Duration(days: index));
    final value = buckets[_dayKey(date)]!;
    return _DailyActivityPoint(
      label: labels[date.weekday - 1],
      income: value.income,
      expense: value.expense,
      maxReference: maxValue,
    );
  });
}

_PeriodBounds _resolvePeriodBounds(
  _FilterPeriod period,
  DateTimeRange? customRange,
) {
  final now = DateTime.now();
  final dayStart = DateTime(now.year, now.month, now.day);

  switch (period) {
    case _FilterPeriod.day:
      return _PeriodBounds(
        start: dayStart,
        end: dayStart
            .add(const Duration(days: 1))
            .subtract(const Duration(milliseconds: 1)),
        label: 'Сегодня',
      );
    case _FilterPeriod.month:
      final monthStart = DateTime(now.year, now.month);
      final monthEnd = DateTime(
        now.year,
        now.month + 1,
      ).subtract(const Duration(milliseconds: 1));
      return _PeriodBounds(
        start: monthStart,
        end: monthEnd,
        label: 'Текущий месяц',
      );
    case _FilterPeriod.year:
      final yearStart = DateTime(now.year);
      final yearEnd = DateTime(
        now.year + 1,
      ).subtract(const Duration(milliseconds: 1));
      return _PeriodBounds(
        start: yearStart,
        end: yearEnd,
        label: 'Текущий год',
      );
    case _FilterPeriod.custom:
      final range =
          customRange ?? DateTimeRange(start: dayStart, end: dayStart);
      return _PeriodBounds(
        start: DateTime(range.start.year, range.start.month, range.start.day),
        end: DateTime(
          range.end.year,
          range.end.month,
          range.end.day,
          23,
          59,
          59,
          999,
        ),
        label:
            '${formatCompactDate(range.start)} - ${formatCompactDate(range.end)}',
      );
  }
}

_TransactionTotals _sumTransactions(List<TransactionItem> transactions) {
  var income = 0.0;
  var expense = 0.0;

  for (final transaction in transactions) {
    switch (transaction.entryType) {
      case TransactionEntryType.income:
        income += transaction.amount;
      case TransactionEntryType.expense:
        expense += transaction.amount;
      case TransactionEntryType.transferOut:
      case TransactionEntryType.transferIn:
        break;
    }
  }

  return _TransactionTotals(income: income, expense: expense);
}

List<_CategoryCatalogItem> _buildCategoryCatalog(
  List<TransactionItem> transactions,
  List<CategoryModel> categories,
) {
  final grouped = <String, List<TransactionItem>>{};
  final categoriesById = {
    for (final category in categories) category.id: category,
  };

  for (final transaction in transactions) {
    if (transaction.entryType == TransactionEntryType.transferIn ||
        transaction.entryType == TransactionEntryType.transferOut) {
      continue;
    }

    final key = transaction.categoryName?.trim().isNotEmpty == true
        ? transaction.categoryName!.trim()
        : transaction.entryType.label;
    grouped.putIfAbsent(key, () => <TransactionItem>[]).add(transaction);
  }

  final items =
      grouped.entries
          .map((entry) {
            final categoryTransactions = entry.value;
            final amount = categoryTransactions.fold<double>(
              0,
              (sum, item) => sum + item.amount,
            );
            final sample = categoryTransactions.first;
            final category =
                categoriesById[sample.categoryId] ??
                CategoryModel(
                  id: sample.categoryId ?? entry.key,
                  name: entry.key,
                  kind: sample.entryType == TransactionEntryType.income
                      ? CategoryKind.income
                      : CategoryKind.expense,
                  icon: null,
                  color: null,
                  isSystem: false,
                  isArchived: false,
                  displayOrder: 0,
                );

            return _CategoryCatalogItem(
              name: entry.key,
              amount: amount,
              count: categoryTransactions.length,
              color: _categoryAccentColor(category),
              icon: _categoryIcon(category),
              transactions: List<TransactionItem>.unmodifiable(
                categoryTransactions,
              ),
            );
          })
          .toList(growable: false)
        ..sort((left, right) => right.amount.compareTo(left.amount));

  return items;
}

List<CategoryModel> _visibleCategories(
  List<CategoryModel> categories,
  CategoryKind kind,
) {
  final items = categories
      .where((category) => category.kind == kind && !category.isArchived)
      .toList(growable: true);

  items.sort((left, right) {
    final orderCompare = left.displayOrder.compareTo(right.displayOrder);
    if (orderCompare != 0) {
      return orderCompare;
    }

    return left.name.toLowerCase().compareTo(right.name.toLowerCase());
  });

  return List<CategoryModel>.unmodifiable(items);
}

String _categoryKindLabel(CategoryKind kind) =>
    kind == CategoryKind.income ? 'Доход' : 'Расход';

Color _categoryAccentColor(CategoryModel category) {
  final raw = category.color?.trim();
  if (raw != null && raw.isNotEmpty) {
    if (_categoryColorOptions.any(
      (option) => option.hex.toUpperCase() == raw.toUpperCase(),
    )) {
      return _colorByCategoryHex(raw);
    }

    final normalized = raw.replaceFirst('#', '');
    final parsed = int.tryParse(normalized, radix: 16);
    if (parsed != null) {
      return Color(normalized.length <= 6 ? 0xFF000000 | parsed : parsed);
    }
  }

  return category.kind == CategoryKind.income
      ? const Color(0xFF16C784)
      : const Color(0xFFFF9F0A);
}

bool _canEditTransaction(TransactionItem transaction) {
  return transaction.transferGroupId == null &&
      transaction.categoryId != null &&
      (transaction.entryType == TransactionEntryType.expense ||
          transaction.entryType == TransactionEntryType.income);
}

Future<void> _showCreateTransactionSheet(
  BuildContext context,
  AppController controller, {
  TransactionEntryType initialEntryType = TransactionEntryType.expense,
  TransactionItem? transaction,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _CreateTransactionSheet(
      controller: controller,
      initialEntryType: initialEntryType,
      initialTransaction: transaction,
    ),
  );
}

Future<void> _openCategoryManagerSheet(
  BuildContext context,
  AppController controller, {
  required CategoryKind initialKind,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        _CategoryManagerSheet(controller: controller, initialKind: initialKind),
  );
}

Future<void> _openCategoryEditorSheet(
  BuildContext context,
  AppController controller, {
  required CategoryKind kind,
  CategoryModel? category,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _CategoryEditorSheet(
      controller: controller,
      kind: kind,
      category: category,
    ),
  );
}

Future<void> _openAccountEditorSheet(
  BuildContext context,
  AppController controller, {
  MoneyAccount? account,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        _AccountEditorSheet(controller: controller, account: account),
  );
}

Future<void> _openTransferSheet(
  BuildContext context,
  AppController controller,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _TransferSheet(controller: controller),
  );
}

Widget _buildTransactionActions(
  BuildContext context,
  AppController controller,
  TransactionItem transaction,
) {
  return PopupMenuButton<String>(
    onSelected: (value) async {
      if (value == 'edit') {
        await _showCreateTransactionSheet(
          context,
          controller,
          initialEntryType: transaction.entryType,
          transaction: transaction,
        );
        return;
      }

      if (value == 'delete') {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Удалить операцию?'),
            content: Text(
              'Операция "${transaction.categoryName ?? transaction.entryType.label}" будет удалена.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Удалить'),
              ),
            ],
          ),
        );

        if (confirmed != true || !context.mounted) {
          return;
        }

        try {
          await controller.deleteTransaction(transaction.id);
          if (!context.mounted) {
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Операция удалена.')),
          );
        } on Object catch (error) {
          if (!context.mounted) {
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(controller.describeError(error))),
          );
        }
      }
    },
    itemBuilder: (context) => [
      if (_canEditTransaction(transaction))
        const PopupMenuItem<String>(
          value: 'edit',
          child: Text('Редактировать'),
        ),
      const PopupMenuItem<String>(
        value: 'delete',
        child: Text('Удалить'),
      ),
    ],
  );
}

Future<void> _archiveAccount(
  BuildContext context,
  AppController controller,
  MoneyAccount account,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Скрыть счет?'),
      content: Text(
        'Счет "${account.name}" исчезнет из активного списка, но не будет удален безвозвратно.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Скрыть'),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) {
    return;
  }

  try {
    await controller.archiveAccount(account);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Счет скрыт.')));
  } on Object catch (error) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(controller.describeError(error))));
  }
}

List<_CategoryBreakdownItem> _buildCategoryBreakdown(
  List<TransactionItem> transactions,
) {
  final sums = <String, double>{};

  for (final transaction in transactions) {
    if (transaction.entryType != TransactionEntryType.expense) continue;
    final name = transaction.categoryName ?? 'Прочее';
    sums[name] = (sums[name] ?? 0) + transaction.amount;
  }

  final entries = sums.entries.toList()
    ..sort((left, right) => right.value.compareTo(left.value));

  if (entries.isEmpty) return const [];

  final maxValue = entries.first.value;
  const colors = [
    Color(0xFF4B5563),
    Color(0xFF6366F1),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFF06B6D4),
  ];

  return entries
      .take(4)
      .toList()
      .asMap()
      .entries
      .map((entry) {
        return _CategoryBreakdownItem(
          name: entry.value.key,
          amount: entry.value.value,
          share: maxValue == 0 ? 0 : entry.value.value / maxValue,
          color: colors[entry.key % colors.length],
        );
      })
      .toList(growable: false);
}

String _dayKey(DateTime date) {
  final local = DateUtils.dateOnly(date);
  return '${local.year}-${local.month}-${local.day}';
}

BoxDecoration _surfaceDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(26),
    border: Border.all(color: const Color(0xFFE5E7EB)),
    boxShadow: const [
      BoxShadow(
        color: Color(0x08111827),
        blurRadius: 24,
        offset: Offset(0, 10),
      ),
    ],
  );
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
