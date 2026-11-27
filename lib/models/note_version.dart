/// An immutable snapshot of a note at a point in time.
class NoteVersion {
  const NoteVersion({
    required this.id,
    required this.noteId,
    required this.number,
    required this.title,
    required this.content,
    required this.createdAt,
    this.label,
    this.coverImagePath,
  });

  final String id;
  final String noteId;

  /// Sequential version number per note, starting at 1.
  final int number;

  /// Optional message describing the version.
  final String? label;
  final String title;

  /// Quill delta JSON string.
  final String content;
  final String? coverImagePath;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'noteId': noteId,
    'number': number,
    'label': label,
    'title': title,
    'content': content,
    'coverImagePath': coverImagePath,
    'createdAt': createdAt.toIso8601String(),
  };

  factory NoteVersion.fromJson(Map<String, dynamic> json) {
    return NoteVersion(
      id: json['id'] as String,
      noteId: json['noteId'] as String,
      number: json['number'] as int,
      label: json['label'] as String?,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      coverImagePath: json['coverImagePath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
