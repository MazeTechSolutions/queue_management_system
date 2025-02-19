class QueueItemModel {
  final String id;
  final String name;
  final bool isCompleted;
  final int? completedAt;

  QueueItemModel({
    required this.id,
    required this.name,
    required this.isCompleted,
    this.completedAt,
  });

  factory QueueItemModel.fromMap(Map<String, dynamic> map) {
    return QueueItemModel(
        id: map['id'] as String? ?? '',
        name: map['full_name'] as String? ?? '',
        isCompleted: map['isCompleted'] ?? false,
        completedAt: map['completedAt'] as int? ?? 0);
  }
}
