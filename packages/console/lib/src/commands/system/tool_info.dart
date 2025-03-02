/// Represents information about a tool including its version and description.
class ToolInfo {
  String? version;
  final String description;

  ToolInfo({
    this.version,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'version': version,
        'description': description,
      };
}

/// Represents a category of tools.
class ToolCategory {
  final Map<String, ToolInfo> tools;

  ToolCategory(this.tools);

  Map<String, dynamic> toJson() => Map.fromEntries(
        tools.entries.map(
          (e) => MapEntry(e.key, e.value.toJson()),
        ),
      );
}

/// Represents the complete tool version data.
class ToolVersionData {
  final Map<String, ToolCategory> categories;
  final List<String> missing;

  ToolVersionData({
    required this.categories,
    required this.missing,
  });

  Map<String, dynamic> toJson() => {
        'tools': Map.fromEntries(
          categories.entries.map(
            (e) => MapEntry(e.key, e.value.toJson()),
          ),
        ),
        'missing': missing,
      };
}
