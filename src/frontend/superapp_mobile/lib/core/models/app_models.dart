double _readDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value) ?? 0;
  }

  return 0;
}

int _readInt(Object? value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  if (value is String) {
    return int.tryParse(value) ?? 0;
  }

  return 0;
}

bool _readBool(Object? value) {
  if (value is bool) {
    return value;
  }

  if (value is String) {
    return value.toLowerCase() == 'true';
  }

  return false;
}

String _readString(Object? value) => value?.toString() ?? '';

DateTime _readDateTime(Object? value) {
  final text = _readString(value);
  if (text.isEmpty) {
    return DateTime.now();
  }

  return DateTime.parse(text).toLocal();
}

enum UserRole {
  user,
  superAdmin;

  factory UserRole.fromCode(Object? value) =>
      _readInt(value) == 2 ? UserRole.superAdmin : UserRole.user;

  String get label => this == UserRole.superAdmin ? 'Super Admin' : 'User';
}

enum AccountKind {
  cash,
  bankCard,
  savings,
  credit,
  investment;

  factory AccountKind.fromCode(Object? value) {
    return switch (_readInt(value)) {
      2 => AccountKind.bankCard,
      3 => AccountKind.savings,
      4 => AccountKind.credit,
      5 => AccountKind.investment,
      _ => AccountKind.cash,
    };
  }

  String get label => switch (this) {
    AccountKind.cash => 'Наличные',
    AccountKind.bankCard => 'Карта',
    AccountKind.savings => 'Накопления',
    AccountKind.credit => 'Кредитный',
    AccountKind.investment => 'Инвестиции',
  };
}

enum CategoryKind {
  expense,
  income;

  factory CategoryKind.fromCode(Object? value) =>
      _readInt(value) == 2 ? CategoryKind.income : CategoryKind.expense;
}

enum TransactionEntryType {
  expense,
  income,
  transferOut,
  transferIn;

  factory TransactionEntryType.fromCode(Object? value) {
    return switch (_readInt(value)) {
      2 => TransactionEntryType.income,
      3 => TransactionEntryType.transferOut,
      4 => TransactionEntryType.transferIn,
      _ => TransactionEntryType.expense,
    };
  }

  int get code => switch (this) {
    TransactionEntryType.expense => 1,
    TransactionEntryType.income => 2,
    TransactionEntryType.transferOut => 3,
    TransactionEntryType.transferIn => 4,
  };

  String get label => switch (this) {
    TransactionEntryType.expense => 'Расход',
    TransactionEntryType.income => 'Доход',
    TransactionEntryType.transferOut => 'Перевод',
    TransactionEntryType.transferIn => 'Перевод',
  };

  CategoryKind get categoryKind => this == TransactionEntryType.income
      ? CategoryKind.income
      : CategoryKind.expense;
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.preferredCurrency,
    required this.avatarUrl,
    required this.role,
  });

  final String id;
  final String email;
  final String fullName;
  final String preferredCurrency;
  final String? avatarUrl;
  final UserRole role;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: _readString(json['id']),
      email: _readString(json['email']),
      fullName: _readString(json['fullName']),
      preferredCurrency: _readString(json['preferredCurrency']).isEmpty
          ? 'KZT'
          : _readString(json['preferredCurrency']),
      avatarUrl: json['avatarUrl']?.toString(),
      role: UserRole.fromCode(json['role']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'preferredCurrency': preferredCurrency,
      'avatarUrl': avatarUrl,
      'role': role == UserRole.superAdmin ? 2 : 1,
    };
  }
}

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.accessTokenExpiresAtUtc,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final DateTime accessTokenExpiresAtUtc;
  final String refreshToken;
  final UserProfile user;

  factory AuthSession.fromAuthResponse(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: _readString(json['accessToken']),
      accessTokenExpiresAtUtc: _readDateTime(
        json['accessTokenExpiresAtUtc'],
      ).toUtc(),
      refreshToken: _readString(json['refreshToken']),
      user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: _readString(json['accessToken']),
      accessTokenExpiresAtUtc: _readDateTime(
        json['accessTokenExpiresAtUtc'],
      ).toUtc(),
      refreshToken: _readString(json['refreshToken']),
      user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'accessTokenExpiresAtUtc': accessTokenExpiresAtUtc.toIso8601String(),
      'refreshToken': refreshToken,
      'user': user.toJson(),
    };
  }

  AuthSession copyWith({
    String? accessToken,
    DateTime? accessTokenExpiresAtUtc,
    String? refreshToken,
    UserProfile? user,
  }) {
    return AuthSession(
      accessToken: accessToken ?? this.accessToken,
      accessTokenExpiresAtUtc:
          accessTokenExpiresAtUtc ?? this.accessTokenExpiresAtUtc,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
    );
  }
}

class DashboardSummary {
  const DashboardSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.net,
    required this.totalBalance,
  });

  final double totalIncome;
  final double totalExpense;
  final double net;
  final double totalBalance;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalIncome: _readDouble(json['totalIncome']),
      totalExpense: _readDouble(json['totalExpense']),
      net: _readDouble(json['net']),
      totalBalance: _readDouble(json['totalBalance']),
    );
  }
}

class MoneyAccount {
  const MoneyAccount({
    required this.id,
    required this.name,
    required this.currencyCode,
    required this.kind,
    required this.balance,
    required this.isArchived,
    required this.displayOrder,
  });

  final String id;
  final String name;
  final String currencyCode;
  final AccountKind kind;
  final double balance;
  final bool isArchived;
  final int displayOrder;

  factory MoneyAccount.fromJson(Map<String, dynamic> json) {
    return MoneyAccount(
      id: _readString(json['id']),
      name: _readString(json['name']),
      currencyCode: _readString(json['currencyCode']),
      kind: AccountKind.fromCode(json['kind']),
      balance: _readDouble(json['balance']),
      isArchived: _readBool(json['isArchived']),
      displayOrder: _readInt(json['displayOrder']),
    );
  }
}

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.kind,
    required this.icon,
    required this.color,
    required this.isSystem,
    required this.isArchived,
    required this.displayOrder,
  });

  final String id;
  final String name;
  final CategoryKind kind;
  final String? icon;
  final String? color;
  final bool isSystem;
  final bool isArchived;
  final int displayOrder;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: _readString(json['id']),
      name: _readString(json['name']),
      kind: CategoryKind.fromCode(json['kind']),
      icon: json['icon']?.toString(),
      color: json['color']?.toString(),
      isSystem: _readBool(json['isSystem']),
      isArchived: _readBool(json['isArchived']),
      displayOrder: _readInt(json['displayOrder']),
    );
  }
}

class TransactionItem {
  const TransactionItem({
    required this.id,
    required this.accountId,
    required this.accountName,
    required this.categoryId,
    required this.categoryName,
    required this.entryType,
    required this.amount,
    required this.note,
    required this.occurredAt,
    required this.transferGroupId,
    required this.counterpartyAccountId,
  });

  final String id;
  final String accountId;
  final String accountName;
  final String? categoryId;
  final String? categoryName;
  final TransactionEntryType entryType;
  final double amount;
  final String? note;
  final DateTime occurredAt;
  final String? transferGroupId;
  final String? counterpartyAccountId;

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: _readString(json['id']),
      accountId: _readString(json['accountId']),
      accountName: _readString(json['accountName']),
      categoryId: json['categoryId']?.toString(),
      categoryName: json['categoryName']?.toString(),
      entryType: TransactionEntryType.fromCode(json['entryType']),
      amount: _readDouble(json['amount']),
      note: json['note']?.toString(),
      occurredAt: _readDateTime(json['occurredAtUtc']),
      transferGroupId: json['transferGroupId']?.toString(),
      counterpartyAccountId: json['counterpartyAccountId']?.toString(),
    );
  }
}

class TransactionPage {
  const TransactionPage({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
  });

  final List<TransactionItem> items;
  final int pageNumber;
  final int pageSize;
  final int totalCount;

  factory TransactionPage.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? const <dynamic>[]);
    return TransactionPage(
      items: rawItems
          .map((item) => TransactionItem.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      pageNumber: _readInt(json['pageNumber']),
      pageSize: _readInt(json['pageSize']),
      totalCount: _readInt(json['totalCount']),
    );
  }
}
