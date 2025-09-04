
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patientappointment/core/providers/auth_provider.dart';
import 'package:patientappointment/presentation/screens/upcoming_appointments_screen.dart';
import 'package:patientappointment/presentation/screens/missed_appointments_screen.dart';
import 'package:patientappointment/presentation/screens/completed_appointments_screen.dart';
import 'package:patientappointment/presentation/screens/search_doctors_screen.dart';
import 'package:patientappointment/presentation/screens/account_screen.dart';
import 'package:patientappointment/presentation/screens/doctor_admin_screen.dart';

class HomeTabsScreen extends StatefulWidget {
  const HomeTabsScreen({super.key});

  @override
  State<HomeTabsScreen> createState() => _HomeTabsScreenState();
}

class _HomeTabsScreenState extends State<HomeTabsScreen> {
  int _selectedIndex = 0;
  bool? _previousIsAdminState;

  final List<Widget> _patientScreens = [
    const UpcomingAppointmentsScreen(),
    const MissedAppointmentsScreen(),
    const CompletedAppointmentsScreen(),
    const SearchDoctorsScreen(),
    const AccountScreen(),
  ];

  final List<String> _patientTitles = [
    'Upcoming',
    'Missed',
    'Completed',
    'Search',
    'Account',
  ];

  final List<BottomNavigationBarItem> _patientNavigationBarItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today),
      label: 'Upcoming',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.warning_amber_rounded),
      label: 'Missed',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.check_circle_outline),
      label: 'Completed',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: 'Search',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      label: 'Account',
    ),
  ];
  final List<Widget> _adminScreens = [
    const DoctorAdminScreen(),
    const AccountScreen(),
  ];

  final List<String> _adminTitles = [
    'Admin Dashboard',
    'Account',
  ];

  final List<BottomNavigationBarItem> _adminNavigationBarItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard_customize_outlined),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.manage_accounts_outlined),
      label: 'Account',
    ),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _previousIsAdminState = Provider.of<AuthProvider>(context, listen: false).currentUser?.isAdmin ?? false;
      }
    });
  }

  void _onItemTapped(int index, List<Widget> activeScreens) {
    if (index >= 0 && index < activeScreens.length) {
      setState(() {
        _selectedIndex = index;
      });
    } else {
      print("HomeTabsScreen: Invalid tap index $index for current mode. Active screen count: ${activeScreens.length}");
    }
  }
  Future<void> _handleAppBarLogout(BuildContext scaffoldContext) async {
    final authProviderInstance = Provider.of<AuthProvider>(scaffoldContext, listen: false);

    final confirmLogout = await showDialog<bool>(
      context: scaffoldContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      print("HOME_TABS_SCREEN (AppBar): Logout confirmed.");
      await authProviderInstance.logout();
      print("HOME_TABS_SCREEN (AppBar): AuthProvider logout() call completed.");

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            print("HOME_TABS_SCREEN (AppBar PostFrame): Attempting to navigate to /login.");
            try {
              Navigator.of(scaffoldContext).pushNamedAndRemoveUntil(
                '/login',
                    (Route<dynamic> route) => false,
              );
              print("HOME_TABS_SCREEN (AppBar PostFrame): pushNamedAndRemoveUntil EXECUTED.");
            } catch (e) {
              print("HOME_TABS_SCREEN (AppBar PostFrame): ERROR during navigation: $e");
            }
          } else {
            print("HOME_TABS_SCREEN (AppBar PostFrame): Widget unmounted before navigation.");
          }
        });
      } else {
        print("HOME_TABS_SCREEN (AppBar): HomeTabsScreen unmounted before addPostFrameCallback for logout navigation.");
      }
    } else {
      print("HOME_TABS_SCREEN (AppBar): Logout cancelled.");
    }
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool currentIsAdmin = authProvider.currentUser?.isAdmin ?? false;

    if (_previousIsAdminState != null && _previousIsAdminState != currentIsAdmin) {
      print("HomeTabsScreen: isAdmin changed from $_previousIsAdminState to $currentIsAdmin. Resetting _selectedIndex to 0.");
      _selectedIndex = 0;
    }
    _previousIsAdminState = currentIsAdmin;

    final List<Widget> activeScreens = currentIsAdmin ? _adminScreens : _patientScreens;
    final List<String> activeTitles = currentIsAdmin ? _adminTitles : _patientTitles;
    final List<BottomNavigationBarItem> activeNavigationBarItems =
    currentIsAdmin ? _adminNavigationBarItems : _patientNavigationBarItems;
    if (_selectedIndex >= activeScreens.length) {
      print("HomeTabsScreen: _selectedIndex ($_selectedIndex) was out of bounds for activeScreens length (${activeScreens.length}). Clamping to 0.");
      _selectedIndex = 0;
    }
    if (_selectedIndex >= activeTitles.length) {
      _selectedIndex = 0;
    }
    if (_selectedIndex >= activeNavigationBarItems.length) {
      _selectedIndex = 0;
    }


    print("HomeTabsScreen: Building. User: ${authProvider.currentUser?.id}, isAdmin: $currentIsAdmin, _selectedIndex: $_selectedIndex, ActiveScreens length: ${activeScreens.length}");

    if (authProvider.currentUser == null && ModalRoute.of(context)?.isCurrent == true) {
      print("HomeTabsScreen: currentUser is null, but screen is current. Showing loading. Navigation should occur soon.");
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Logging out..."),
            ],
          ),
        ),
      );
    }


    return Scaffold(
      appBar: AppBar(
        title: Text(activeTitles.isNotEmpty && _selectedIndex < activeTitles.length
            ? activeTitles[_selectedIndex]
            : "Home"
        ),
        actions: [
          IconButton(
            icon: Icon(currentIsAdmin ? Icons.person_search_outlined : Icons.admin_panel_settings_outlined),
            tooltip: currentIsAdmin ? 'Switch to Patient Mode' : 'Switch to Admin Mode',
            onPressed: () {
              if (authProvider.currentUser != null) {
                authProvider.toggleAdminMode();
              } else {
                print("HomeTabsScreen: Cannot toggle admin mode, user is null.");
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () {
              _handleAppBarLogout(context);

            },
          )
        ],
      ),
      body: activeScreens.isNotEmpty && _selectedIndex < activeScreens.length
          ? activeScreens[_selectedIndex]
          : const Center(child: Text("Page not found or error.")),
      bottomNavigationBar: BottomNavigationBar(
        items: activeNavigationBarItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) => _onItemTapped(index, activeScreens),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

