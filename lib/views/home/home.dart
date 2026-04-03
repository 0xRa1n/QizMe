import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qizme/views/widgets/home_widgets.dart';
import 'package:qizme/views/widgets/menu_widgets.dart';
import 'package:qizme/views/home/tabs/edit_account.dart';
import 'package:qizme/views/home/tabs/add_card_set.dart';
import 'package:qizme/views/home/tabs/settings.dart';

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
      _isLoading = false;
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
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            buildStreakCard(),
            const SizedBox(height: 25),
            buildCalendarSection(),
            const SizedBox(height: 35),
            const Text(
              'Mastery Dashboard',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 15),
            buildCreateSubjectCard(),
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
              const Text("Hello, "),
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          // this is tabs. since in our design, the bottom bar does not change, we need to use tabs to navigate between pages
          buildMenuButtons(
            context: context,
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
      return SettingsPage(
        onBack: (settings) {
          print('User settings choices: $settings');
          // You can now save these settings to your database
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF5D8A56)),
        ),
      );
    }

    final pages = <Widget>[
      _buildHomePage(),
      AddCardSet(),
      const Center(child: Text('Library Page')),
      _buildMenuPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(155, 5, 113, 75),
        centerTitle: true,
        automaticallyImplyLeading: false,
        title:
            (currentPageIndex == 3 &&
                (_showEditAccount ||
                    _showSettings)) // if the current page is the menu page and the edit account or settings page is shown, show the back button and the title
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
                    // if the current page is the edit account, show the title edit account, otherwise settings
                    _showEditAccount ? 'Edit account' : 'Settings',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              )
            : buildSearchBar(), // if the current page is neither the edit account page nor the settings page, show the search bar
      ),
      bottomNavigationBar: NavigationBar(
        height: 80,
        onDestinationSelected: (int index) {
          // when a destination is selected, update the current page index and hide the edit/settings pages if applicable
          setState(() {
            currentPageIndex = index;
            if (index != 3) {
              // if the selected menu in the bottom bar is not the menu button (index 3), hide the edit/settings pages
              _showEditAccount = false;
              _showSettings = false;
            }
          });
        },
        indicatorColor: Colors.green[200],
        selectedIndex: currentPageIndex,
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: IconTheme(
              data: const IconThemeData(size: iconSize),
              child: const Icon(Icons.home),
            ),
            icon: IconTheme(
              data: const IconThemeData(size: iconSize),
              child: const Icon(Icons.home_outlined),
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: IconTheme(
              data: const IconThemeData(size: iconSize),
              child: const Icon(Icons.add),
            ),
            label: 'Add card set',
          ),
          NavigationDestination(
            selectedIcon: IconTheme(
              data: const IconThemeData(size: iconSize),
              child: const Icon(Icons.library_books),
            ),
            icon: IconTheme(
              data: const IconThemeData(size: iconSize),
              child: const Icon(Icons.library_books_outlined),
            ),
            label: 'Library',
          ),
          NavigationDestination(
            icon: IconTheme(
              data: const IconThemeData(size: iconSize),
              child: const Icon(Icons.menu),
            ),
            label: 'Menu',
          ),
        ],
      ),
      body: pages[currentPageIndex],
    );
  }
}
