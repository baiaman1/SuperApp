import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:superapp_mobile/core/models/app_models.dart';
import 'package:superapp_mobile/core/network/api_exception.dart';
import 'package:superapp_mobile/core/utils/formatters.dart';
import 'package:superapp_mobile/features/home/app_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.controller});

  final AppController controller;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final data = widget.controller.homeData;
    final pages = [
      _HomeSection(
        controller: widget.controller,
        child: _AddFlowTab(controller: widget.controller),
      ),
      _HomeSection(
        controller: widget.controller,
        child: _AccountsManagerTab(controller: widget.controller),
      ),
      _HomeSection(
        controller: widget.controller,
        child: _ReportsTab(controller: widget.controller),
      ),
      _HomeSection(
        controller: widget.controller,
        child: _HistoryTab(controller: widget.controller),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: data == null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Header(controller: widget.controller),
                        const SizedBox(height: 16),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: widget.controller.refreshHome,
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 120),
                              children: [
                                if (widget.controller.homeError != null) ...[
                                  _InfoBanner(
                                    message: widget.controller.homeError!,
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                _EmptyState(controller: widget.controller),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : IndexedStack(index: _pageIndex, children: pages),
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pageIndex,
        onDestinationSelected: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Счета',
          ),
          NavigationDestination(
            icon: Icon(Icons.query_stats_outlined),
            selectedIcon: Icon(Icons.query_stats_rounded),
            label: 'Аналитика',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'История',
          ),
        ],
      ),
    );
  }
}

enum _FilterPeriod { day, month, year, custom }
enum _HistoryEntryFilter { all, income, expense }

class _HomeSection extends StatelessWidget {
  const _HomeSection({required this.controller, required this.child});

  final AppController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(controller: controller),
        const SizedBox(height: 16),
        if (controller.homeError != null) ...[
          _InfoBanner(message: controller.homeError!),
          const SizedBox(height: 16),
        ],
        Expanded(child: child),
      ],
    );
  }
}

class _MainWorkspace extends StatelessWidget {
  const _MainWorkspace({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(controller: controller),
          const SizedBox(height: 16),
          if (controller.homeError != null) ...[
            _InfoBanner(message: controller.homeError!),
            const SizedBox(height: 16),
          ],
          const _WorkspaceTabBar(tabs: ['Добавить', 'Счета']),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: [
                _AddFlowTab(controller: controller),
                _AccountsManagerTab(controller: controller),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsWorkspace extends StatelessWidget {
  const _AnalyticsWorkspace({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(controller: controller),
          const SizedBox(height: 16),
          if (controller.homeError != null) ...[
            _InfoBanner(message: controller.homeError!),
            const SizedBox(height: 16),
          ],
          const _WorkspaceTabBar(tabs: ['История', 'Отчеты']),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: [
                _HistoryTab(controller: controller),
                _ReportsTab(controller: controller),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceTabBar extends StatelessWidget {
  const _WorkspaceTabBar({required this.tabs});

  final List<String> tabs;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: TabBar(
          tabs: tabs.map((tab) => Tab(text: tab)).toList(growable: false),
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF111318),
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: const Color(0xFF111318),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

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
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(color: const Color(0xFF111318)),
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
              children: categories
                  .take(8)
                  .map(
                    (category) => _CategoryShortcut(
                      category: category,
                      enabled: !_isSubmitting,
                      onTap: () => _submit(category),
                    ),
                  )
                  .toList(growable: false),
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

class _ManagedAccountTile extends StatelessWidget {
  const _ManagedAccountTile({
    required this.account,
    required this.onEdit,
    required this.onArchive,
  });

  final MoneyAccount account;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _surfaceDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Icon(
              _accountIcon(account.kind),
              color: const Color(0xFF111318),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  account.kind.label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  formatMoney(
                    account.balance,
                    currencyCode: account.currencyCode,
                  ),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              }
              if (value == 'archive') {
                onArchive();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'edit',
                child: Text('Редактировать'),
              ),
              PopupMenuItem<String>(value: 'archive', child: Text('Скрыть')),
            ],
          ),
        ],
      ),
    );
  }
}

class _PeriodSelectorCard extends StatelessWidget {
  const _PeriodSelectorCard({
    this.title,
    this.subtitle,
    required this.selectedPeriod,
    required this.customRange,
    required this.onSelect,
  });

  final String? title;
  final String? subtitle;
  final _FilterPeriod selectedPeriod;
  final DateTimeRange? customRange;
  final Future<void> Function(_FilterPeriod period) onSelect;

  @override
  Widget build(BuildContext context) {
    final customLabel = customRange == null
        ? 'Период'
        : '${formatCompactDate(customRange!.start)} - ${formatCompactDate(customRange!.end)}';

    return _SectionSurface(
      title: title,
      subtitle: subtitle,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _PeriodChip(
            label: 'День',
            selected: selectedPeriod == _FilterPeriod.day,
            onTap: () => onSelect(_FilterPeriod.day),
          ),
          _PeriodChip(
            label: 'Месяц',
            selected: selectedPeriod == _FilterPeriod.month,
            onTap: () => onSelect(_FilterPeriod.month),
          ),
          _PeriodChip(
            label: 'Год',
            selected: selectedPeriod == _FilterPeriod.year,
            onTap: () => onSelect(_FilterPeriod.year),
          ),
          _PeriodChip(
            label: customLabel,
            selected: selectedPeriod == _FilterPeriod.custom,
            onTap: () => onSelect(_FilterPeriod.custom),
          ),
        ],
      ),
    );
  }
}
class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF111318) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? const Color(0xFF111318) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: selected ? Colors.white : const Color(0xFF111318),
          ),
        ),
      ),
    );
  }
}

class _CategoryCatalogCard extends StatelessWidget {
  const _CategoryCatalogCard({required this.items, required this.currencyCode});

  final List<_CategoryCatalogItem> items;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return _SectionSurface(
      title: 'Все категории',
      subtitle: 'Отсортировано по сумме операций за период.',
      child: items.isEmpty
          ? const Text('За этот период категории пока пустые.')
          : Column(
              children: items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet<void>(
                            context: context,
                            useSafeArea: true,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => _CategoryHistorySheet(
                              item: item,
                              currencyCode: currencyCode,
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: item.color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(item.icon, color: item.color),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item.count} операций',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    formatMoney(
                                      item.amount,
                                      currencyCode: currencyCode,
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(color: item.color),
                                  ),
                                  const SizedBox(height: 4),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }
}

class _CategoryHistorySheet extends StatelessWidget {
  const _CategoryHistorySheet({required this.item, required this.currencyCode});

  final _CategoryCatalogItem item;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
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
            Text(item.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              '${item.count} операций на ${formatMoney(item.amount, currencyCode: currencyCode)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            ...item.transactions.map(
              (transaction) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TransactionTile(
                  transaction: transaction,
                  currencyCode: currencyCode,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryManagerSheet extends StatefulWidget {
  const _CategoryManagerSheet({
    required this.controller,
    required this.initialKind,
  });

  final AppController controller;
  final CategoryKind initialKind;

  @override
  State<_CategoryManagerSheet> createState() => _CategoryManagerSheetState();
}

class _CategoryManagerSheetState extends State<_CategoryManagerSheet> {
  late CategoryKind _kind;
  bool _isWorking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _kind = widget.initialKind;
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
        child: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            final categories = _visibleCategories(
              widget.controller.homeData?.categories ?? const <CategoryModel>[],
              _kind,
            );

            return ListView(
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
                  'Категории',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Создавай свои категории и держи быстрый ввод аккуратным.',
                ),
                const SizedBox(height: 18),
                SegmentedButton<CategoryKind>(
                  segments: const [
                    ButtonSegment<CategoryKind>(
                      value: CategoryKind.expense,
                      label: Text('Расход'),
                      icon: Icon(Icons.remove_circle_outline_rounded),
                    ),
                    ButtonSegment<CategoryKind>(
                      value: CategoryKind.income,
                      label: Text('Доход'),
                      icon: Icon(Icons.add_circle_outline_rounded),
                    ),
                  ],
                  selected: {_kind},
                  onSelectionChanged: _isWorking
                      ? null
                      : (selection) {
                          setState(() {
                            _kind = selection.first;
                            _error = null;
                          });
                        },
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _isWorking ? null : _createCategory,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(
                    _kind == CategoryKind.income
                        ? 'Новая категория дохода'
                        : 'Новая категория расхода',
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  _InfoBanner(message: _error!),
                ],
                const SizedBox(height: 18),
                if (categories.isEmpty)
                  const _InfoBanner(
                    message:
                        'Пока нет категорий этого типа. Создай первую сверху.',
                  )
                else
                  ...categories.map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ManagedCategoryTile(
                        category: category,
                        onEdit: _isWorking
                            ? null
                            : () => _editCategory(category),
                        onDelete: _isWorking
                            ? null
                            : () => _deleteCategory(category),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _createCategory() async {
    await _openCategoryEditorSheet(
      context,
      widget.controller,
      kind: _kind,
    );
  }

  Future<void> _editCategory(CategoryModel category) async {
    await _openCategoryEditorSheet(
      context,
      widget.controller,
      kind: category.kind,
      category: category,
    );
  }

  Future<void> _deleteCategory(CategoryModel category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить категорию?'),
        content: Text(
          'Категория "${category.name}" исчезнет из быстрого выбора, но старые операции останутся в истории.',
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

    setState(() {
      _isWorking = true;
      _error = null;
    });

    try {
      await widget.controller.deleteCategory(category.id);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Категория удалена.')));
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
          _isWorking = false;
        });
      }
    }
  }
}

class _ManagedCategoryTile extends StatelessWidget {
  const _ManagedCategoryTile({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  final CategoryModel category;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final accent = _categoryAccentColor(category);

    return Container(
      padding: const EdgeInsets.all(16),
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
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_categoryIcon(category), color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF111318),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category.isSystem
                      ? '${_categoryKindLabel(category.kind)} - системная'
                      : '${_categoryKindLabel(category.kind)} - пользовательская',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                onEdit?.call();
              }
              if (value == 'delete') {
                onDelete?.call();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'edit',
                child: Text('Редактировать'),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Text('Удалить'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryEditorSheet extends StatefulWidget {
  const _CategoryEditorSheet({
    required this.controller,
    required this.kind,
    this.category,
  });

  final AppController controller;
  final CategoryKind kind;
  final CategoryModel? category;

  @override
  State<_CategoryEditorSheet> createState() => _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends State<_CategoryEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late CategoryKind _kind;
  late String _selectedIconKey;
  late String _selectedColorHex;
  bool _isSaving = false;
  String? _error;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _kind = widget.category?.kind ?? widget.kind;
    _selectedIconKey = _normalizeCategoryIconKey(widget.category?.icon, _kind);
    _selectedColorHex = _normalizeCategoryColorHex(widget.category?.color, _kind);
  }

  @override
  void dispose() {
    _nameController.dispose();
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
              _isEditing ? 'Редактировать категорию' : 'Новая категория',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _isEditing
                  ? 'Можно поменять название без лишних шагов.'
                  : 'Добавь понятное название, чтобы категория сразу была удобной в быстром вводе.',
            ),
            const SizedBox(height: 18),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isEditing)
                    _InfoBanner(
                      message:
                          'Тип: ${_categoryKindLabel(widget.category!.kind)}. Пока его нельзя менять после создания.',
                    )
                  else
                    SegmentedButton<CategoryKind>(
                      segments: const [
                        ButtonSegment<CategoryKind>(
                          value: CategoryKind.expense,
                          label: Text('Расход'),
                          icon: Icon(Icons.remove_circle_outline_rounded),
                        ),
                        ButtonSegment<CategoryKind>(
                          value: CategoryKind.income,
                          label: Text('Доход'),
                          icon: Icon(Icons.add_circle_outline_rounded),
                        ),
                      ],
                      selected: {_kind},
                      onSelectionChanged: _isSaving
                          ? null
                          : (selection) {
                              final nextKind = selection.first;
                              setState(() {
                                final previousKind = _kind;
                                _kind = nextKind;
                                if (_selectedIconKey ==
                                    _defaultCategoryIconKey(previousKind)) {
                                  _selectedIconKey =
                                      _defaultCategoryIconKey(nextKind);
                                }
                                if (_selectedColorHex ==
                                    _defaultCategoryColorHex(previousKind)) {
                                  _selectedColorHex =
                                      _defaultCategoryColorHex(nextKind);
                                }
                              });
                            },
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Название'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Укажи название категории.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedIconKey,
                    decoration: const InputDecoration(labelText: 'Иконка'),
                    items: _categoryIconOptions
                        .map(
                          (option) => DropdownMenuItem<String>(
                            value: option.key,
                            child: Row(
                              children: [
                                Icon(option.icon, size: 20),
                                const SizedBox(width: 12),
                                Text(option.label),
                              ],
                            ),
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
                              _selectedIconKey = value;
                            });
                          },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedColorHex,
                    decoration: const InputDecoration(labelText: 'Цвет'),
                    items: _categoryColorOptions
                        .map(
                          (option) => DropdownMenuItem<String>(
                            value: option.hex,
                            child: Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: option.color,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(option.label),
                              ],
                            ),
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
                              _selectedColorHex = value;
                            });
                          },
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
        await widget.controller.updateCategory(
          UpdateCategoryDraft(
            categoryId: widget.category!.id,
            name: _nameController.text.trim(),
            icon: _selectedIconKey,
            color: _selectedColorHex,
            isArchived: false,
            displayOrder: widget.category!.displayOrder,
          ),
        );
      } else {
        await widget.controller.createCategory(
          CreateCategoryDraft(
            name: _nameController.text.trim(),
            kind: _kind,
            icon: _selectedIconKey,
            color: _selectedColorHex,
          ),
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Категория обновлена.' : 'Категория создана.',
          ),
        ),
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
              'Перевод между счетами',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            // const Text(
            //   'Деньги уйдут с одного счета и придут на другой одной операцией.',
            // ),
            const SizedBox(height: 18),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _fromAccountId,
                    decoration: const InputDecoration(labelText: 'Со счета'),
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
                        : (value) => setState(() => _fromAccountId = value),
                    validator: (value) => value == null ? 'Выбери счет.' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _toAccountId,
                    decoration: const InputDecoration(labelText: 'На счет'),
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
                        : (value) => setState(() => _toAccountId = value),
                    validator: (value) => value == null ? 'Выбери счет.' : null,
                  ),
                  const SizedBox(height: 16),
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
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _submit,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.compare_arrows_rounded),
                    label: Text(_isSaving ? 'Переводим...' : 'Сделать перевод'),
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
  const _TransactionsCard({required this.page, required this.currencyCode});

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
  const _SectionSurface({
    this.title,
    this.subtitle,
    required this.child,
  });

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
    label: 'Транспорт',
    icon: Icons.directions_car_filled_rounded,
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
  _CategoryIconOption(
    key: 'people',
    label: 'Люди',
    icon: Icons.people,
  ),
  _CategoryIconOption(
    key: 'bus',
    label: 'Проездные',
    icon: Icons.bus_alert_rounded,
  ),
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
  _CategoryColorOption(
    hex: '#2A9D8F',
    label: 'Мята',
    color: Color(0xFF2A9D8F),
  ),
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
    builder: (context) => _CategoryManagerSheet(
      controller: controller,
      initialKind: initialKind,
    ),
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
