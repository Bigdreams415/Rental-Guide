import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../constants/colors.dart';
import '../../../core/models/user.dart';
import '../../../core/models/property.dart';

class AuthenticatedProfile extends StatelessWidget {
  final User user;
  final List<Property> properties;
  final int totalViews;
  final int favoritesCount;
  final VoidCallback onEditProfile;
  final VoidCallback onLogout;
  final Function(String) onMenuItemTap;

  const AuthenticatedProfile({
    super.key,
    required this.user,
    required this.properties,
    required this.totalViews,
    required this.favoritesCount,
    required this.onEditProfile,
    required this.onLogout,
    required this.onMenuItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildProfileHeader(),
        const SizedBox(height: 16),
        _buildStatsSection(),
        const SizedBox(height: 24),
        _buildMyListings(),
        const SizedBox(height: 24),
        _buildMenuOptions(),
        const SizedBox(height: 24),
        _buildAccountActions(),
        const SizedBox(height: 20),
        Text(
          'App Version 1.0.0',
          style: TextStyle(fontSize: 12, color: AppColors.grey),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Removed "My Profile" text as requested
          const SizedBox(height: 8),

          // Profile info - NO CARD, just clean layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile image with verification badge
              Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          AppColors.primaryLight.withOpacity(0.2),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: user.profileImage != null
                        ? ClipOval(
                            child: Image.network(
                              user.profileImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Text(
                              user.fullName[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                  ),
                  if (user.verificationLevel != 'unverified')
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surface,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Iconsax.verify5,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 16),

              // User details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Email with icon
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Iconsax.sms,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Phone with icon
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Iconsax.call,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            user.phoneNumber,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Verification badge if verified
                    if (user.verificationLevel != 'unverified')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.verify5,
                              size: 14,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getVerificationBadge(user.verificationLevel),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getVerificationBadge(String level) {
    switch (level) {
      case 'phone_verified':
        return 'Phone Verified';
      case 'identity_verified':
        return 'Identity Verified';
      case 'landlord_verified':
        return 'Verified Landlord';
      default:
        return 'Verified Account';
    }
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            value: properties.length.toString(),
            label: 'My Listings',
            icon: Iconsax.home,
          ),
          Container(height: 40, width: 1, color: AppColors.greyLight),
          _buildStatItem(
            value: totalViews.toString(),
            label: 'Total Views',
            icon: Iconsax.eye,
          ),
          Container(height: 40, width: 1, color: AppColors.greyLight),
          _buildStatItem(
            value: favoritesCount.toString(),
            label: 'Favorites',
            icon: Iconsax.heart,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildMyListings() {
    if (properties.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🏠 My Properties',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (properties.length > 3)
                TextButton(
                  onPressed: () => onMenuItemTap('my_properties'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                  child: Row(
                    children: [
                      Text('See All'),
                      const SizedBox(width: 4),
                      Icon(Iconsax.arrow_right_3, size: 16),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...properties
              .take(3)
              .map(
                (property) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildPropertyListItem(property),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildPropertyListItem(Property property) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.primary.withOpacity(0.1),
            ),
            child: Icon(Iconsax.building_3, size: 30, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        property.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: property.status == 'available'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        property.status,
                        style: TextStyle(
                          fontSize: 11,
                          color: property.status == 'available'
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Iconsax.location, size: 14, color: AppColors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${property.city}, ${property.state}',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      property.formattedPrice,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Iconsax.eye, size: 14, color: AppColors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${property.viewCount} views',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Menu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildMenuItem(
                  icon: Iconsax.heart,
                  title: 'Favorite Properties',
                  subtitle: '$favoritesCount saved properties',
                  value: 'favorites',
                  isFirst: true,
                ),
                _buildDividerLine(),
                _buildMenuItem(
                  icon: Iconsax.document_text,
                  title: 'My Transactions',
                  subtitle: 'View transaction history',
                  value: 'transactions',
                ),
                _buildDividerLine(),
                _buildMenuItem(
                  icon: Iconsax.notification,
                  title: 'Notifications',
                  subtitle: 'Manage notifications',
                  value: 'notifications',
                ),
                _buildDividerLine(),
                _buildMenuItem(
                  icon: Iconsax.security_user,
                  title: 'Privacy & Security',
                  subtitle: 'Account protection',
                  value: 'privacy',
                ),
                _buildDividerLine(),
                _buildMenuItem(
                  icon: Iconsax.message_question,
                  title: 'Help & Support',
                  subtitle: 'Get help with your account',
                  value: 'support',
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: () => onMenuItemTap(value),
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(20) : Radius.zero,
        bottom: isLast ? const Radius.circular(20) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Iconsax.arrow_right_3, size: 18, color: AppColors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDividerLine() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: AppColors.greyLight.withOpacity(0.5)),
    );
  }

  Widget _buildAccountActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Edit Profile Button
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: onEditProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Iconsax.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Edit Profile'),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Logout Button
          Container(
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: onLogout,
              icon: Icon(Iconsax.logout, color: AppColors.error),
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
