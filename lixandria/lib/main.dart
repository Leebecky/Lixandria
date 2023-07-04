/*
Programmer Name: Ms Rebecca Lee Hui Yi, APD3F2211CS(IS)
Program Name: main.dart
Description: Main thread from which the application is launched. Contains configuration for app theme colour and bottom navigation bar. 
First Written On: 02/06/2023
Last Edited On:  12/06/2023
 */

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:lixandria/models/shelf.dart';
import 'package:lixandria/pages/settings/settings.dart';
import 'package:lixandria/pages/statistics/statistics_main.dart';
import 'package:realm/realm.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/book.dart';
import 'models/tag.dart';
import 'pages/add/add_catalogue.dart';
import 'pages/home.dart';

// List<CameraDescription>? cameras;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final config = Configuration.local([Shelf.schema, Tag.schema, Book.schema],
        initialDataCallback: populateInitialDb);
    final realm = Realm(config);

    if (!realm.isClosed) {
      realm.close();
    }

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Lixandria',
        theme: ThemeData(
          fontFamily: GoogleFonts.karla().fontFamily,
          scaffoldBackgroundColor: const Color(0xffE5D9B6),
          primaryColor: const Color(0xff5F8D4E),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const AppScaffold());
  }
}

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _selectedIndex = 1;

  static const List<Widget> _appPages = <Widget>[
    Statistics(),
    Home(),
    Settings()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lixandria", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff285430),
      ),
      body: Center(
        child: _appPages.elementAt(_selectedIndex),
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              shape: const CircleBorder(),
              child: const Icon(Icons.add_rounded),
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddCatalogue()))
              // ScaffoldMessenger.of(context).showSnackBar(
              //     const SnackBar(content: Text("Welcome to Lixandria")));
              )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xffA4BE7B),
        onTap: _onItemTapped,
        backgroundColor: const Color(0xff285430),
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.white,
      ),
    );
  }
}

void populateInitialDb(Realm realm) {
  realm.add(Shelf(ObjectId().toString(), shelfName: "Shelf 1"));
  realm.add(Tag(ObjectId().toString(), tagDesc: "Romance"));
  realm.add(Tag(ObjectId().toString(), tagDesc: "Horror"));
  realm.add(Tag(ObjectId().toString(), tagDesc: "Fantasy"));
  realm.add(Tag(ObjectId().toString(), tagDesc: "Thriller"));
  realm.add(Tag(ObjectId().toString(), tagDesc: "Mystery"));
}
