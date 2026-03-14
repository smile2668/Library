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
        'library_id': libraryId,
        'student_id': studentId,
        'student_name': studentName,
        'seat_number': seatNumber,
        'plan': plan,
        'due_date': dueDate.toIso8601String(),
        'payment_method': paymentMethod,
        'payment_status': paymentStatus,
      };

  factory FeeModel.fromMap(String id, Map<String, dynamic> map) => FeeModel(
        id: id,
        libraryId: map['library_id'] as String? ?? map['libraryId'] as String? ?? '',
        studentId: map['student_id'] as String? ?? map['studentId'] as String? ?? '',
        studentName: map['student_name'] as String? ?? map['studentName'] as String? ?? '',
        seatNumber: map['seat_number'] as int? ?? map['seatNumber'] as int? ?? 0,
        plan: map['plan'] as String? ?? '1 Month',
        dueDate: DateTime.tryParse(
                map['due_date'] as String? ?? map['dueDate'] as String? ?? '') ??
            DateTime.now(),
        paymentMethod:
            map['payment_method'] as String? ?? map['paymentMethod'] as String? ?? 'Pay to counter',
        paymentStatus:
            map['payment_status'] as String? ?? map['paymentStatus'] as String? ?? 'Pending',
      );

  FeeModel copyWith({
    String? id,
    String? libraryId,
    String? studentId,
    String? studentName,
    int? seatNumber,
    String? plan,
    DateTime? dueDate,
    String? paymentMethod,
    String? paymentStatus,
  }) =>
      FeeModel(
        id: id ?? this.id,
        libraryId: libraryId ?? this.libraryId,
        studentId: studentId ?? this.studentId,
        studentName: studentName ?? this.studentName,
        seatNumber: seatNumber ?? this.seatNumber,
        plan: plan ?? this.plan,
        dueDate: dueDate ?? this.dueDate,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        paymentStatus: paymentStatus ?? this.paymentStatus,
      );
}
