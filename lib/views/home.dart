import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/login.dart';

class QizMe extends StatefulWidget {
  const QizMe({super.key});

  @override
  State<QizMe> createState() => _QizMeState();
}

class _QizMeState extends State<QizMe> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text("Search bar 2"),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(21, 23, 25, 100),
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
        const Center(child: Text('Home Page')),
        const Center(child: Text('Add Card Set Page')),
        const Center(child: Text('Library Page')),
        Center(
          child: OutlinedButton(
            child: Text(
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
