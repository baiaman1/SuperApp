part of '../home_page.dart';

class _CreateTransactionSheet extends StatefulWidget {
  const _CreateTransactionSheet({
    required this.controller,
    required this.initialEntryType,
    this.initialTransaction,
  });

  final AppController controller;
  final TransactionEntryType initialEntryType;
  final TransactionItem? initialTransaction;

  @override
  State<_CreateTransactionSheet> createState() =>
      _CreateTransactionSheetState();
}

class _CreateTransactionSheetState extends State<_CreateTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late TransactionEntryType _entryType;
  String? _selectedAccountId;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  String? _error;

  bool get _isEditing => widget.initialTransaction != null;

  @override
  void initState() {
    super.initState();
    final initialTransaction = widget.initialTransaction;
    _entryType = initialTransaction?.entryType ?? widget.initialEntryType;
    final homeData = widget.controller.homeData;
    _selectedAccountId =
        initialTransaction?.accountId ?? homeData?.accounts.firstOrNull?.id;
    _selectedCategoryId =
        initialTransaction?.categoryId ??
        widget.controller.categoriesFor(_entryType).firstOrNull?.id;
    _selectedDate = initialTransaction?.occurredAt ?? DateTime.now();
    if (initialTransaction != null) {
      _amountController.text = initialTransaction.amount.toStringAsFixed(
        initialTransaction.amount % 1 == 0 ? 0 : 2,
      );
      _noteController.text = initialTransaction.note ?? '';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accounts =
        widget.controller.homeData?.accounts ?? const <MoneyAccount>[];
    final categories = widget.controller.categoriesFor(_entryType);
    if (categories.isNotEmpty &&
        categories.every((item) => item.id != _selectedCategoryId)) {
      _selectedCategoryId = categories.first.id;
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 14,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: ListView(
          shrinkWrap: true,
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
              _isEditing ? 'Редактировать операцию' : 'Новая операция',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            // const SizedBox(height: 8),
            // Text(
            //   _isEditing
            //       ? 'Исправь сумму, счет, категорию или дату в той же форме.'
            //       : 'Подробный ввод с датой и комментарием.',
            // ),
            const SizedBox(height: 18),
            Form(
              key: _formKey,
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
                    onSelectionChanged: _isSaving
                        ? null
                        : (selection) {
                            setState(() {
                              _entryType = selection.first;
                              _selectedCategoryId = widget.controller
                                  .categoriesFor(_entryType)
                                  .firstOrNull
                                  ?.id;
                            });
                          },
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Сумма',
                      hintText: '12500',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Введи сумму.';
                      }
                      final amount = double.tryParse(
                        value.replaceAll(',', '.'),
                      );
                      if (amount == null || amount <= 0) {
                        return 'Сумма должна быть больше нуля.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    key: ValueKey(
                      'sheet-account-${_selectedAccountId ?? 'none'}',
                    ),
                    initialValue: _selectedAccountId,
                    decoration: const InputDecoration(labelText: 'Счет'),
                    items: accounts
                        .map(
                          (account) => DropdownMenuItem<String>(
                            value: account.id,
                            child: Text(account.name),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: _isSaving
                        ? null
                        : (value) => setState(() => _selectedAccountId = value),
                    validator: (value) => value == null ? 'Выбери счет.' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    key: ValueKey(
                      'sheet-category-${_selectedCategoryId ?? 'none'}',
                    ),
                    initialValue: _selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'Категория'),
                    items: categories
                        .map(
                          (category) => DropdownMenuItem<String>(
                            value: category.id,
                            child: Text(category.name),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: _isSaving
                        ? null
                        : (value) =>
                              setState(() => _selectedCategoryId = value),
                    validator: (value) =>
                        value == null ? 'Выбери категорию.' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Комментарий',
                      hintText: 'Необязательно',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _isSaving ? null : _pickDate,
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text('Дата: ${formatCompactDate(_selectedDate)}'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    _InfoBanner(message: _error!),
                  ],
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _submit,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(_isSaving ? 'Сохраняем...' : 'Сохранить'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _selectedDate,
      locale: const Locale('ru', 'RU'),
    );

    if (!mounted || picked == null) {
      return;
    }

    setState(() {
      _selectedDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        DateTime.now().hour,
        DateTime.now().minute,
      );
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final accountId = _selectedAccountId;
    final categoryId = _selectedCategoryId;
    if (accountId == null || categoryId == null) {
      setState(() => _error = 'Выбери счет и категорию.');
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final amount = double.parse(_amountController.text.replaceAll(',', '.'));

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final note = _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim();
      if (_isEditing) {
        await widget.controller.updateTransaction(
          UpdateTransactionDraft(
            transactionId: widget.initialTransaction!.id,
            accountId: accountId,
            categoryId: categoryId,
            entryType: _entryType,
            amount: amount,
            note: note,
            occurredAt: _selectedDate,
          ),
        );
      } else {
        await widget.controller.createTransaction(
          CreateTransactionDraft(
            accountId: accountId,
            categoryId: categoryId,
            entryType: _entryType,
            amount: amount,
            note: note,
            occurredAt: _selectedDate,
          ),
        );
      }

      if (!mounted) {
        return;
      }

      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Операция обновлена.' : 'Операция добавлена.',
          ),
        ),
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
          _isSaving = false;
        });
      }
    }
  }
}

IconData _accountIcon(AccountKind kind) => switch (kind) {
  AccountKind.cash => Icons.payments_outlined,
  AccountKind.bankCard => Icons.credit_card_rounded,
  AccountKind.savings => Icons.savings_outlined,
  AccountKind.credit => Icons.account_balance_wallet_outlined,
  AccountKind.investment => Icons.trending_up_rounded,
};
