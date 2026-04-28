part of '../home_page.dart';

class QuickComposerCard extends StatefulWidget {
  const QuickComposerCard({super.key, required this.controller});

  final AppController controller;

  @override
  State<QuickComposerCard> createState() => _QuickComposerCardState();
}

class _QuickComposerCardState extends State<QuickComposerCard> {
  TransactionEntryType _entryType = TransactionEntryType.expense;
  String _amount = '';
  String? _selectedAccountId;
  bool _isSubmitting = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedAccountId ??=
        widget.controller.selectedAccountId ??
        widget.controller.homeData?.accounts.firstOrNull?.id;
  }

  @override
  Widget build(BuildContext context) {
    final accounts =
        widget.controller.homeData?.accounts ?? const <MoneyAccount>[];
    final categories = widget.controller.categoriesFor(_entryType);
    final featuredCategories = categories.take(7).toList(growable: false);

    if (_selectedAccountId == null && accounts.isNotEmpty) {
      _selectedAccountId = accounts.first.id;
    }

    return _SectionSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<TransactionEntryType>(
            segments: const [
              ButtonSegment<TransactionEntryType>(
                value: TransactionEntryType.expense,
                label: Text('Расход'),
                icon: Icon(Icons.remove_circle_outline_rounded),
              ),
              ButtonSegment<TransactionEntryType>(
                value: TransactionEntryType.income,
                label: Text('Доход'),
                icon: Icon(Icons.add_circle_outline_rounded),
              ),
            ],
            selected: {_entryType},
            onSelectionChanged: _isSubmitting
                ? null
                : (selection) {
                    setState(() {
                      _entryType = selection.first;
                      _error = null;
                    });
                  },
          ),
          const SizedBox(height: 16),
          if (accounts.isEmpty)
            const _InfoBanner(message: 'Сначала создай хотя бы один счет.')
          else
            _QuickAccountSelector(
              account: accounts.firstWhere(
                (item) => item.id == _selectedAccountId,
                orElse: () => accounts.first,
              ),
              enabled: !_isSubmitting,
              onTap: accounts.length <= 1 ? null : () => _pickAccount(accounts),
            ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Text(
              _amountLabel,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: const Color(0xFF111318),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _Numpad(
            enabled: !_isSubmitting,
            onDigit: _appendDigit,
            onDoubleZero: _appendDoubleZero,
            onBackspace: _removeDigit,
            onClear: _clearAmount,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Категории',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton.icon(
                onPressed: _isSubmitting
                    ? null
                    : () => _openCategoryManagerSheet(
                        context,
                        widget.controller,
                        initialKind: _entryType.categoryKind,
                      ),
                icon: const Icon(Icons.tune_rounded, size: 18),
                label: const Text('Управлять'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (categories.isEmpty)
            const Text('Для этого типа операций пока нет категорий.')
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ...featuredCategories
                    .map(
                      (category) => _CategoryShortcut(
                        category: category,
                        enabled: !_isSubmitting,
                        onTap: () => _submit(category),
                      ),
                    )
                    .toList(growable: false),
                _CategoryMoreShortcut(
                  enabled: !_isSubmitting,
                  onTap: () => _pickCategory(categories),
                ),
              ],
            ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            _InfoBanner(message: _error!),
          ],
        ],
      ),
    );
  }

  String get _amountLabel => _amount.isEmpty ? '0' : _amount;

  void _appendDigit(String digit) {
    setState(() {
      if (_amount == '0') {
        _amount = digit;
      } else {
        _amount += digit;
      }
      _error = null;
    });
  }

  void _appendDoubleZero() {
    setState(() {
      if (_amount.isEmpty) {
        _amount = '0';
      } else {
        _amount += '00';
      }
      _error = null;
    });
  }

  void _removeDigit() {
    setState(() {
      if (_amount.isEmpty) {
        return;
      }
      _amount = _amount.substring(0, _amount.length - 1);
    });
  }

  void _clearAmount() {
    setState(() {
      _amount = '';
      _error = null;
    });
  }

  Future<void> _pickAccount(List<MoneyAccount> accounts) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _QuickAccountPickerSheet(
        accounts: accounts,
        selectedAccountId: _selectedAccountId,
      ),
    );

    if (!mounted || selected == null) {
      return;
    }

    setState(() {
      _selectedAccountId = selected;
      _error = null;
    });
  }

  Future<void> _pickCategory(List<CategoryModel> categories) async {
    final selected = await showModalBottomSheet<CategoryModel>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _QuickCategoryPickerSheet(
        entryType: _entryType,
        categories: categories,
      ),
    );

    if (!mounted || selected == null) {
      return;
    }

    await _submit(selected);
  }

  Future<void> _submit(CategoryModel category) async {
    if (_isSubmitting) {
      return;
    }

    final accountId = _selectedAccountId;
    final amount = double.tryParse(_amount.replaceAll(' ', ''));
    if (accountId == null) {
      setState(() => _error = 'Сначала выбери счет.');
      return;
    }

    if (amount == null || amount <= 0) {
      setState(() => _error = 'Сначала введи сумму.');
      return;
    }

    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await widget.controller.createTransaction(
        CreateTransactionDraft(
          accountId: accountId,
          categoryId: category.id,
          entryType: _entryType,
          amount: amount,
          occurredAt: DateTime.now(),
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _amount = '';
      });
      messenger.showSnackBar(
        SnackBar(content: Text('Добавлено: ${category.name}')),
      );
    } on Object catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = error is ApiException
            ? error.message
            : widget.controller.describeError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

class _Numpad extends StatelessWidget {
  const _Numpad({
    required this.enabled,
    required this.onDigit,
    required this.onDoubleZero,
    required this.onBackspace,
    required this.onClear,
  });

  final bool enabled;
  final ValueChanged<String> onDigit;
  final VoidCallback onDoubleZero;
  final VoidCallback onBackspace;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['00', '0', 'Del'],
    ];

    return Column(
      children: rows
          .map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: row
                    .map(
                      (value) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: _NumpadButton(
                            label: value,
                            enabled: enabled,
                            onTap: () {
                              if (!enabled) {
                                return;
                              }

                              if (value == 'Del') {
                                onBackspace();
                                return;
                              }

                              if (value == '00') {
                                onDoubleZero();
                                return;
                              }

                              onDigit(value);
                            },
                            onLongPress: value == 'Del' ? onClear : null,
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _NumpadButton extends StatelessWidget {
  const _NumpadButton({
    required this.label,
    required this.enabled,
    required this.onTap,
    this.onLongPress,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      onLongPress: enabled ? onLongPress : null,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFF9FAFB) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: const Color(0xFF111318)),
        ),
      ),
    );
  }
}

class _CategoryShortcut extends StatelessWidget {
  const _CategoryShortcut({
    required this.category,
    required this.enabled,
    required this.onTap,
  });

  final CategoryModel category;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconTone = _categoryAccentColor(category);
    final tone = iconTone.withValues(alpha: 0.10);

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 96,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: tone,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_categoryIcon(category), color: iconTone),
            ),
            const SizedBox(height: 12),
            Text(
              category.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryMoreShortcut extends StatelessWidget {
  const _CategoryMoreShortcut({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 96,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.apps_rounded,
                color: Color(0xFF111318),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Все',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickCategoryPickerSheet extends StatelessWidget {
  const _QuickCategoryPickerSheet({
    required this.entryType,
    required this.categories,
  });

  final TransactionEntryType entryType;
  final List<CategoryModel> categories;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.78,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Все категории',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                entryType == TransactionEntryType.income
                    ? 'Выбери категорию дохода для быстрого добавления.'
                    : 'Выбери категорию расхода для быстрого добавления.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.84,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _SheetCategoryShortcut(
                      category: category,
                      onTap: () => Navigator.of(context).pop(category),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetCategoryShortcut extends StatelessWidget {
  const _SheetCategoryShortcut({
    required this.category,
    required this.onTap,
  });

  final CategoryModel category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconTone = _categoryAccentColor(category);
    final tone = iconTone.withValues(alpha: 0.10);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: tone,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_categoryIcon(category), color: iconTone),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Text(
                category.name,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
