import 'package:flutter/material.dart';
import './home_page.dart';
import '../../profile/presentation/profile_page.dart';
import '../../bookings/presentation/bookings_page.dart';
import '../../notifications/presentation/notifications_page.dart';
import '../../free_exams/presentation/free_exams_page.dart';
import '../../orientations/presentation/orientations_page.dart';
import '../../privacy/presentation/privacy_policy_page.dart';
import '../../auth/auth_service.dart';
import '../../auth/presentation/login_page.dart';

enum AvailablePages { 
  home, 
  profile, 
  orientations, 
  bookings, 
  freeExams 
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {

  Widget _getPageWidget(AvailablePages tab) {
    switch (tab) {
      case AvailablePages.home:
        return const HomePage();
      case AvailablePages.freeExams:
        return const FreeExamsPage();
      case AvailablePages.orientations:
        return const OrientationsPage();
      case AvailablePages.profile:
        return const ProfilePage();
      case AvailablePages.bookings:
        return const BookingsPage();
      default:
        return const LoginPage();
    }
  }
  
  AvailablePages _selectedPageTab = AvailablePages.home;
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  
  void _openDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _openNotifications() {
    Navigator.of(context).pushNamed('/notifications');
  }

  void _openBookings() {
    Navigator.of(context).pushNamed('/bookings');
  }

  void _openFreeExams() {
    setState(() => _selectedPageTab = AvailablePages.freeExams);
  }

  void _openFreeClasses() {
    // Free Classes and Orientations are the same - navigate to orientations page
    setState(() => _selectedPageTab = AvailablePages.orientations);

  }

  void _openPrivacyPolicy() {
    Navigator.of(context).pushNamed('/privacy');
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Logging out...'),
              ],
            ),
          ),
        );
      }

      try {
        // Perform logout
        await AuthService.logout();
        
        // Navigate to login page and clear all previous routes
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      } catch (e) {
        // Close loading dialog
        if (mounted) {
          Navigator.of(context).pop();
          
          // Show error message but still navigate to login
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout completed locally. Server error: ${e.toString().replaceFirst('Exception: ', '')}'),
              backgroundColor: Colors.orange,
            ),
          );
          
          // Navigate to login page anyway
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      }
    }
  }

  Future<void> _deleteAccount() async {
    // Show confirmation dialog with stronger warning
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Deleting account...'),
              ],
            ),
          ),
        );
      }

      try {
        // Perform account deletion
        await AuthService.deleteAccount();
        
        // Close loading dialog
        if (mounted) {
          Navigator.of(context).pop();
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate to login page and clear all previous routes
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      } catch (e) {
        // Close loading dialog
        if (mounted) {
          Navigator.of(context).pop();
          
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete account: ${e.toString().replaceFirst('Exception: ', '')}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      endDrawer: _buildDrawer(context),
      body: Column(
        children: [
          _buildGlobalTopBar(),
          Expanded(child: _getPageWidget(_selectedPageTab)),
          _buildGlobalBottomBar(),
        ],
      ),
      
    );
  }

  Widget _buildGlobalTopBar() {
    return SafeArea(
      top: true,
      bottom: false,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search...',
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.notifications_none, size: 28),
              onPressed: _openNotifications,
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.menu, size: 28),
              onPressed: _openDrawer,
            ),
          ],
        ),
      ),
    );
  }

  void _onBottomMenuBarItemTapped(int index) {
    final List<AvailablePages> navLinks = [
      AvailablePages.home,
      AvailablePages.freeExams,
      AvailablePages.orientations,
      AvailablePages.profile,
    ];

    if (index >= 0 && index < navLinks.length) {
      setState(() => _selectedPageTab = navLinks[index]);
    }
  }

  Widget _buildGlobalBottomBar() {
    final navLinks = [
      AvailablePages.home,
      AvailablePages.freeExams,
      AvailablePages.orientations,
      AvailablePages.profile,
    ];

    int currentIndex = navLinks.indexOf(_selectedPageTab);
    if (currentIndex < 0) {
      // If the selected tab is not in the bottom nav bar (e.g., Bookings),
      // default to a safe index, like 0 (Home), to avoid crashing.
      currentIndex = 0;
    }

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      backgroundColor: Colors.white,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      currentIndex: currentIndex,
      onTap: _onBottomMenuBarItemTapped,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Free Exam'),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Orientations'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'You'),
      ],
    );
  
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.black12),
            child: Center(
              child: Image(
                image: AssetImage('assets/images/app-logo.png'),
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('My Profile'),
            onTap: () {
              setState(() => _selectedPageTab = AvailablePages.profile);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.class_),
            title: const Text('My Classroom'),
            onTap: () {
              setState(() => _selectedPageTab = AvailablePages.home);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('My Bookings'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedPageTab = AvailablePages.bookings);
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Free Exams'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedPageTab = AvailablePages.freeExams);
            },
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Free Classes'),
            onTap: () {
              Navigator.pop(context);
                setState(() => _selectedPageTab = AvailablePages.orientations);
              },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _logout();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _deleteAccount();
            },
          ),
        ],
      ),
    );
  }

  
}

 