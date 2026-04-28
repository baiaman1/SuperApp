part of '../home_page.dart';

class _AddFlowTab extends StatelessWidget {
  const _AddFlowTab({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final data = controller.homeData;

    return RefreshIndicator(
      onRefresh: controller.refreshHome,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          QuickComposerCard(controller: controller),
          const SizedBox(height: 16),
          _SectionSurface(
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () =>
                        _showCreateTransactionSheet(context, controller),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Подробно'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.refreshHome,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Обновить'),
                  ),
                ),
              ],
            ),
          ),
          if (data != null) ...[
            const SizedBox(height: 16),
            _OverviewCard(
              summary: data.summary,
              currencyCode: controller.currencyCode,
            ),
            const SizedBox(height: 16),
            _TransactionsCard(
              controller: controller,
              page: data.transactions,
              currencyCode: controller.currencyCode,
            ),
          ],
        ],
      ),
    );
  }
}

class _AccountsManagerTab extends StatelessWidget {
  const _AccountsManagerTab({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final accounts = controller.homeData?.accounts ?? const <MoneyAccount>[];

    return RefreshIndicator(
      onRefresh: controller.refreshHome,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          _SectionSurface(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () =>
                            _openAccountEditorSheet(context, controller),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Новый счет'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: accounts.length < 2
                            ? null
                            : () => _openTransferSheet(context, controller),
                        icon: const Icon(Icons.compare_arrows_rounded),
                        label: const Text('Перевод'),
                      ),
                    ),
                  ],
                ),
                if (accounts.length < 2) ...[
                  const SizedBox(height: 12),
                  const _InfoBanner(
                    message: 'Для перевода нужны минимум два активных счета.',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (accounts.isEmpty)
            const _SectionSurface(
              title: 'Пока пусто',
              subtitle: 'Создай первый счет, чтобы начать работу с деньгами.',
              child: SizedBox.shrink(),
            )
          else
            ...accounts.map(
              (account) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ManagedAccountTile(
                  account: account,
                  onEdit: () => _openAccountEditorSheet(
                    context,
                    controller,
                    account: account,
                  ),
                  onArchive: () =>
                      _archiveAccount(context, controller, account),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryTab extends StatefulWidget {
  const _HistoryTab({required this.controller});

  final AppController controller;

  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab> {
  _FilterPeriod _period = _FilterPeriod.day;
  DateTimeRange? _customRange;
  _HistoryEntryFilter _entryFilter = _HistoryEntryFilter.all;
  String? _selectedAccountId;
  TransactionPage? _page;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didUpdateWidget(covariant _HistoryTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts =
        widget.controller.homeData?.accounts ?? const <MoneyAccount>[];
    if (_selectedAccountId != null &&
        accounts.every((account) => account.id != _selectedAccountId)) {
      _selectedAccountId = null;
    }

    final bounds = _resolvePeriodBounds(_period, _customRange);
    final items = _page?.items ?? const <TransactionItem>[];
    final totals = _sumTransactions(items);

    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          _PeriodSelectorCard(
            // title: 'История операций',
            // subtitle: 'День, месяц, год или свой период.',
            selectedPeriod: _period,
            customRange: _customRange,
            onSelect: _onSelectPeriod,
          ),
          const SizedBox(height: 16),
          _SectionSurface(
            // title: 'Тип операций',
            // subtitle: 'Покажи все записи или только один поток.',
            child: SegmentedButton<_HistoryEntryFilter>(
              segments: const [
                ButtonSegment<_HistoryEntryFilter>(
                  value: _HistoryEntryFilter.all,
                  label: Text('Все'),
                  icon: Icon(Icons.view_list_rounded),
                ),
                ButtonSegment<_HistoryEntryFilter>(
                  value: _HistoryEntryFilter.income,
                  label: Text('Доходы'),
                  icon: Icon(Icons.south_west_rounded),
                ),
                ButtonSegment<_HistoryEntryFilter>(
                  value: _HistoryEntryFilter.expense,
                  label: Text('Расходы'),
                  icon: Icon(Icons.north_east_rounded),
                ),
              ],
              selected: {_entryFilter},
              onSelectionChanged: (selection) async {
                final next = selection.first;
                if (_entryFilter == next) {
                  return;
                }

                setState(() {
                  _entryFilter = next;
                });
                await _reload();
              },
            ),
          ),
          if (accounts.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionSurface(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _PeriodChip(
                      label: 'Все счета',
                      selected: _selectedAccountId == null,
                      onTap: () async {
                        if (_selectedAccountId == null) {
                          return;
                        }

                        setState(() {
                          _selectedAccountId = null;
                        });
                        await _reload();
                      },
                    ),
                    ...accounts.map(
                      (account) => Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: _PeriodChip(
                          label: account.name,
                          selected: account.id == _selectedAccountId,
                          onTap: () async {
                            if (_selectedAccountId == account.id) {
                              return;
                            }

                            setState(() {
                              _selectedAccountId = account.id;
                            });
                            await _reload();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (_error != null) ...[
            _InfoBanner(message: _error!),
            const SizedBox(height: 16),
          ],
          _SectionSurface(
            title: 'Сводка',
            subtitle: bounds.label,
            child: Row(
              children: [
                Expanded(
                  child: _SoftValueCard(
                    label: 'Доход',
                    value: formatMoney(
                      totals.income,
                      currencyCode: widget.controller.currencyCode,
                    ),
                    tone: const Color(0xFF047857),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SoftValueCard(
                    label: 'Расход',
                    value: formatMoney(
                      totals.expense,
                      currencyCode: widget.controller.currencyCode,
                    ),
                    tone: const Color(0xFFB45309),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SoftValueCard(
                    label: 'Записей',
                    value: '${items.length}',
                    tone: const Color(0xFF111318),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (items.isEmpty)
            const _SectionSurface(
              title: 'Нет операций',
              subtitle: 'За выбранный период пока ничего не найдено.',
              child: SizedBox.shrink(),
            )
          else
            _SectionSurface(
              title: 'Список операций',
              subtitle: '${_page?.totalCount ?? items.length} записей',
              child: Column(
                children: items
                    .map(
                      (transaction) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _TransactionTile(
                          transaction: transaction,
                          currencyCode: widget.controller.currencyCode,
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'edit') {
                                await _editTransaction(transaction);
                                return;
                              }
                              if (value == 'delete') {
                                await _deleteTransaction(transaction);
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
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _onSelectPeriod(_FilterPeriod period) async {
    if (period == _FilterPeriod.custom) {
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
        lastDate: DateTime.now().add(const Duration(days: 30)),
        locale: const Locale('ru', 'RU'),
        initialDateRange: _customRange,
      );

      if (!mounted || picked == null) {
        return;
      }

      setState(() {
        _period = _FilterPeriod.custom;
        _customRange = picked;
      });
      await _reload();
      return;
    }

    setState(() {
      _period = period;
    });
    await _reload();
  }

  Future<void> _reload() async {
    final bounds = _resolvePeriodBounds(_period, _customRange);

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final page = await widget.controller.loadTransactions(
        accountId: _selectedAccountId,
        entryType: _selectedEntryType,
        dateFrom: bounds.start,
        dateTo: bounds.end,
        pageSize: 200,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _page = page;
      });
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
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteTransaction(TransactionItem transaction) async {
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

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await widget.controller.deleteTransaction(transaction.id);
      await _reload();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Операция удалена.')));
    } on Object catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.controller.describeError(error))),
      );
    }
  }

  Future<void> _editTransaction(TransactionItem transaction) async {
    await _showCreateTransactionSheet(
      context,
      widget.controller,
      initialEntryType: transaction.entryType,
      transaction: transaction,
    );

    if (!mounted) {
      return;
    }

    await _reload();
  }

  TransactionEntryType? get _selectedEntryType => switch (_entryFilter) {
    _HistoryEntryFilter.all => null,
    _HistoryEntryFilter.income => TransactionEntryType.income,
    _HistoryEntryFilter.expense => TransactionEntryType.expense,
  };
}

class _ReportsTab extends StatefulWidget {
  const _ReportsTab({required this.controller});

  final AppController controller;

  @override
  State<_ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<_ReportsTab> {
  _FilterPeriod _period = _FilterPeriod.month;
  DateTimeRange? _customRange;
  TransactionPage? _page;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didUpdateWidget(covariant _ReportsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _page?.items ?? const <TransactionItem>[];
    final totals = _sumTransactions(items);
    final categoryItems = _buildCategoryCatalog(
      items,
      widget.controller.homeData?.categories ?? const <CategoryModel>[],
    );

    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          _PeriodSelectorCard(
            // title: 'Отчеты и категории',
            // subtitle: 'Смотри картину по доходам, расходам и категориям.',
            selectedPeriod: _period,
            customRange: _customRange,
            onSelect: _onSelectPeriod,
          ),
          const SizedBox(height: 16),
          if (_error != null) ...[
            _InfoBanner(message: _error!),
            const SizedBox(height: 16),
          ],
          _SectionSurface(
            title: 'Итоги периода',
            subtitle: _resolvePeriodBounds(_period, _customRange).label,
            child: Row(
              children: [
                Expanded(
                  child: _SoftValueCard(
                    label: 'Доход',
                    value: formatMoney(
                      totals.income,
                      currencyCode: widget.controller.currencyCode,
                    ),
                    tone: const Color(0xFF047857),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SoftValueCard(
                    label: 'Расход',
                    value: formatMoney(
                      totals.expense,
                      currencyCode: widget.controller.currencyCode,
                    ),
                    tone: const Color(0xFFB45309),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SoftValueCard(
                    label: 'Поток',
                    value: formatMoney(
                      totals.income - totals.expense,
                      currencyCode: widget.controller.currencyCode,
                      signed: true,
                    ),
                    tone: totals.income - totals.expense >= 0
                        ? const Color(0xFF047857)
                        : const Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (items.isEmpty)
            const _SectionSurface(
              title: 'Пока нет данных',
              subtitle:
                  'Добавь операции за выбранный период, и здесь появятся отчеты.',
              child: SizedBox.shrink(),
            )
          else ...[
            _ActivityCard(
              transactions: items,
              currencyCode: widget.controller.currencyCode,
            ),
            const SizedBox(height: 16),
            _CategoryBreakdownCard(
              transactions: items,
              currencyCode: widget.controller.currencyCode,
            ),
            const SizedBox(height: 16),
            _CategoryCatalogCard(
              items: categoryItems,
              currencyCode: widget.controller.currencyCode,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _onSelectPeriod(_FilterPeriod period) async {
    if (period == _FilterPeriod.custom) {
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
        lastDate: DateTime.now().add(const Duration(days: 30)),
        locale: const Locale('ru', 'RU'),
        initialDateRange: _customRange,
      );

      if (!mounted || picked == null) {
        return;
      }

      setState(() {
        _period = _FilterPeriod.custom;
        _customRange = picked;
      });
      await _reload();
      return;
    }

    setState(() {
      _period = period;
    });
    await _reload();
  }

  Future<void> _reload() async {
    final bounds = _resolvePeriodBounds(_period, _customRange);

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final page = await widget.controller.loadTransactions(
        dateFrom: bounds.start,
        dateTo: bounds.end,
        pageSize: 250,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _page = page;
      });
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
          _isLoading = false;
        });
      }
    }
  }
}
