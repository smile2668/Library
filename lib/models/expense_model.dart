class ExpenseModel {
  final String id;
  final String libraryId;
  final String name;
  final double amount;
  final DateTime date;
  final String notes;
  final String category;

  const ExpenseModel({
    required this.id,
    required this.libraryId,
    required this.name,
    required this.amount,
    required this.date,
    this.notes = '',
    this.category = 'Other',
  });

  Map<String, dynamic> toMap() => {
        'library_id': libraryId,
        'name': name,
        'amount': amount,
        'date': date.toIso8601String(),
        'notes': notes,
        'category': category,
      };

  factory ExpenseModel.fromMap(String id, Map<String, dynamic> map) => ExpenseModel(
        id: id,
        libraryId: map['library_id'] as String? ?? '',
        name: map['name'] as String? ?? '',
        amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
        date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
        notes: map['notes'] as String? ?? '',
        category: map['category'] as String? ?? 'Other',
      );

  ExpenseModel copyWith({
    String? id,
    String? libraryId,
    String? name,
    double? amount,
    DateTime? date,
    String? notes,
    String? category,
  }) =>
      ExpenseModel(
        id: id ?? this.id,
        libraryId: libraryId ?? this.libraryId,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        notes: notes ?? this.notes,
        category: category ?? this.category,
      );
}
