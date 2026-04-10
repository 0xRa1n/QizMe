import 'package:flutter/material.dart';

class QizmeSearchDelegate extends SearchDelegate<String> {
  final bool darkMode;

  QizmeSearchDelegate({required this.darkMode});

  final List<String> _options = [
    'Create card',
    'Library',
    'Account',
    'Settings',
  ];

  final List<String> _optionValues = [
    'create_card',
    'library',
    'account',
    'settings',
  ];

  final Map<String, IconData> _optionIcons = {
    'Create card': Icons.add,
    'Library': Icons.library_books,
    'Account': Icons.person,
    'Settings': Icons.settings,
  };

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      scaffoldBackgroundColor: darkMode
          ? const Color(0xFF121212)
          : Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: darkMode ? const Color(0xFF1E1E1E) : Colors.white,
        iconTheme: IconThemeData(color: darkMode ? Colors.white : Colors.black),
        toolbarTextStyle: TextTheme(
          titleLarge: TextStyle(
            color: darkMode ? Colors.white : Colors.black,
            fontSize: 20,
          ),
        ).bodyMedium,
        titleTextStyle: TextTheme(
          titleLarge: TextStyle(
            color: darkMode ? Colors.white : Colors.black,
            fontSize: 20,
          ),
        ).titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: darkMode ? Colors.grey[400] : Colors.black54,
        ),
        border: InputBorder.none,
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(color: darkMode ? Colors.white : Colors.black),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final suggestions = _options.where((option) {
      return option.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          leading: Icon(
            _optionIcons[suggestion],
            color: darkMode ? Colors.white70 : Colors.black87,
          ),
          title: Text(
            suggestion,
            style: TextStyle(color: darkMode ? Colors.white : Colors.black),
          ),
          onTap: () {
            final value = _optionValues[_options.indexOf(suggestion)];
            close(context, value);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = _options.where((option) {
      return option.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          leading: Icon(
            _optionIcons[suggestion],
            color: darkMode ? Colors.white70 : Colors.black87,
          ),
          title: Text(
            suggestion,
            style: TextStyle(color: darkMode ? Colors.white : Colors.black),
          ),
          onTap: () {
            final value = _optionValues[_options.indexOf(suggestion)];
            close(context, value);
          },
        );
      },
    );
  }
}
