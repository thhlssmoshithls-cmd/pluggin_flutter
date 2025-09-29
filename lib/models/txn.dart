// lib/models/txn.dart
class Txn {
  final int? id;
  final int? userId;
  final String createdAt;
  final int total;

  Txn({this.id, this.userId, required this.createdAt, required this.total});

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'created_at': createdAt,
      'total': total,
    };
  }

  factory Txn.fromMap(Map<String, dynamic> m) => Txn(
        id: m['id'] as int?,
        userId: m['user_id'] as int?,
        createdAt: m['created_at'],
        total: m['total'],
      );
}
