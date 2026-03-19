import 'package:flutter/material.dart';
import 'package:qizme/views/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qizme/views/home/widgets/home_widgets.dart';

class QizMe extends StatefulWidget {
  const QizMe({super.key});

  @override
  State<QizMe> createState() => _QizMeState();
}

class _QizMeState extends State<QizMe> {
  int currentPageIndex = 0;
  SharedPreferences? _prefs;
  bool _isLoading = true;

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

  @override
  Widget build(BuildContext context) {
    final name = _prefs?.getString('name') ?? 'None';

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
      Center(
        // fourth page
        child: Container(
          margin: EdgeInsets.only(top: 65),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/user.png'),
              ),
              const SizedBox(height: 16),
              Text('Hello $name'),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.grey[200],
                    ),
                    child: const Text(
                      "Account",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.grey[200],
                    ),
                    child: const Text(
                      "Settings",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      if (!mounted) return;

                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => Login()),
                        (route) => false, // Removes all previous routes
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.red[200],
                    ),
                    child: const Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: buildSearchBar(),
        centerTitle: true,
        backgroundColor: Color.fromARGB(155, 5, 113, 75),
      ),
      bottomNavigationBar: NavigationBar(
        height: 80,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.green[200],
        selectedIndex: currentPageIndex,
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: IconTheme(
              data: IconThemeData(size: iconSize),
              child: Icon(Icons.home),
            ),
            icon: IconTheme(
              data: IconThemeData(size: iconSize),
              child: Icon(Icons.home_outlined),
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: IconTheme(
              data: IconThemeData(size: iconSize),
              child: Icon(Icons.add),
            ),
            label: 'Add card set',
          ),
          NavigationDestination(
            selectedIcon: IconTheme(
              data: IconThemeData(size: iconSize),
              child: Icon(Icons.library_books),
            ),
            icon: IconTheme(
              data: IconThemeData(size: iconSize),
              child: Icon(Icons.library_books_outlined),
            ),
            label: 'Library',
          ),
          NavigationDestination(
            icon: IconTheme(
              data: IconThemeData(size: iconSize),
              child: Icon(Icons.menu),
            ),
            label: 'Menu',
          ),
        ],
      ),
      body: pages[currentPageIndex],
    );
  }
}
