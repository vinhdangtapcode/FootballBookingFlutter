import 'package:flutter/material.dart';
import 'package:football_booking_flutter/screens/main_tab_scaffold.dart';
import 'package:football_booking_flutter/screens/owner_edit_profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/field_detail_screen.dart';
import 'screens/booking_history_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/rating_screen.dart';
import 'screens/add_rating_screen.dart';
import 'screens/owner_fields_screen.dart';
import 'screens/add_edit_field_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/field_booking_history_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/owner_main_tab_scaffold.dart';
import 'screens/owner_notifications_screen.dart';

void main() {
  runApp(FootballBookingApp());
}

class FootballBookingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Football Booking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => MainTabScaffold(),
        '/fieldDetail': (context) => FieldDetailScreen(),
        '/bookingHistory': (context) => MainTabScaffold(initialIndex: 1),
        '/booking': (context) => BookingScreen(),
        '/favorites': (context) => FavoritesScreen(),
        '/ratings': (context) => RatingScreen(),
        '/addRating': (context) => AddRatingScreen(),
        '/ownerFields': (context) => OwnerFieldsScreen(),
        '/addEditField': (context) => AddEditFieldScreen(),
        '/profile': (context) => ProfileScreen(),
        '/fieldBookingHistory': (context) => FieldBookingHistoryScreen(),
        '/notifications': (context) => MainTabScaffold(initialIndex: 2),
        '/settings': (context) => MainTabScaffold(initialIndex: 3),
        '/ownerMain': (context) => OwnerMainTabScaffold(),
        '/ownerNotifications': (context) => OwnerMainTabScaffold(initialIndex: 1),
        '/ownerSettings': (context) => OwnerMainTabScaffold(initialIndex: 2),
        '/ownerEditProfile': (context) => OwnerEditProfileScreen(),
      },
    );
  }
}
