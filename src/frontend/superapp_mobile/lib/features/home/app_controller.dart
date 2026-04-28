import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superapp_mobile/core/config/app_environment.dart';
import 'package:superapp_mobile/core/models/app_models.dart';
import 'package:superapp_mobile/core/network/api_client.dart';
import 'package:superapp_mobile/core/network/api_exception.dart';
import 'package:superapp_mobile/core/storage/session_store.dart';

class HomeSnapshot {
  const HomeSnapshot({
    required this.summary,
    required this.accounts,
    required this.categories,
    required this.transactions,
  });

  final DashboardSummary summary;
  final List<MoneyAccount> accounts;
  final List<CategoryModel> categories;
  final TransactionPage transactions;
}

class CreateTransactionDraft {
  const CreateTransactionDraft({
    required this.accountId,
    required this.categoryId,
    required this.entryType,
    required this.amount,
    required this.occurredAt,
    this.note,
  });

  final String accountId;
  final String categoryId;
  final TransactionEntryType entryType;
  final double amount;
  final DateTime occurredAt;
  final String? note;
}

class UpdateTransactionDraft {
  const UpdateTransactionDraft({
    required this.transactionId,
    required this.accountId,
    required this.categoryId,
    required this.entryType,
    required this.amount,
    required this.occurredAt,
    this.note,
  });

  final String transactionId;
  final String accountId;
  final String categoryId;
  final TransactionEntryType entryType;
  final double amount;
  final DateTime occurredAt;
  final String? note;
}

class CreateAccountDraft {
  const CreateAccountDraft({
    required this.name,
    required this.currencyCode,
    required this.kind,
    required this.openingBalance,
    this.displayOrder,
  });

  final String name;
  final String currencyCode;
  final AccountKind kind;
  final double openingBalance;
  final int? displayOrder;
}

class UpdateAccountDraft {
  const UpdateAccountDraft({
    required this.accountId,
    required this.name,
    required this.currencyCode,
    required this.kind,
    required this.isArchived,
    this.displayOrder,
  });

  final String accountId;
  final String name;
  final String currencyCode;
  final AccountKind kind;
  final bool isArchived;
  final int? displayOrder;
}

class TransferDraft {
  const TransferDraft({
    required this.fromAccountId,
    required this.toAccountId,
    required this.amount,
    required this.occurredAt,
    this.note,
  });

  final String fromAccountId;
  final String toAccountId;
  final double amount;
  final DateTime occurredAt;
  final String? note;
}

class CreateCategoryDraft {
  const CreateCategoryDraft({
    required this.name,
    required this.kind,
    this.icon,
    this.color,
    this.displayOrder,
  });

  final String name;
  final CategoryKind kind;
  final String? icon;
  final String? color;
  final int? displayOrder;
}

class UpdateCategoryDraft {
  const UpdateCategoryDraft({
    required this.categoryId,
    required this.name,
    this.icon,
    this.color,
    required this.isArchived,
    this.displayOrder,
  });

  final String categoryId;
  final String name;
  final String? icon;
  final String? color;
  final bool isArchived;
  final int? displayOrder;
}

class AppController extends ChangeNotifier {
  AppController._({
    required ApiClient apiClient,
    required SessionStore sessionStore,
  }) : _apiClient = apiClient,
       _sessionStore = sessionStore;

  final ApiClient _apiClient;
  final SessionStore _sessionStore;

  AuthSession? _session;
  HomeSnapshot? _homeData;
  bool _isReady = false;
  bool _isAuthenticating = false;
  bool _isLoadingHome = false;
  String? _authError;
  String? _homeError;
  String? _selectedAccountId;
  TransactionEntryType? _selectedFilter;
  Future<void>? _refreshingSession;

  static Future<AppController> bootstrap() async {
    final preferences = await SharedPreferences.getInstance();
    final controller = AppController._(
      apiClient: ApiClient(),
      sessionStore: SessionStore(preferences),
    );
    await controller._restore();
    return controller;
  }

  bool get isReady => _isReady;
  bool get isAuthenticated => _session != null;
  bool get isAuthenticating => _isAuthenticating;
  bool get isLoadingHome => _isLoadingHome;
  String? get authError => _authError;
  String? get homeError => _homeError;
  String get apiBaseUrl => _apiClient.baseUrl;
  String? get selectedAccountId => _selectedAccountId;
  TransactionEntryType? get selectedFilter => _selectedFilter;
  HomeSnapshot? get homeData => _homeData;
  UserProfile? get currentUser => _session?.user;
  String get currencyCode => _session?.user.preferredCurrency ?? 'KGS';

  Future<void> _restore() async {
    try {
      _session = await _sessionStore.read();
      if (_session != null) {
        final profile = await _withAccessToken(
          (token) => _apiClient.getMe(token),
        );
        _session = _session!.copyWith(user: profile);
        await _sessionStore.write(_session!);
        await refreshHome();
      }
    } catch (_) {
      await _clearSession();
    } finally {
      _isReady = true;
      notifyListeners();
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    _authError = null;
    _isAuthenticating = true;
    notifyListeners();

    try {
      final session = await _apiClient.signInWithPassword(
        email: email,
        password: password,
        deviceName: AppEnvironment.deviceName,
      );
      _session = session;
      _selectedAccountId = null;
      _selectedFilter = null;
      await _sessionStore.write(session);
      await refreshHome();
    } on Object catch (error) {
      _authError = describeError(error);
    } finally {
      _isAuthenticating = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _clearSession();
    notifyListeners();
  }

  Future<void> refreshHome() async {
    if (_session == null) {
      _homeData = null;
      _homeError = null;
      return;
    }

    _isLoadingHome = true;
    _homeError = null;
    notifyListeners();

    try {
      final snapshot = await _withAccessToken((token) async {
        final accountsFuture = _apiClient.getAccounts(token);
        final categoriesFuture = _apiClient.getCategories(token);
        final summaryFuture = _apiClient.getDashboardSummary(
          token,
          accountId: _selectedAccountId,
        );
        final transactionsFuture = _apiClient.getTransactions(
          token,
          accountId: _selectedAccountId,
          entryType: _selectedFilter,
        );

        final results = await Future.wait<Object>([
          accountsFuture,
          categoriesFuture,
          summaryFuture,
          transactionsFuture,
        ]);

        return HomeSnapshot(
          accounts: (results[0] as List<MoneyAccount>)
              .where((account) => !account.isArchived)
              .toList(growable: false),
          categories: (results[1] as List<CategoryModel>)
              .where((category) => !category.isArchived)
              .toList(growable: false),
          summary: results[2] as DashboardSummary,
          transactions: results[3] as TransactionPage,
        );
      });

      _homeData = snapshot;
      if (_selectedAccountId != null &&
          snapshot.accounts.every(
            (account) => account.id != _selectedAccountId,
          )) {
        _selectedAccountId = null;
      }
    } on Object catch (error) {
      _homeError = describeError(error);
    } finally {
      _isLoadingHome = false;
      notifyListeners();
    }
  }

  void selectAccount(String? accountId) {
    if (_selectedAccountId == accountId) {
      return;
    }

    _selectedAccountId = accountId;
    notifyListeners();
    unawaited(refreshHome());
  }

  void selectTransactionFilter(TransactionEntryType? entryType) {
    if (_selectedFilter == entryType) {
      return;
    }

    _selectedFilter = entryType;
    notifyListeners();
    unawaited(refreshHome());
  }

  List<CategoryModel> categoriesFor(TransactionEntryType entryType) {
    final kind = entryType.categoryKind;
    final items =
        _homeData?.categories
            .where(
              (category) => category.kind == kind && !category.isArchived,
            )
            .toList(growable: true) ??
        <CategoryModel>[];

    final usage = <String, int>{};
    for (final transaction
        in _homeData?.transactions.items ?? const <TransactionItem>[]) {
      final matchesKind =
          (kind == CategoryKind.income &&
              transaction.entryType == TransactionEntryType.income) ||
          (kind == CategoryKind.expense &&
              transaction.entryType == TransactionEntryType.expense);
      if (!matchesKind) {
        continue;
      }

      final categoryId = transaction.categoryId?.trim();
      if (categoryId == null || categoryId.isEmpty) {
        continue;
      }

      usage.update(categoryId, (value) => value + 1, ifAbsent: () => 1);
    }

    items.sort((left, right) {
      final usageCompare =
          (usage[right.id] ?? 0).compareTo(usage[left.id] ?? 0);
      if (usageCompare != 0) {
        return usageCompare;
      }

      final orderCompare = left.displayOrder.compareTo(right.displayOrder);
      if (orderCompare != 0) {
        return orderCompare;
      }

      return left.name.toLowerCase().compareTo(right.name.toLowerCase());
    });

    return List<CategoryModel>.unmodifiable(items);
  }

  Future<void> createTransaction(CreateTransactionDraft draft) async {
    await _withAccessToken((token) {
      return _apiClient.createTransaction(
        token,
        accountId: draft.accountId,
        categoryId: draft.categoryId,
        entryType: draft.entryType,
        amount: draft.amount,
        occurredAt: draft.occurredAt,
        note: draft.note,
      );
    });

    await refreshHome();
  }

  Future<void> updateTransaction(UpdateTransactionDraft draft) async {
    await _withAccessToken((token) {
      return _apiClient.updateTransaction(
        token,
        transactionId: draft.transactionId,
        accountId: draft.accountId,
        categoryId: draft.categoryId,
        entryType: draft.entryType,
        amount: draft.amount,
        occurredAt: draft.occurredAt,
        note: draft.note,
      );
    });

    await refreshHome();
  }

  Future<TransactionPage> loadTransactions({
    String? accountId,
    String? categoryId,
    TransactionEntryType? entryType,
    DateTime? dateFrom,
    DateTime? dateTo,
    int pageNumber = 1,
    int pageSize = 100,
  }) {
    return _withAccessToken(
      (token) => _apiClient.getTransactions(
        token,
        accountId: accountId,
        categoryId: categoryId,
        entryType: entryType,
        dateFrom: dateFrom,
        dateTo: dateTo,
        pageNumber: pageNumber,
        pageSize: pageSize,
      ),
    );
  }

  Future<void> createAccount(CreateAccountDraft draft) async {
    await _withAccessToken(
      (token) => _apiClient.createAccount(
        token,
        name: draft.name,
        currencyCode: draft.currencyCode,
        kind: draft.kind,
        openingBalance: draft.openingBalance,
        displayOrder: draft.displayOrder,
      ),
    );

    await refreshHome();
  }

  Future<void> updateAccount(UpdateAccountDraft draft) async {
    await _withAccessToken(
      (token) => _apiClient.updateAccount(
        token,
        accountId: draft.accountId,
        name: draft.name,
        currencyCode: draft.currencyCode,
        kind: draft.kind,
        isArchived: draft.isArchived,
        displayOrder: draft.displayOrder,
      ),
    );

    await refreshHome();
  }

  Future<void> archiveAccount(MoneyAccount account) {
    return updateAccount(
      UpdateAccountDraft(
        accountId: account.id,
        name: account.name,
        currencyCode: account.currencyCode,
        kind: account.kind,
        isArchived: true,
        displayOrder: account.displayOrder,
      ),
    );
  }

  Future<void> createTransfer(TransferDraft draft) async {
    await _withAccessToken(
      (token) => _apiClient.createTransfer(
        token,
        fromAccountId: draft.fromAccountId,
        toAccountId: draft.toAccountId,
        amount: draft.amount,
        occurredAt: draft.occurredAt,
        note: draft.note,
      ),
    );

    await refreshHome();
  }

  Future<void> createCategory(CreateCategoryDraft draft) async {
    await _withAccessToken(
      (token) => _apiClient.createCategory(
        token,
        name: draft.name,
        kind: draft.kind,
        icon: draft.icon,
        color: draft.color,
        displayOrder: draft.displayOrder,
      ),
    );

    await refreshHome();
  }

  Future<void> updateCategory(UpdateCategoryDraft draft) async {
    await _withAccessToken(
      (token) => _apiClient.updateCategory(
        token,
        categoryId: draft.categoryId,
        name: draft.name,
        icon: draft.icon,
        color: draft.color,
        isArchived: draft.isArchived,
        displayOrder: draft.displayOrder,
      ),
    );

    await refreshHome();
  }

  Future<void> deleteCategory(String categoryId) async {
    await _withAccessToken(
      (token) => _apiClient.deleteCategory(token, categoryId: categoryId),
    );

    await refreshHome();
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _withAccessToken(
      (token) =>
          _apiClient.deleteTransaction(token, transactionId: transactionId),
    );

    await refreshHome();
  }

  String describeError(Object error) {
    if (error is ApiException) {
      if (error.statusCode == 0) {
        return error.message;
      }

      if (error.statusCode == 401) {
        return 'Сессия устарела. Войди заново.';
      }

      return error.message;
    }

    return 'Произошла непредвиденная ошибка.';
  }

  Future<T> _withAccessToken<T>(Future<T> Function(String token) action) async {
    final session = _session;
    if (session == null) {
      throw const ApiException(
        statusCode: 401,
        message: 'Нужна активная сессия.',
      );
    }

    await _ensureFreshToken();

    try {
      return await action(_session!.accessToken);
    } on ApiException catch (error) {
      if (error.statusCode != 401) {
        rethrow;
      }

      await _refreshToken();
      return action(_session!.accessToken);
    }
  }

  Future<void> _ensureFreshToken() async {
    final session = _session;
    if (session == null) {
      return;
    }

    final threshold = DateTime.now().toUtc().add(const Duration(seconds: 45));
    if (session.accessTokenExpiresAtUtc.isAfter(threshold)) {
      return;
    }

    await _refreshToken();
  }

  Future<void> _refreshToken() {
    final existing = _refreshingSession;
    if (existing != null) {
      return existing;
    }

    final future = _refreshTokenCore();
    _refreshingSession = future;
    return future.whenComplete(() => _refreshingSession = null);
  }

  Future<void> _refreshTokenCore() async {
    final session = _session;
    if (session == null) {
      return;
    }

    try {
      final refreshed = await _apiClient.refreshSession(
        refreshToken: session.refreshToken,
        deviceName: AppEnvironment.deviceName,
      );
      _session = refreshed;
      await _sessionStore.write(refreshed);
    } on Object {
      await _clearSession();
      rethrow;
    }
  }

  Future<void> _clearSession() async {
    _session = null;
    _homeData = null;
    _selectedAccountId = null;
    _selectedFilter = null;
    _authError = null;
    _homeError = null;
    await _sessionStore.clear();
  }

  @override
  void dispose() {
    _apiClient.close();
    super.dispose();
  }
}
