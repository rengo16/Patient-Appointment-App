
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patientappointment/core/providers/auth_provider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        _nameController.text = authProvider.currentUser?.name ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final authProviderInstance = Provider.of<AuthProvider>(context, listen: false);

    final confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                print("ACCOUNT_SCREEN: Dialog 'Cancel' button PRESSED.");
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                print("ACCOUNT_SCREEN: Dialog 'Logout' button PRESSED.");
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      print("ACCOUNT_SCREEN: Logout confirmed by dialog.");
      print("ACCOUNT_SCREEN: Calling AuthProvider logout().");
      await authProviderInstance.logout();
      print("ACCOUNT_SCREEN: AuthProvider logout() call completed.");

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {


          if (mounted) {
            print("ACCOUNT_SCREEN: (PostFrame) Attempting to navigate to /login and remove until.");
            try {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                    (Route<dynamic> route) => false,
              );
              print("ACCOUNT_SCREEN: (PostFrame) pushNamedAndRemoveUntil EXECUTED.");
            } catch (e) {
              print("ACCOUNT_SCREEN: (PostFrame) ERROR during pushNamedAndRemoveUntil: $e");
            }
          } else {
            print("ACCOUNT_SCREEN: (PostFrame) Widget was unmounted before navigation could occur inside PostFrameCallback.");
          }
        });
      } else {
        print("ACCOUNT_SCREEN: Widget unmounted before addPostFrameCallback could be scheduled (logout initiated from an already unmounted widget - unusual).");
      }
    } else {
      print("ACCOUNT_SCREEN: Logout cancelled or dialog dismissed.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      print("ACCOUNT_SCREEN: User is NULL, showing 'Logging out...' UI (or similar).");
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Logging out..."),
            ],
          ),
        ),
      );
    }
    print("ACCOUNT_SCREEN: Build method called. User is NOT NULL: ${user.name}");
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: TextStyle(fontSize: 40, color: Theme.of(context).colorScheme.onPrimaryContainer),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: _isEditing
                  ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20),
                ),
              )
                  : Text(
                user.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                user.phone,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            if (!user.isAdmin)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SwitchListTile(
                  title: const Text('Enable Admin Mode'),
                  value: user.isAdmin,
                  onChanged: (value) {
                    Provider.of<AuthProvider>(context, listen: false).toggleAdminMode();
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ),


            const Spacer(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 16)
                ),
                onPressed: () {
                  final authProviderInstance = Provider.of<AuthProvider>(context, listen: false);
                  if (_isEditing) {
                    if (authProviderInstance.currentUser != null) {
                      authProviderInstance.updateProfile(_nameController.text);
                    }
                  }
                  setState(() {
                    _isEditing = !_isEditing;
                    if (_isEditing && authProviderInstance.currentUser != null) {
                      _nameController.text = authProviderInstance.currentUser!.name;
                    }
                  });
                },
                child: Text(_isEditing ? 'Save Changes' : 'Edit Profile'),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: TextButton(
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.withOpacity(0.5))
                ),
                onPressed: _handleLogout,
                child: const Text('Logout'),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
