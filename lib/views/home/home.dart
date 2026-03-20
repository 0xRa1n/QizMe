import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qizme/views/home/widgets/home_widgets.dart';
import 'package:qizme/views/home/widgets/menu_widgets.dart';
import 'package:qizme/views/home/tabs/edit_account.dart';
import 'package:qizme/utils/http.dart';
import 'package:qizme/constants.dart';

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

  Widget _buildMenuOption({
    required BuildContext context,
    required String name,
    required String profilePicture,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 65),
      child: Column(
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(profilePicture),
              ),
              SizedBox(height: 16),
            ],
          ),

          Center(
            child: Row(
              children: [
                Text("Hello, "),
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          buildMenuButtons(
            context: context,
            onAccountTap: () {
              setState(() {
                _showEditAccount = true;
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

  @override
  Widget build(BuildContext context) {
    final name = _prefs?.getString('name') ?? 'None';
    final profilePicture = _prefs?.getString('profilePicture') ?? '';

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF5D8A56)),
        ),
      );
    }

    final pages = <Widget>[
      _buildHomePage(),
      const Center(child: Text('Add Card Set Page')),
      const Center(child: Text('Library Page')),
      _showEditAccount
          ? EditAccountPage(
              onBack: () {
                setState(() {
                  _showEditAccount = false;
                });
              },
            )
          : _buildMenuOption(
              context: context,
              name: name,
              profilePicture: profilePicture,
            ),
    ];

    return Scaffold(
      // hide search AppBar when in Edit Account (to match figma top section)
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(155, 5, 113, 75),
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: (currentPageIndex == 3 && _showEditAccount)
            ? Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      setState(() {
                        _showEditAccount = false;
                      });
                    },
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Edit account',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              )
            : buildSearchBar(),
      ),
      bottomNavigationBar: NavigationBar(
        height: 80,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
            // reset edit state if user leaves menu tab
            if (index != 3) _showEditAccount = false;
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
