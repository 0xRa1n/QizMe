import 'package:flutter/material.dart';
import 'package:qizme/services/card_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Import home_widgets.dart with a prefix to avoid name collisions.
import 'package:qizme/views/widgets/home_widgets.dart' as home_widgets;
import 'package:qizme/views/widgets/menu_widgets.dart';
import 'package:qizme/views/home/tabs/edit_account.dart';
import 'package:qizme/views/home/tabs/add_card_set.dart';
import 'package:qizme/views/home/tabs/settings.dart';
// Add this import at the top of your file
import 'package:qizme/repositories/auth_repository.dart';
import 'package:qizme/views/screens/create_flashcard_page.dart';
import 'package:qizme/views/screens/edit_flashcard_page.dart';
import 'package:qizme/views/screens/subject_content_page.dart';

class QizMe extends StatefulWidget {
  const QizMe({super.key});

  @override
  State<QizMe> createState() => _QizMeState();
}

class _QizMeState extends State<QizMe> {
  int currentPageIndex = 0;
  SharedPreferences? _prefs;
  bool _isLoading = true;
  bool _showEditAccount = false;
  bool _showSettings = false;
  bool _showCreateFlashcard = false;
  Map<String, dynamic>? _flashcardToEdit;
  Map<String, dynamic>? _selectedSubject;

  bool _showEditCardSetName = false;
  bool _showEditFlashcard = false;
  Map<String, dynamic>? _editingCardSet;
  List<Map<String, dynamic>> _editingFlashcards = [];
  int _currentFlashcardIndex = 0;
  // --- THEME STATE ---
  // This is the initial value before preferences are loaded.
  bool _darkMode = false;
  int _currentStreak = 0;

  final AuthRepository _authRepository =
      AuthRepository(); // since the Auth Repository is a class, we have to instantiate it

  static const double iconSize = 31;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentStreak = prefs.getInt('currentStreak') ?? 0;
    });
  }

  Future<void> _initializePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _prefs = prefs;
      // Load the saved dark mode preference, defaulting to `false` (light) if not set.
      _darkMode = _prefs?.getBool('darkMode') ?? false;
      _isLoading = false;
    });
  }

  // --- THEME TOGGLE FUNCTION ---
  // This function updates the theme and saves the preference.
  Future<void> _toggleDarkMode(bool newValue) async {
    setState(() {
      _darkMode = newValue;
    });
    await _prefs?.setBool('darkMode', newValue);
  }

  // Method to allow child widgets to change the tab
  void changeTab(int index) {
    setState(() {
      currentPageIndex = index;
      if (index != 3) {
        _showEditAccount = false;
        _showSettings = false;
      }
    });
  }

  void _selectSubject(Map<String, dynamic> subject) {
    setState(() {
      _selectedSubject = subject;
    });
  }

  void _unselectSubject() {
    setState(() {
      _selectedSubject = null;
      _showCreateFlashcard = false;
      _flashcardToEdit = null;
    });
  }

  Future<void> _refreshUserData() async {
    await _loadStreak();
  }

  Widget _buildHomePage() {
    return RefreshIndicator(
      onRefresh: _refreshUserData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            home_widgets.buildStreakCard(
              darkMode: _darkMode,
              streak: _currentStreak,
            ),
            const SizedBox(height: 24),
            home_widgets.buildCalendarSection(darkMode: _darkMode),
            const SizedBox(height: 24),
            home_widgets.buildCreateSubjectCard(
              onAddCardSet: () => setState(() => changeTab(1)),
              darkMode: _darkMode,
              onSubjectTap: _selectSubject,
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> getEmailFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  Widget _buildLibraryPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Library',
            style: TextStyle(
              fontSize: 32, // Increased font size for emphasis
              fontWeight: FontWeight.bold,
              color: _darkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<String?>(
            future: getEmailFromPreferences(),
            builder: (context, emailSnapshot) {
              if (emailSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (emailSnapshot.hasError ||
                  !emailSnapshot.hasData ||
                  emailSnapshot.data == null) {
                return const Center(
                  child: Text('Could not retrieve user data.'),
                );
              }

              final email = emailSnapshot.data!;
              return FutureBuilder<Map<String, dynamic>>(
                future: CardService.getCardSet(email: email),
                builder: (context, cardSnapshot) {
                  if (cardSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (cardSnapshot.hasError) {
                    return Center(child: Text('Error: ${cardSnapshot.error}'));
                  }

                  final cards = cardSnapshot.data?['raw'] as List? ?? [];

                  if (cards.isEmpty) {
                    // This is the new empty state UI
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: _darkMode
                                  ? Colors.grey[850]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _darkMode
                                    ? Colors.grey[700]!
                                    : Colors.grey[400]!,
                                width: 1.5,
                              ),
                            ),
                            child: const Text(
                              'No decks yet! Create a card?',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              // This will trigger the CreateFlashcardScreen to show up
                              setState(() => changeTab(1));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _darkMode
                                  ? Colors.grey[700]
                                  : Colors.grey[300],
                              foregroundColor: _darkMode
                                  ? Colors.white
                                  : Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 50,
                                vertical: 15,
                              ),
                              side: BorderSide(
                                color: _darkMode
                                    ? Colors.grey[600]!
                                    : Colors.grey[500]!,
                                width: 1.5,
                              ),
                            ),
                            child: const Text(
                              'Create',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // This part remains the same, for when the library is not empty
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: home_widgets.SubjectProgressCard(
                          subject: card,
                          darkMode: _darkMode,
                          onTap: () => _selectSubject(card),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // builds the menu option (profile picture + name) that appears in the menu page
  Widget _buildMenuOption({
    required BuildContext context,
    required String name,
    required String profilePicture,
  }) {
    String resolvedUrl = profilePicture;

    if (resolvedUrl.contains('localhost')) {
      resolvedUrl = resolvedUrl.replaceFirst(
        'http://localhost:8000',
        'http://10.0.2.2:8000',
      );
    }
    final cacheBustedUrl =
        '$resolvedUrl?ts=${DateTime.now().millisecondsSinceEpoch}'; // the purpose of this is to bust the cache so that the image is refreshed every time the user logs in

    return Container(
      margin: const EdgeInsets.only(top: 65),
      child: Column(
        children: [
          Column(
            children: [
              SizedBox(
                height: 100,
                width: 100,
                child: ClipOval(
                  child: profilePicture.isNotEmpty
                      ? Image.network(
                          cacheBustedUrl,
                          key: ValueKey(cacheBustedUrl), // force refresh
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/images/user.png',
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          'assets/images/user.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Hello, ",
                style: TextStyle(
                  color: _darkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _darkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // this is tabs. since in our design, the bottom bar does not change, we need to use tabs to navigate between pages
          buildMenuButtons(
            context: context,
            darkMode:
                _darkMode, // Pass the darkMode state here (if darkmode is true, the buttons will be green, if false, they will be light)
            onAccountTap: () {
              // if the account button is tapped, show the edit account page
              setState(() {
                _showEditAccount = true;
                _showSettings = false;
              });
            },
            onSettingsTap: () {
              // if the settings button is tapped, show the settings page
              setState(() {
                _showSettings = true;
                _showEditAccount = false;
              });
            },
          ),
          const Spacer(),
          buildMenuLogout(context: context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuPage() {
    // this builds the menu page, above was for building the options
    final name = _prefs?.getString('name') ?? 'None';
    final profilePicture = _prefs?.getString('profilePicture') ?? '';

    if (_showEditAccount) {
      // if the edit account page is shown, return the edit account page widget
      return EditAccountPage(
        onBack: () {
          // if the back button is tapped, hide the edit account page
          setState(() {
            _showEditAccount = false;
          });
        },
        onProfileUpdated: () async {
          // if the profile is updated, refresh the user data
          await _refreshUserData();
        },
      );
    }

    if (_showSettings) {
      // Pass the current theme state and the toggle function to the SettingsPage.
      return SettingsPage(
        initialDarkMode: _darkMode,
        onThemeChanged: _toggleDarkMode,
        onBack: (settings) async {
          // Make the callback async
          // The 'settings' object is a Map, so access its values with ['key']
          final pushNotification = settings['pushNotification'] ?? false;
          final darkModeValue = settings['darkMode'] ?? _darkMode;

          // Update the theme if it changed.
          if (darkModeValue != _darkMode) {
            await _toggleDarkMode(darkModeValue);
          }

          try {
            // Call the method on the _authRepository instance
            await _authRepository.updateUserPreferences(
              darkMode: darkModeValue,
              pushNotification: pushNotification,
            );
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to save settings: $e')),
              );
            }
          }
        },
      );
    }
    // if none of the above conditions are met, return the menu option widget (default)
    return _buildMenuOption(
      context: context,
      name: name,
      profilePicture: profilePicture,
    );
  }

  @override
  Widget build(BuildContext context) {
    // get the darkMode from the preferences and set the theme accordingly. we will also show a loading screen while we are loading the preferences to avoid showing the wrong theme for a split second
    bool darkModeFromPrefs = _prefs?.getBool('darkMode') ?? true;
    print('Dark mode from preferences: $darkModeFromPrefs');

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF5D8A56)),
        ),
      );
    }

    final pages = <Widget>[
      _buildHomePage(),
      AddCardSet(darkMode: _darkMode), // Pass the darkMode value here
      _buildLibraryPage(),
      _buildMenuPage(),
    ];

    Widget? body;
    if (_flashcardToEdit != null && _selectedSubject != null) {
      body = EditFlashcardPage(
        darkMode: _darkMode,
        flashcard: _flashcardToEdit!,
        cardId: _selectedSubject!['_id'] as String,
        onDone: () {
          setState(() {
            _flashcardToEdit = null;
          });
        },
      );
    } else if (_showCreateFlashcard && _selectedSubject != null) {
      body = CreateFlashcardPage(
        darkMode: _darkMode,
        cardId: _selectedSubject!['_id'] as String,
        onFlashcardAdded: (newCard) {
          setState(() {
            if (_selectedSubject != null) {
              final flashcards = List<dynamic>.from(
                _selectedSubject!['flashcards'] ?? [],
              );
              flashcards.add(newCard);
              _selectedSubject!['flashcards'] = flashcards;
            }
          });
        },
        onDone: () {
          setState(() {
            _showCreateFlashcard = false;
          });
        },
      ); // Placeholder for Create Flashcard view
    } else if (_selectedSubject != null) {
      body = SubjectContentPage(
        subject: _selectedSubject!,
        onEditFlashcard: (flashcard) {
          setState(() {
            _flashcardToEdit = flashcard;
          });
        },
      );
    } else {
      body = pages[currentPageIndex];
    }

    return Scaffold(
      backgroundColor: _darkMode
          ? const Color(0xFF121212)
          : const Color(0xFFF8F9FA), // Conditional background
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 5, 113, 75),
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: (_flashcardToEdit != null)
            ? Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _flashcardToEdit = null;
                      });
                    },
                  ),
                  const Text(
                    'Edit Flashcard',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              )
            : (_showCreateFlashcard)
            ? Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _showCreateFlashcard = false;
                      });
                    },
                  ),
                  const Text(
                    'Create Flashcard',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              )
            : (_selectedSubject != null)
            ? Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: _unselectSubject,
                  ),
                  Text(
                    _selectedSubject!['title'] ?? 'Subject',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              )
            : (currentPageIndex == 3 && (_showEditAccount || _showSettings))
            ? Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _showEditAccount = false;
                        _showSettings = false;
                      });
                    },
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _showEditAccount ? 'Edit account' : 'Settings',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              )
            : home_widgets.buildSearchBar(darkMode: _darkMode),
        actions:
            (_selectedSubject != null &&
                !_showCreateFlashcard &&
                _flashcardToEdit == null)
            ? [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _showCreateFlashcard = true;
                    });
                  },
                ),
              ]
            : null,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: _darkMode
            ? NavigationBarThemeData(
                // Dark Mode Theme
                backgroundColor: const Color(0xFF1E1E1E),
                indicatorColor: const Color.fromARGB(255, 45, 106, 79),
                labelTextStyle: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    );
                  }
                  return TextStyle(color: Colors.grey[400]);
                }),
                iconTheme: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return const IconThemeData(
                      size: iconSize,
                      color: Colors.white,
                    );
                  }
                  return IconThemeData(size: iconSize, color: Colors.grey[400]);
                }),
              )
            : NavigationBarThemeData(
                // Light Mode Theme
                backgroundColor: Colors.white,
                indicatorColor: Colors.green[100],
                labelTextStyle: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    );
                  }
                  return TextStyle(color: Colors.grey[600]);
                }),
                iconTheme: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return const IconThemeData(
                      size: iconSize,
                      color: Color.fromARGB(255, 45, 106, 79),
                    );
                  }
                  return IconThemeData(size: iconSize, color: Colors.grey[600]);
                }),
              ),
        child: NavigationBar(
          height: 80,
          selectedIndex: currentPageIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedSubject = null;
              _showCreateFlashcard = false;
              _flashcardToEdit = null;
              currentPageIndex = index;
              if (index != 3) {
                _showEditAccount = false;
                _showSettings = false;
              }
            });
          },
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.add_circle),
              icon: Icon(Icons.add_circle_outline),
              label: 'Add card set',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.library_books),
              icon: Icon(Icons.library_books_outlined),
              label: 'Library',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.menu_open),
              icon: Icon(Icons.menu),
              label: 'Menu',
            ),
          ],
        ),
      ),
      body: body,
    );
  }
}
