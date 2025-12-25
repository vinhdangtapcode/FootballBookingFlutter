import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'booking_history_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';
import '../services/api_service.dart';
import '../main.dart'; // Import để sử dụng routeObserver

class MainTabScaffold extends StatefulWidget {
  final int initialIndex;
  const MainTabScaffold({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainTabScaffold> createState() => _MainTabScaffoldState();
}

class _MainTabScaffoldState extends State<MainTabScaffold> with WidgetsBindingObserver, RouteAware {
  late int _currentIndex;
  int _newNotificationCount = 0;
  List<int> _seenNotificationIds = [];
  final List<Widget> _screens = [
    HomeScreen(),
    BookingHistoryScreen(),
    NotificationsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addObserver(this);
    _loadSeenNotifications();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Đăng ký với RouteObserver
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Được gọi khi một route được pop và màn hình này trở nên visible lại
  @override
  void didPopNext() {
    super.didPopNext();
    // Refresh notification count khi back từ màn hình khác
    _fetchNewNotificationCount();
  }

  // Khi app quay lại foreground, refresh notification count
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchNewNotificationCount();
    }
  }

  // Load danh sách ID thông báo đã xem từ SharedPreferences
  Future<void> _loadSeenNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final seenIds = prefs.getStringList('seen_notification_ids') ?? [];
    _seenNotificationIds = seenIds.map((id) => int.parse(id)).toList();
    await _fetchNewNotificationCount();
  }

  // Lưu danh sách ID thông báo đã xem vào SharedPreferences
  Future<void> _saveSeenNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'seen_notification_ids',
      _seenNotificationIds.map((id) => id.toString()).toList(),
    );
  }

  // Đếm số thông báo MỚI (chưa có trong danh sách đã xem)
  Future<void> _fetchNewNotificationCount() async {
    final notis = await ApiService.getNotifications();
    final newCount = notis.where((n) {
      final id = n['id'];
      return id != null && !_seenNotificationIds.contains(id);
    }).length;
    
    if (mounted) {
      setState(() {
        _newNotificationCount = newCount;
      });
    }
  }

  // Đánh dấu tất cả thông báo hiện tại là "đã xem"
  Future<void> _markAllAsSeen() async {
    final notis = await ApiService.getNotifications();
    for (var n in notis) {
      final id = n['id'];
      if (id != null && !_seenNotificationIds.contains(id)) {
        _seenNotificationIds.add(id);
      }
    }
    await _saveSeenNotifications();
    if (mounted) {
      setState(() {
        _newNotificationCount = 0;
      });
    }
  }

  void _onTabTapped(int index) async {
    if (index == _currentIndex) {
      // Nếu đang ở tab hiện tại, refresh notification count
      await _fetchNewNotificationCount();
      return;
    }
    setState(() => _currentIndex = index);
    // Khi click vào tab thông báo, đánh dấu tất cả là đã xem
    if (index == 2) {
      await _markAllAsSeen();
    } else {
      // Refresh notification count khi chuyển tab khác
      await _fetchNewNotificationCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyedSubtree(
        key: ValueKey(_currentIndex),
        child: _screens[_currentIndex],
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
          const BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Lịch sử đặt'),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.chat),
                if (_newNotificationCount > 0)
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
                        '$_newNotificationCount',
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
