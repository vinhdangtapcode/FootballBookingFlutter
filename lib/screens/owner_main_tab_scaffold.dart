import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'owner_fields_screen.dart';
import 'owner_notifications_screen.dart';
import 'owner_settings_screen.dart';

class OwnerMainTabScaffold extends StatefulWidget {
  final int initialIndex;
  const OwnerMainTabScaffold({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<OwnerMainTabScaffold> createState() => _OwnerMainTabScaffoldState();
}

class _OwnerMainTabScaffoldState extends State<OwnerMainTabScaffold> {
  late int _currentIndex;
  int _unreadCount = 0;
  final List<Widget> _screens = [
    OwnerFieldsScreen(),
    OwnerNotificationsScreen(),
    OwnerSettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _fetchUnreadCount();
  }

  Future<void> _fetchUnreadCount() async {
    final notis = await ApiService.getNotifications();
    setState(() {
      _unreadCount = notis.where((n) => n['read'] == false).length;
    });
  }

  void _onTabTapped(int index) async {
    setState(() => _currentIndex = index);
    if (index == 1) {
      await _fetchUnreadCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        onTap: _onTabTapped,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.chat),
                if (_unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '$_unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Thông báo',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ],
      ),
    );
  }
}

