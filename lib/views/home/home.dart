import 'package:flutter/material.dart';
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
    String userName = _prefs?.getString('name') ?? "None";
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
        // this is automatically sorted, no need to do anything
        // just follow the order of the pages, and it will be displayed in the correct order
        // make sure to use column or row
        Center(child: Text('Welcome $userName')), // first page
        const Center(child: Text('Add Card Set Page')), // second page
        const Center(child: Text('Library Page')), // third page
        Center(
          // fourth page
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/user.png'),
              ),
              SizedBox(height: 16),

              Text('Hello $userName'),

              SizedBox(height: 16),

              Padding(
                padding: const EdgeInsetsGeometry.symmetric(horizontal: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      alignment:
                          Alignment.centerLeft, // Aligns text to the left
                      padding: const EdgeInsets.all(
                        16.0,
                      ), // Padding inside the button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // Rounded corners
                      ),
                      backgroundColor: Colors
                          .grey[200], // Optional: Light grey background like image
                    ),
                    child: const Text(
                      "Account",
                      style: TextStyle(
                        color: Colors.black, // Dark text
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ][currentPageIndex],
    );
  }
}
