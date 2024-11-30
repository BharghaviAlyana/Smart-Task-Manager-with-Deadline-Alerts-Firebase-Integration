// shared_scaffold.dart
import 'package:flutter/material.dart';
import 'package:flutter_lab_project/calendar_screen.dart';
import 'package:flutter_lab_project/edit_task_screen.dart';
import 'package:flutter_lab_project/homepage.dart';
import 'package:flutter_lab_project/settings_screen.dart';

class SharedScaffold extends StatefulWidget {
  final Widget body;
  final String currentRoute;
  final bool showFloatingButton;
  final Widget? floatingActionButton;

  const SharedScaffold({
    Key? key,
    required this.body,
    required this.currentRoute,
    this.showFloatingButton = false,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  State<SharedScaffold> createState() => _SharedScaffoldState();
}

class _SharedScaffoldState extends State<SharedScaffold> {
  void _navigateToPage(BuildContext context, String route) {
    if (route != widget.currentRoute) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          switch (route) {
            case 'tasks':
              return const MyHomePage();
            case 'calendar':
              return const CalendarScreen();
            case 'settings':
              return const SettingsScreen();
            default:
              return const MyHomePage();
          }
        }),
      );
    }
  }

 @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: widget.body,
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, 'tasks', Icons.list_alt, 'Tasks'),
                _buildNavItem(context, 'calendar', Icons.calendar_today, 'Calendar'),
                _buildNavItem(context, 'settings', Icons.settings, 'Settings'),
              ],
            ),
          ),
        ),
        Positioned(
          right: 20,
          bottom: 90, // Adjust this value to position above bottom nav
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditTaskScreen()),
              );
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToPage(context, 'add'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF6C63FF),
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
  Widget _buildNavItem(BuildContext context, String route, IconData icon, String label) {
    final isSelected = widget.currentRoute == route;
    return GestureDetector(
      onTap: () => _navigateToPage(context, route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C63FF).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF6C63FF) : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF6C63FF) : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}