import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QizMe extends StatefulWidget {
  const QizMe({super.key});

  @override
  State<QizMe> createState() => _QizMeState();
}

class _QizMeState extends State<QizMe> {
  int currentPageIndex = 0;

  // 1. Declare a nullable SharedPreferences variable and a loading flag
  SharedPreferences? _prefs;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 2. Trigger the initialization process
    _initializePreferences();
  }

  // 3. Handle the asynchronous work outside the build method
  Future<void> _initializePreferences() async {
    // Use the standard SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();

    // Update the state to rebuild the UI cleanly
    setState(() {
      _prefs = prefs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 4. Handle the loading state at the root level of the build method
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF5D8A56)),
        ),
      );
    }

    // 5. Return the flat, readable Scaffold once loading is complete
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text("Search bar 2"),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(21, 23, 25, 100),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: const Color.fromARGB(255, 238, 191, 191),
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(icon: Icon(Icons.add), label: 'Add card set'),
          NavigationDestination(
            icon: Icon(Icons.library_books),
            label: 'Library',
          ),
          NavigationDestination(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),
      body: <Widget>[
        // Here you can now easily read from _prefs synchronously
        Center(child: Text('Welcome ${_prefs?.getString('name') ?? "None"}')),
        const Center(child: Text('Add Card Set Page')),
        const Center(child: Text('Library Page')),
        Center(
          child: OutlinedButton(
            child: const Text(
              'Logout',
              style: TextStyle(fontSize: 18.0, color: Colors.black),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
              );
            },
          ),
        ),
      ][currentPageIndex],
    );
  }
}
