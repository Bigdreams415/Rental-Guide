import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/guest_profile.dart';
import '../widgets/authenticated_profile.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfileData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<ProfileProvider>().refreshProfile(),
          color: const Color(0xFF0066B2),
          child: Consumer<ProfileProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(
                  child: LoadingIndicator(),
                );
              }

              if (provider.errorMessage != null) {
                return Center(
                  child: CustomErrorWidget(
                    message: provider.errorMessage!,
                    onRetry: () => provider.refreshProfile(),
                  ),
                );
              }

              if (!provider.isAuthenticated) {
                return SingleChildScrollView(
                  child: GuestProfile(
                    onLoginTap: () => _navigateToLogin(context),
                    onRegisterTap: () => _navigateToRegister(context),
                  ),
                );
              }

              return SingleChildScrollView(
                child: AuthenticatedProfile(
                  user: provider.currentUser!,
                  properties: provider.userProperties,
                  totalViews: provider.totalViews,
                  favoritesCount: provider.favoritesCount,
                  onEditProfile: () => _navigateToEditProfile(context),
                  onLogout: () => _showLogoutDialog(context, provider),
                  onMenuItemTap: (value) => _handleMenuItemTap(context, value),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pushNamed(context, '/login');
  }

  void _navigateToRegister(BuildContext context) {
    Navigator.pushNamed(context, '/register');
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.pushNamed(context, '/edit-profile');
  }

  void _handleMenuItemTap(BuildContext context, String value) {
    switch (value) {
      case 'favorites':
        Navigator.pushNamed(context, '/favorites');
        break;
      case 'transactions':
        Navigator.pushNamed(context, '/transactions');
        break;
      case 'notifications':
        Navigator.pushNamed(context, '/notifications');
        break;
      case 'privacy':
        Navigator.pushNamed(context, '/privacy');
        break;
      case 'support':
        Navigator.pushNamed(context, '/support');
        break;
      case 'my_properties':
        Navigator.pushNamed(context, '/my-properties');
        break;
    }
  }

  Future<void> _showLogoutDialog(BuildContext context, ProfileProvider provider) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                provider.logout();
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}