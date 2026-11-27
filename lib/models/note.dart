/// A note. [content] holds the rich text as a Quill delta JSON string.
class Note {
  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.coverImagePath,
    this.collectionId,
    this.color,
    this.pinned = false,
    this.attachmentPaths = const [],
  });

  /// Empty Quill document (a single newline insert).
  static const String emptyContent = '[{"insert":"\\n"}]';

  final String id;
  final String title;
  final String content;
  final String? coverImagePath;
  final String? collectionId;

  /// Optional note colour as an ARGB32 integer.
  final int? color;
  final bool pinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Local paths of images and drawings embedded in the note.
  final List<String> attachmentPaths;

  Note copyWith({
    String? title,
    String? content,
    String? coverImagePath,
    bool clearCoverImage = false,
    String? collectionId,
    bool clearCollection = false,
    int? color,
    bool clearColor = false,
    bool? pinned,
    DateTime? updatedAt,
    List<String>? attachmentPaths,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      coverImagePath: clearCoverImage
          ? null
          : (coverImagePath ?? this.coverImagePath),
      collectionId: clearCollection
          ? null
          : (collectionId ?? this.collectionId),
      color: clearColor ? null : (color ?? this.color),
      pinned: pinned ?? this.pinned,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attachmentPaths: attachmentPaths ?? this.attachmentPaths,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'coverImagePath': coverImagePath,
    'collectionId': collectionId,
    'color': color,
    'pinned': pinned,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'attachmentPaths': attachmentPaths,
  };

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? emptyContent,
      coverImagePath: json['coverImagePath'] as String?,
      collectionId: json['collectionId'] as String?,
      color: json['color'] as int?,
      pinned: json['pinned'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      attachmentPaths: (json['attachmentPaths'] as List<dynamic>? ?? const [])
          .cast<String>()
          .toList(),
    );
  }
}
