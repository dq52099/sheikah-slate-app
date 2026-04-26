import 'package:flutter/material.dart';
import '../materializer/materializer_screen.dart';
import '../chronogear/chronogear_screen.dart';
import '../compendium/compendium_screen.dart';
import '../sanctuary/sanctuary_screen.dart';
import '../../core/botw_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const MaterializerScreen(),
    const ChronogearScreen(),
    const CompendiumScreen(),
    const SanctuaryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: BotwTheme.sheikahBlue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.auto_fix_high), label: '具现化'),
          BottomNavigationBarItem(icon: Icon(Icons.loop), label: '时间回溯'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: '希卡图鉴'),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: '控制台'),
        ],
      ),
    );
  }
}
