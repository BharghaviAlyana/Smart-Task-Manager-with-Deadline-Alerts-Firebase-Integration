// settings_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_lab_project/shared_widget.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this package to pubspec.yaml

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SharedScaffold(
      currentRoute: 'settings',
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text(
                'Profile',
                style: TextStyle(fontSize: 16),
              ),
              onTap: () {
                // Handle profile tap
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text(
                'Notifications',
                style: TextStyle(fontSize: 16),
              ),
              trailing: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 30,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: _notificationsEnabled 
                      ? const Color(0xFF6C63FF) 
                      : Colors.grey[300],
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                      top: 3,
                      left: _notificationsEnabled ? 22 : 2,
                      right: _notificationsEnabled ? 2 : 22,
                      child: GestureDetector(
                        onTap: () => _toggleNotifications(!_notificationsEnabled),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text(
                'Theme',
                style: TextStyle(fontSize: 16),
              ),
              onTap: () {
                // Handle theme tap
              },
            ),
            const Divider(height: 0),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                // Navigate to login screen
              },
            ),
          ],
        ),
      ),
    );
  }
}