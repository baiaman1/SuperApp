part of '../home_page.dart';

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
    required this.selectedPeriod,
    required this.customRange,
    required this.onSelect,
  });

  final _FilterPeriod selectedPeriod;
  final DateTimeRange? customRange;
  final Future<void> Function(_FilterPeriod period) onSelect;

  @override
  Widget build(BuildContext context) {
    final customLabel = customRange == null
        ? 'Период'
        : '${formatCompactDate(customRange!.start)} - ${formatCompactDate(customRange!.end)}';

    return _SectionSurface(
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
    await _openCategoryEditorSheet(context, widget.controller, kind: _kind);
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
              PopupMenuItem<String>(value: 'delete', child: Text('Удалить')),
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
    _selectedColorHex = _normalizeCategoryColorHex(
      widget.category?.color,
      _kind,
    );
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
                                  _selectedIconKey = _defaultCategoryIconKey(
                                    nextKind,
                                  );
                                }
                                if (_selectedColorHex ==
                                    _defaultCategoryColorHex(previousKind)) {
                                  _selectedColorHex = _defaultCategoryColorHex(
                                    nextKind,
                                  );
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
