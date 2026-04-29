import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../providers/profile_provider.dart';
import '../../inspections/screens/my_inspections_screen.dart';
import '../../favorites/screens/favorites_screen.dart';
import '../../listings/screens/my_listings_screen.dart';
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
                return const Center(child: LoadingIndicator());
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
                  onDeleteAccount: () =>
                      _showDeleteAccountDialog(context, provider),
                  onListingsTap: () => _navigateToMyListings(context, provider),
                  onTotalViewsTap: () => _showTotalViewsInfo(context),
                  onFavoritesTap: () => _navigateToFavorites(context, provider),
                  onMenuItemTap: (value) =>
                      _handleMenuItemTap(context, value),
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

  Future<void> _navigateToMyListings(
      BuildContext context, ProfileProvider provider) async {
    final user = provider.currentUser;
    if (user != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MyListingsScreen(userId: user.id),
        ),
      );
      provider.refreshProfile();
    }
  }

  Future<void> _navigateToFavorites(
      BuildContext context, ProfileProvider provider) async {
    final user = provider.currentUser;
    if (user != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FavoritesScreen(userId: user.id),
        ),
      );
      provider.refreshFavoritesCount();
    }
  }

  void _showTotalViewsInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Iconsax.eye, color: Color(0xFF0066B2), size: 24),
            SizedBox(width: 10),
            Text('Total Views'),
          ],
        ),
        content: const Text(
          'Total views across all your listed properties. '
          'Each view means someone interacted with your listing.',
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMenuItemTap(BuildContext context, String value) async {
    final profileProvider = context.read<ProfileProvider>();
    final user = profileProvider.currentUser;

    switch (value) {
      case 'favorites':
        if (user != null) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FavoritesScreen(userId: user.id),
            ),
          );
          profileProvider.refreshFavoritesCount();
        }
        break;
      case 'inspections':
        if (user != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MyInspectionsScreen(currentUserId: user.id),
            ),
          );
        }
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
        if (user != null) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MyListingsScreen(userId: user.id),
            ),
          );
          profileProvider.refreshProfile();
        }
        break;
    }
  }

  Future<void> _showLogoutDialog(
    BuildContext context,
    ProfileProvider provider,
  ) async {
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
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteAccountDialog(
    BuildContext context,
    ProfileProvider provider,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Iconsax.warning_2, color: Colors.red, size: 24),
              SizedBox(width: 10),
              Text('Delete Account'),
            ],
          ),
          content: const Text(
            'This feature is not available yet. '
            'Account deletion will be available in a future update.',
            style: TextStyle(fontSize: 15, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
