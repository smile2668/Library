class FeeModel {
  final String id;
  final String libraryId;
  final String studentId;
  final String studentName;
  final int seatNumber;
  final String plan;
  final DateTime dueDate;
  final String paymentMethod;
  final String paymentStatus;

  const FeeModel({
    required this.id,
    required this.libraryId,
    required this.studentId,
    required this.studentName,
    required this.seatNumber,
    required this.plan,
    required this.dueDate,
    required this.paymentMethod,
    required this.paymentStatus,
  });

  Map<String, dynamic> toMap() => {
        'libraryId': libraryId,
        'studentId': studentId,
        'studentName': studentName,
        'seatNumber': seatNumber,
        'plan': plan,
        'dueDate': dueDate.toIso8601String(),
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus,
      };

  factory FeeModel.fromMap(String id, Map<String, dynamic> map) => FeeModel(
        id: id,
        libraryId: map['libraryId'] as String? ?? '',
        studentId: map['studentId'] as String? ?? '',
        studentName: map['studentName'] as String? ?? '',
        seatNumber: map['seatNumber'] as int? ?? 0,
        plan: map['plan'] as String? ?? '1 Month',
        dueDate: DateTime.tryParse(map['dueDate'] as String? ?? '') ?? DateTime.now(),
        paymentMethod: map['paymentMethod'] as String? ?? 'Pay to counter',
        paymentStatus: map['paymentStatus'] as String? ?? 'Pending',
      );
}
