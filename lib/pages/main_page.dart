import 'package:flutter/material.dart';

import '../app/theme.dart';
import 'home_page.dart';
import 'placeholder_page.dart';
import 'profile_page.dart';

/// Shell หลังล็อกอิน — bottom navigation 4 แท็บ
/// (หน้าแรก / ประวัตินัด / ประวัติการวัด / ผู้ใช้งาน)
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _index = 0;

  static const _pages = <Widget>[
    HomePage(),
    PlaceholderPage(icon: Icons.history, title: 'ประวัตินัด'),
    PlaceholderPage(icon: Icons.monitor_heart_outlined, title: 'ประวัติการวัด'),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppTheme.whiteColor,
          indicatorColor: AppTheme.primaryThemeApp.withValues(alpha: 0.12),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => AppTheme.generalText(
              13,
              fonWeight: FontWeight.w600,
              color: states.contains(WidgetState.selected)
                  ? AppTheme.primaryThemeApp
                  : AppTheme.secondaryText62,
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? AppTheme.primaryThemeApp
                  : AppTheme.secondaryText62,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'หน้าแรก',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_note_outlined),
              selectedIcon: Icon(Icons.event_note),
              label: 'ประวัตินัด',
            ),
            NavigationDestination(
              icon: Icon(Icons.monitor_heart_outlined),
              selectedIcon: Icon(Icons.monitor_heart),
              label: 'ประวัติการวัด',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'ผู้ใช้งาน',
            ),
          ],
        ),
      ),
    );
  }
}
