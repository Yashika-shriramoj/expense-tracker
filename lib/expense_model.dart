class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.createdAt,
  });

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'].toString(),
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}