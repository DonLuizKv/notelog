import 'dart:convert';

/// Extracts plain text from a Quill delta JSON string (a list of operations
/// like `{"insert": "text"}`). Embeds such as images are skipped. Returns the
/// raw string when it is not valid delta JSON.
String plainTextOf(String content) {
  try {
    final decoded = jsonDecode(content);
    if (decoded is! List) return content;
    final buffer = StringBuffer();
    for (final op in decoded) {
      if (op is Map && op['insert'] is String) {
        buffer.write(op['insert'] as String);
      }
    }
    return buffer.toString().trimRight();
  } on FormatException {
    return content;
  }
}

/// Builds a minimal Quill delta JSON string from plain text.
String deltaFromPlainText(String text) {
  final normalized = text.endsWith('\n') ? text : '$text\n';
  return jsonEncode([
    {'insert': normalized},
  ]);
}
