/// A named group of notes.
class Collection {
  const Collection({
    required this.id,
    required this.name,
    required this.createdAt,
    this.color,
  });

  final String id;
  final String name;

  /// Optional colour as an ARGB32 integer.
  final int? color;
  final DateTime createdAt;

  Collection copyWith({String? name, int? color}) {
    return Collection(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color': color,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      color: json['color'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
