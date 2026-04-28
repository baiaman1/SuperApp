part of '../home_page.dart';

class _AccountEditorSheet extends StatefulWidget {
  const _AccountEditorSheet({required this.controller, this.account});

  final AppController controller;
  final MoneyAccount? account;

  @override
  State<_AccountEditorSheet> createState() => _AccountEditorSheetState();
}

class _AccountEditorSheetState extends State<_AccountEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _currencyController;
  late final TextEditingController _openingBalanceController;
  late AccountKind _kind;
  bool _isSaving = false;
  String? _error;

  bool get _isEditing => widget.account != null;

  @override
  void initState() {
    super.initState();
    final account = widget.account;
    _nameController = TextEditingController(text: account?.name ?? '');
    _currencyController = TextEditingController(
      text: account?.currencyCode ?? widget.controller.currencyCode,
    );
    _openingBalanceController = TextEditingController(
      text: account == null ? '0' : '',
    );
    _kind = account?.kind ?? AccountKind.cash;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currencyController.dispose();
    _openingBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              _isEditing ? 'Редактировать счет' : 'Новый счет',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            // Text(
            //   _isEditing
            //       ? 'Название и тип можно поменять в любой момент.'
            //       : 'Создай отдельный счет для наличных, карты или накоплений.',
            // ),
            const SizedBox(height: 18),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Название'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Укажи название счета.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<AccountKind>(
                    initialValue: _kind,
                    decoration: const InputDecoration(labelText: 'Тип счета'),
                    items: AccountKind.values
                        .map(
                          (kind) => DropdownMenuItem<AccountKind>(
                            value: kind,
                            child: Text(kind.label),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: _isSaving
                        ? null
                        : (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _kind = value;
                            });
                          },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _currencyController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(labelText: 'Валюта'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Укажи валюту.';
                      }
                      return null;
                    },
                  ),
                  if (!_isEditing) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _openingBalanceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Стартовый баланс',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Укажи стартовый баланс.';
                        }
                        if (double.tryParse(value.replaceAll(',', '.')) ==
                            null) {
                          return 'Введи число.';
                        }
                        return null;
                      },
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    const _InfoBanner(
                      message: 'Баланс меняется через операции и переводы.',
                    ),
                  ],
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
                    label: Text(
                      _isSaving
                          ? 'Сохраняем...'
                          : _isEditing
                          ? 'Сохранить'
                          : 'Создать',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      if (_isEditing) {
        await widget.controller.updateAccount(
          UpdateAccountDraft(
            accountId: widget.account!.id,
            name: _nameController.text.trim(),
            currencyCode: _currencyController.text.trim().toUpperCase(),
            kind: _kind,
            isArchived: false,
            displayOrder: widget.account!.displayOrder,
          ),
        );
      } else {
        await widget.controller.createAccount(
          CreateAccountDraft(
            name: _nameController.text.trim(),
            currencyCode: _currencyController.text.trim().toUpperCase(),
            kind: _kind,
            openingBalance: double.parse(
              _openingBalanceController.text.replaceAll(',', '.'),
            ),
          ),
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Счет обновлен.' : 'Счет создан.')),
      );
    } on Object catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = widget.controller.describeError(error);
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

class _TransferSheet extends StatefulWidget {
  const _TransferSheet({required this.controller});

  final AppController controller;

  @override
  State<_TransferSheet> createState() => _TransferSheetState();
}

class _TransferSheetState extends State<_TransferSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _fromAccountId;
  String? _toAccountId;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final accounts =
        widget.controller.homeData?.accounts ?? const <MoneyAccount>[];
    if (accounts.length >= 2) {
      _fromAccountId = accounts.first.id;
      _toAccountId = accounts[1].id;
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
        child: SingleChildScrollView(
          // ✅ вместо ListView
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
                'Перевод между счетами',
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: 18),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    /// 🔴 СО СЧЕТА
                    DropdownButtonFormField<String>(
                      initialValue: _fromAccountId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Со счета'),

                      selectedItemBuilder: (context) {
                        return accounts.map((account) {
                          return Text(
                            '${account.name} '
                            ' - ${account.balance} ${account.currencyCode}',
                            overflow: TextOverflow.ellipsis,
                          );
                        }).toList();
                      },

                      items: accounts.map((account) {
                        return DropdownMenuItem<String>(
                          value: account.id,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(account.name),
                              Text(
                                formatMoney(
                                  account.balance,
                                  currencyCode: account.currencyCode,
                                ),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      onChanged: _isSaving
                          ? null
                          : (value) => setState(() => _fromAccountId = value),

                      validator: (value) =>
                          value == null ? 'Выбери счет.' : null,
                    ),

                    const SizedBox(height: 16),

                    /// 🔥 Dropdown с балансом
                    DropdownButtonFormField<String>(
                      initialValue: _toAccountId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'На счет'),

                      /// 👇 ВЫБРАННОЕ значение (ТОЛЬКО 1 строка)
                      selectedItemBuilder: (context) {
                        return accounts.map((account) {
                          return Text(
                            '${account.name} '
                            ' - ${account.balance} ${account.currencyCode}',
                            overflow: TextOverflow.ellipsis,
                          );
                        }).toList();
                      },

                      /// 👇 СПИСОК (здесь можно 2 строки)
                      items: accounts.map((account) {
                        return DropdownMenuItem<String>(
                          value: account.id,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(account.name),
                              Text(
                                formatMoney(
                                  account.balance,
                                  currencyCode: account.currencyCode,
                                ),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      onChanged: _isSaving
                          ? null
                          : (value) => setState(() => _toAccountId = value),
                    ),

                    const SizedBox(height: 16),

                    /// 💰 Сумма
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(labelText: 'Сумма'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Укажи сумму.';
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

                    /// 📝 Комментарий
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Комментарий',
                        hintText: 'Необязательно',
                      ),
                      maxLines: 2,
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      _InfoBanner(message: _error!),
                    ],

                    const SizedBox(height: 20),

                    /// 🚀 Кнопка
                    FilledButton.icon(
                      onPressed: _isSaving ? null : _submit,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.compare_arrows_rounded),
                      label: Text(
                        _isSaving ? 'Переводим...' : 'Сделать перевод',
                      ),
                    ),
                  ],
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

    if (_fromAccountId == _toAccountId) {
      setState(() {
        _error = 'Счета должны быть разными.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await widget.controller.createTransfer(
        TransferDraft(
          fromAccountId: _fromAccountId!,
          toAccountId: _toAccountId!,
          amount: double.parse(_amountController.text.replaceAll(',', '.')),
          occurredAt: DateTime.now(),
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        ),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Перевод выполнен.')));
    } on Object catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = widget.controller.describeError(error);
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

class _QuickAccountSelector extends StatelessWidget {
  const _QuickAccountSelector({
    required this.account,
    required this.enabled,
    required this.onTap,
  });

  final MoneyAccount account;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Icon(
                _accountIcon(account.kind),
                color: const Color(0xFF111318),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF111318),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatMoney(
                      account.balance,
                      currencyCode: account.currencyCode,
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              onTap == null
                  ? Icons.check_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccountPickerSheet extends StatelessWidget {
  const _QuickAccountPickerSheet({
    required this.accounts,
    required this.selectedAccountId,
  });

  final List<MoneyAccount> accounts;
  final String? selectedAccountId;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Text('Счет', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              'Выбери счет для быстрого добавления.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            ...accounts.map(
              (account) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(account.id),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: account.id == selectedAccountId
                          ? const Color(0xFF111318)
                          : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: account.id == selectedAccountId
                            ? const Color(0xFF111318)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: account.id == selectedAccountId
                                ? const Color(0xFF181C24)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            _accountIcon(account.kind),
                            color: account.id == selectedAccountId
                                ? Colors.white
                                : const Color(0xFF111318),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                account.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: account.id == selectedAccountId
                                          ? Colors.white
                                          : const Color(0xFF111318),
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatMoney(
                                  account.balance,
                                  currencyCode: account.currencyCode,
                                ),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: account.id == selectedAccountId
                                          ? const Color(0xFFB7BDC9)
                                          : const Color(0xFF6B7280),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          account.id == selectedAccountId
                              ? Icons.check_rounded
                              : Icons.arrow_forward_ios_rounded,
                          size: 18,
                          color: account.id == selectedAccountId
                              ? Colors.white
                              : const Color(0xFF6B7280),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
