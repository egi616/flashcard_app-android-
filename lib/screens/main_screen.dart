import 'package:flutter/material.dart';

import '../theme/app_color.dart';
import 'deck_list_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [DeckListScreen(), ScreenProfile()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColor.surface,
          border: Border(top: BorderSide(color: AppColor.secondary)),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            height: 72,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            destinations: [
              _navigationDestination(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_outlined,
                label: 'Beranda',
              ),
              _navigationDestination(
                icon: Icons.person_outline,
                selectedIcon: Icons.person_outline,
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  NavigationDestination _navigationDestination({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    return NavigationDestination(
      icon: Icon(icon),
      selectedIcon: Icon(selectedIcon),
      label: label,
    );
  }
}
