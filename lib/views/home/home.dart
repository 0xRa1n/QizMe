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

  final AuthRepository _authRepository =
      AuthRepository(); // since the Auth Repository is a class, we have to instantiate it

  static const double iconSize = 31;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
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
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _prefs = prefs;
    });
  }

  Widget _buildHomePage() {
    // Pass the _darkMode boolean down to the home page widgets.
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            // Use the prefix to call the functions from home_widgets.dart
            home_widgets.buildStreakCard(darkMode: _darkMode),
            const SizedBox(height: 25),
            home_widgets.buildCalendarSection(darkMode: _darkMode),
            const SizedBox(height: 35),
            home_widgets.buildCreateSubjectCard(
              onAddCardSet: () => changeTab(1),
              darkMode: _darkMode,
              onSubjectTap: _selectSubject,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<String?> getEmailFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  List<Map<String, dynamic>> _getSampleCardSets() {
    return [
      {'title': 'Sample Set: Flutter Basics', 'progress': 25, 'flashcards': []},
      {
        'title': 'Sample Set: Dart Programming',
        'progress': 75,
        'flashcards': [],
      },
    ];
  }

  Widget _buildLibraryPage() {
    final emailFuture = getEmailFromPreferences();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            const Text(
              'Library',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),
            FutureBuilder<String?>(
              future: emailFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error fetching user data: ${snapshot.error}');
                } else {
                  return FutureBuilder<Map<String, dynamic>>(
                    future: CardService.getCardSet(email: snapshot.data ?? ""),
                    builder: (context, cardSnapshot) {
                      if (cardSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (cardSnapshot.hasError) {
                        return Text(
                          'Error loading card sets: ${cardSnapshot.error}',
                        );
                      } else {
                        final cards = cardSnapshot.data?['raw'] as List? ?? [];

                        // Add sample data if no cards exist
                        final displayCards = cards.isEmpty
                            ? _getSampleCardSets()
                            : cards;

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: displayCards.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final card = displayCards[index];
                            return InkWell(
                              onTap: () =>
                                  _selectSubject(card as Map<String, dynamic>),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.black54,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header row with title and kebab menu
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            card['title'] ?? 'No Title',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          onSelected: (value) {
                                            if (value == 'edit_name') {
                                              setState(() {
                                                _showEditCardSetName = true;
                                                _editingCardSet = card;
                                              });
                                            } else if (value ==
                                                'edit_flashcards') {
                                              setState(() {
                                                _showEditFlashcard = true;
                                                _editingCardSet = card;
                                                _editingFlashcards =
                                                    List<
                                                      Map<String, dynamic>
                                                    >.from(
                                                      card['flashcards'] ?? [],
                                                    );
                                                if (_editingFlashcards
                                                    .isEmpty) {
                                                  _editingFlashcards.add({
                                                    'question': '',
                                                    'answer': '',
                                                  });
                                                }
                                                _currentFlashcardIndex = 0;
                                              });
                                            }
                                          },
                                          itemBuilder: (BuildContext context) =>
                                              [
                                                const PopupMenuItem<String>(
                                                  value: 'edit_name',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.edit,
                                                        size: 20,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        'Edit Card Set Name',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem<String>(
                                                  value: 'edit_flashcards',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.library_books,
                                                        size: 20,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text('Edit Flashcards'),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                          icon: const Icon(
                                            Icons.more_horiz,
                                          ), // Horizontal kebab menu
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Progress percentage text
                                    Text(
                                      '${card['progress'] ?? 0}% Completed',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Progress bar
                                    Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[400],
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 1,
                                        ),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor:
                                            (card['progress'] ?? 0) / 100.0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                                (card['progress'] ?? 0) == 100
                                                ? Colors
                                                      .amber[600] // Gold color for 100%
                                                : Colors
                                                      .green, // Green for in progress
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  );
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
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
