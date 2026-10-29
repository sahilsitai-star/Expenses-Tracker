class Account {
  int? id;
  String name;
  String type; // 'Bank', 'Cash', 'Payable', 'Receivable'
  double balance;
  String? category; // Payable category editing support
  String? phoneNumber;

  Account({
    this.id,
    required this.name,
    required this.type,
    required this.balance,
    this.category,
    this.phoneNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'balance': balance,
      'category': category,
      'phoneNumber': phoneNumber,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: (map['id'] as num?)?.toInt(),
      name: map['name'] as String? ?? '',
      type: map['type'] as String? ?? 'Cash',
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
    );
  }
}

class TransactionItem {
  int? id;
  int accountId;
  String type; // 'Income', 'Expense'
  double amount;
  String date;
  String description;

  TransactionItem({
    this.id,
    required this.accountId,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'type': type,
      'amount': amount,
      'date': date,
      'description': description,
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: (map['id'] as num?)?.toInt(),
      accountId: (map['accountId'] as num?)?.toInt() ?? 0,
      type: map['type'] as String? ?? 'Expense',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: map['date'] as String? ?? '',
      description: map['description'] as String? ?? '',
    );
  }
}
