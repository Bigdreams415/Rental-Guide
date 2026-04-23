import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/home/screens/home_screen.dart';
import 'features/home/providers/home_provider.dart';
import 'features/property_detail/screens/property_detail_screen.dart';
import 'features/property_detail/providers/property_detail_provider.dart';
import 'features/search/screens/search_screen.dart';
import 'features/search/providers/search_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/chat/screens/inbox_screen.dart';
import 'features/chat/providers/chat_provider.dart';
import 'constants/colors.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/post_property/screens/post_property_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kxpdtcyauwfjfxerzxgq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt4cGR0Y3lhdXdmamZ4ZXJ6eGdxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY5Mzg4NjEsImV4cCI6MjA5MjUxNDg2MX0.QM6nKTqIXqslnwHWd3XITCkEGGaWDDF-DWOhQIXK2kM',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => PropertyDetailProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'Direct Property',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: const MainScaffold(),
        onGenerateRoute: (settings) {
          if (settings.name == '/property-detail') {
            final propertyId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) =>
                  PropertyDetailScreen(propertyId: propertyId),
            );
          }
          if (settings.name == '/login') {
            return MaterialPageRoute(
                builder: (context) => const LoginScreen());
          }
          if (settings.name == '/register') {
            return MaterialPageRoute(
                builder: (context) => const RegisterScreen());
          }
          return null;
        },
      ),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    SearchScreen(),
    PostPropertyScreen(),
    InboxScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle), label: 'Post'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}