import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:superapp_mobile/core/config/app_environment.dart';
import 'package:superapp_mobile/core/models/app_models.dart';
import 'package:superapp_mobile/core/network/api_exception.dart';

class ApiClient {
  ApiClient({http.Client? httpClient, String? baseUrl})
    : _httpClient = httpClient ?? http.Client(),
      _baseUrl = baseUrl ?? AppEnvironment.apiBaseUrl;

  final http.Client _httpClient;
  final String _baseUrl;

  String get baseUrl => _baseUrl;

  Future<AuthSession> signInWithPassword({
    required String email,
    required String password,
    required String deviceName,
  }) async {
    final json =
        await _send(
              'POST',
              '/api/auth/login',
              body: {
                'email': email,
                'password': password,
                'deviceName': deviceName,
              },
            )
            as Map<String, dynamic>;

    return AuthSession.fromAuthResponse(json);
  }

  Future<AuthSession> refreshSession({
    required String refreshToken,
    required String deviceName,
  }) async {
    final json =
        await _send(
              'POST',
              '/api/auth/refresh',
              body: {'refreshToken': refreshToken, 'deviceName': deviceName},
            )
            as Map<String, dynamic>;

    return AuthSession.fromAuthResponse(json);
  }

  Future<UserProfile> getMe(String accessToken) async {
    final json =
        await _send('GET', '/api/auth/me', accessToken: accessToken)
            as Map<String, dynamic>;

    return UserProfile.fromJson(json);
  }

  Future<List<MoneyAccount>> getAccounts(String accessToken) async {
    final json =
        await _send('GET', '/api/accounts', accessToken: accessToken)
            as List<dynamic>;

    return json
        .map((item) => MoneyAccount.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<MoneyAccount> createAccount(
    String accessToken, {
    required String name,
    required String currencyCode,
    required AccountKind kind,
    required double openingBalance,
    int? displayOrder,
  }) async {
    final json =
        await _send(
              'POST',
              '/api/accounts',
              accessToken: accessToken,
              body: {
                'name': name,
                'currencyCode': currencyCode,
                'kind': kind.index + 1,
                'openingBalance': openingBalance,
                'displayOrder': displayOrder,
              },
            )
            as Map<String, dynamic>;

    return MoneyAccount.fromJson(json);
  }

  Future<MoneyAccount> updateAccount(
    String accessToken, {
    required String accountId,
    required String name,
    required String currencyCode,
    required AccountKind kind,
    required bool isArchived,
    int? displayOrder,
  }) async {
    final json =
        await _send(
              'PUT',
              '/api/accounts/$accountId',
              accessToken: accessToken,
              body: {
                'name': name,
                'currencyCode': currencyCode,
                'kind': kind.index + 1,
                'isArchived': isArchived,
                'displayOrder': displayOrder,
              },
            )
            as Map<String, dynamic>;

    return MoneyAccount.fromJson(json);
  }

  Future<List<CategoryModel>> getCategories(String accessToken) async {
    final json =
        await _send('GET', '/api/categories', accessToken: accessToken)
            as List<dynamic>;

    return json
        .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<CategoryModel> createCategory(
    String accessToken, {
    required String name,
    required CategoryKind kind,
    String? icon,
    String? color,
    int? displayOrder,
  }) async {
    final json =
        await _send(
              'POST',
              '/api/categories',
              accessToken: accessToken,
              body: {
                'name': name,
                'kind': kind == CategoryKind.income ? 2 : 1,
                'icon': icon,
                'color': color,
                'displayOrder': displayOrder,
              },
            )
            as Map<String, dynamic>;

    return CategoryModel.fromJson(json);
  }

  Future<CategoryModel> updateCategory(
    String accessToken, {
    required String categoryId,
    required String name,
    String? icon,
    String? color,
    required bool isArchived,
    int? displayOrder,
  }) async {
    final json =
        await _send(
              'PUT',
              '/api/categories/$categoryId',
              accessToken: accessToken,
              body: {
                'name': name,
                'icon': icon,
                'color': color,
                'isArchived': isArchived,
                'displayOrder': displayOrder,
              },
            )
            as Map<String, dynamic>;

    return CategoryModel.fromJson(json);
  }

  Future<void> deleteCategory(
    String accessToken, {
    required String categoryId,
  }) async {
    await _send(
      'DELETE',
      '/api/categories/$categoryId',
      accessToken: accessToken,
    );
  }

  Future<DashboardSummary> getDashboardSummary(
    String accessToken, {
    String? accountId,
  }) async {
    final json =
        await _send(
              'GET',
              '/api/dashboard/summary',
              accessToken: accessToken,
              queryParameters: {
                if (accountId != null && accountId.isNotEmpty)
                  'accountId': accountId,
              },
            )
            as Map<String, dynamic>;

    return DashboardSummary.fromJson(json);
  }

  Future<TransactionPage> getTransactions(
    String accessToken, {
    String? accountId,
    String? categoryId,
    TransactionEntryType? entryType,
    DateTime? dateFrom,
    DateTime? dateTo,
    int pageNumber = 1,
    int pageSize = 25,
  }) async {
    final json =
        await _send(
              'GET',
              '/api/transactions',
              accessToken: accessToken,
              queryParameters: {
                'pageNumber': '$pageNumber',
                'pageSize': '$pageSize',
                if (accountId != null && accountId.isNotEmpty)
                  'accountId': accountId,
                if (categoryId != null && categoryId.isNotEmpty)
                  'categoryId': categoryId,
                if (entryType != null) 'entryType': '${entryType.code}',
                if (dateFrom != null)
                  'dateFromUtc': dateFrom.toUtc().toIso8601String(),
                if (dateTo != null)
                  'dateToUtc': dateTo.toUtc().toIso8601String(),
              },
            )
            as Map<String, dynamic>;

    return TransactionPage.fromJson(json);
  }

  Future<TransactionItem> createTransaction(
    String accessToken, {
    required String accountId,
    required String categoryId,
    required TransactionEntryType entryType,
    required double amount,
    required DateTime occurredAt,
    String? note,
  }) async {
    final json =
        await _send(
              'POST',
              '/api/transactions',
              accessToken: accessToken,
              body: {
                'accountId': accountId,
                'categoryId': categoryId,
                'entryType': entryType.code,
                'amount': amount,
                'note': note,
                'occurredAtUtc': occurredAt.toUtc().toIso8601String(),
              },
            )
            as Map<String, dynamic>;

    return TransactionItem.fromJson(json);
  }

  Future<TransactionItem> updateTransaction(
    String accessToken, {
    required String transactionId,
    required String accountId,
    required String categoryId,
    required TransactionEntryType entryType,
    required double amount,
    required DateTime occurredAt,
    String? note,
  }) async {
    final json =
        await _send(
              'PUT',
              '/api/transactions/$transactionId',
              accessToken: accessToken,
              body: {
                'accountId': accountId,
                'categoryId': categoryId,
                'entryType': entryType.code,
                'amount': amount,
                'note': note,
                'occurredAtUtc': occurredAt.toUtc().toIso8601String(),
              },
            )
            as Map<String, dynamic>;

    return TransactionItem.fromJson(json);
  }

  Future<List<TransactionItem>> createTransfer(
    String accessToken, {
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required DateTime occurredAt,
    String? note,
  }) async {
    final json =
        await _send(
              'POST',
              '/api/transactions/transfer',
              accessToken: accessToken,
              body: {
                'fromAccountId': fromAccountId,
                'toAccountId': toAccountId,
                'amount': amount,
                'note': note,
                'occurredAtUtc': occurredAt.toUtc().toIso8601String(),
              },
            )
            as List<dynamic>;

    return json
        .map((item) => TransactionItem.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<void> deleteTransaction(
    String accessToken, {
    required String transactionId,
  }) async {
    await _send(
      'DELETE',
      '/api/transactions/$transactionId',
      accessToken: accessToken,
    );
  }

  void close() {
    _httpClient.close();
  }

  Future<dynamic> _send(
    String method,
    String path, {
    String? accessToken,
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl$path',
    ).replace(queryParameters: queryParameters);

    try {
      final headers = <String, String>{
        'Accept': 'application/json',
        if (body != null) 'Content-Type': 'application/json; charset=utf-8',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      };

      final response = await switch (method) {
        'GET' => _httpClient.get(uri, headers: headers),
        'POST' => _httpClient.post(
          uri,
          headers: headers,
          body: jsonEncode(body ?? const <String, dynamic>{}),
        ),
        'PUT' => _httpClient.put(
          uri,
          headers: headers,
          body: jsonEncode(body ?? const <String, dynamic>{}),
        ),
        'DELETE' => _httpClient.delete(uri, headers: headers),
        _ => throw UnsupportedError('Unsupported HTTP method: $method'),
      };

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.bodyBytes.isEmpty) {
          return null;
        }

        return jsonDecode(utf8.decode(response.bodyBytes));
      }

      throw ApiException(
        statusCode: response.statusCode,
        message: _extractErrorMessage(response),
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        statusCode: 0,
        message:
            'Не удалось связаться с API. Проверь, что backend запущен локально.',
      );
    }
  }

  String _extractErrorMessage(http.Response response) {
    if (response.bodyBytes.isEmpty) {
      return 'Сервер вернул ошибку ${response.statusCode}.';
    }

    try {
      final payload = jsonDecode(utf8.decode(response.bodyBytes));
      if (payload is Map<String, dynamic>) {
        final title = payload['title']?.toString();
        final detail = payload['detail']?.toString();
        final message = payload['message']?.toString();
        final parts = [title, detail, message]
            .whereType<String>()
            .where((part) => part.trim().isNotEmpty)
            .toList(growable: false);
        if (parts.isNotEmpty) {
          return parts.join(' ');
        }
      }
    } catch (_) {
      // Fall back to a generic message if the error payload is not JSON.
    }

    return 'Сервер вернул ошибку ${response.statusCode}.';
  }
}
