import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/property.dart';
import '../providers/property_detail_provider.dart';
import '../../chat/providers/chat_provider.dart';
import '../../chat/screens/chat_screen.dart';
import '../../../constants/colors.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/property_network_image.dart';

class PropertyDetailScreen extends StatefulWidget {
  final String propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  int _currentImageIndex = 0;
  final PageController _imagePageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyDetailProvider>().loadProperty(widget.propertyId);
    });
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  // Normalize Nigerian phone to international format for tel: and wa.me
  String _toInternationalNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)+]'), '');
    if (cleaned.startsWith('0')) cleaned = '234${cleaned.substring(1)}';
    if (!cleaned.startsWith('234')) cleaned = '234$cleaned';
    return cleaned;
  }

  Future<void> _launchCall(String phone) async {
    final number = _toInternationalNumber(phone);
    final uri = Uri.parse('tel:+$number');
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open dialer')));
      }
    }
  }

  Future<void> _launchWhatsApp(String phone, Property property) async {
    final number = _toInternationalNumber(phone);
    final message = Uri.encodeComponent(
      'Hi, I\'m interested in your property: ${property.title} listed on Direct Property.',
    );
    final uri = Uri.parse('https://wa.me/$number?text=$message');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WhatsApp is not installed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PropertyDetailProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingIndicator();
          }

          if (provider.errorMessage != null) {
            return CustomErrorWidget(
              message: provider.errorMessage!,
              onRetry: () => provider.loadProperty(widget.propertyId),
            );
          }

          if (provider.property == null) {
            return const Center(child: Text('Property not found'));
          }

          return _buildDetailScreen(provider.property!);
        },
      ),
    );
  }

  Widget _buildDetailScreen(Property property) {
    final List<String> imageUrls = property.images.isNotEmpty
        ? property.images.map((e) => e.imageUrl).toList()
        : (property.mainImage != null && property.mainImage!.isNotEmpty)
        ? [property.mainImage!]
        : [];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageGallery(property, imageUrls),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.heart,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.share,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              property.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Iconsax.location,
                                  size: 14,
                                  color: AppColors.grey,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${property.address}, ${property.city}, ${property.state}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              property.priceWithPeriod,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${property.viewCount} views',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Key Features',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      if (property.bedrooms != null && property.bedrooms! > 0)
                        _buildFeatureChip(
                          Iconsax.home,
                          '${property.bedrooms} Bedrooms',
                        ),
                      if (property.bathrooms != null && property.bathrooms! > 0)
                        _buildFeatureChip(
                          Iconsax.drop,
                          '${property.bathrooms} Bathrooms',
                        ),
                      if (property.toilets != null && property.toilets! > 0)
                        _buildFeatureChip(
                          Iconsax.house,
                          '${property.toilets} Toilets',
                        ),
                      _buildFeatureChip(Iconsax.ruler, property.displayArea),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  if (property.features.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Additional Features',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: property.features.map((feature) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.greyLight),
                          ),
                          child: Text(
                            feature,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    'Location',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.greyLight),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.map, size: 40, color: AppColors.grey),
                          const SizedBox(height: 8),
                          Text(
                            '${property.lga}, ${property.city}',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (property.landmark != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Near: ${property.landmark}',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(property),
    );
  }

  Widget _buildImageGallery(Property property, List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          PropertyNetworkImage(
            imageUrl: null,
            iconFallback: _getPropertyIcon(property),
            fallbackColor: property.typeColor,
          ),
          _buildImageOverlay(property),
        ],
      );
    }

    if (imageUrls.length == 1) {
      return Stack(
        fit: StackFit.expand,
        children: [
          PropertyNetworkImage(
            imageUrl: imageUrls.first,
            iconFallback: _getPropertyIcon(property),
            fallbackColor: property.typeColor,
          ),
          _buildImageOverlay(property),
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _imagePageController,
          itemCount: imageUrls.length,
          onPageChanged: (i) => setState(() => _currentImageIndex = i),
          itemBuilder: (context, index) {
            return PropertyNetworkImage(
              imageUrl: imageUrls[index],
              iconFallback: _getPropertyIcon(property),
              fallbackColor: property.typeColor,
            );
          },
        ),
        _buildImageOverlay(property),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: MediaQuery.of(context).size.width * 0.35,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              if (_currentImageIndex > 0) {
                _imagePageController.animateToPage(
                  _currentImageIndex - 1,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: const SizedBox.expand(),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: MediaQuery.of(context).size.width * 0.35,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              if (_currentImageIndex < imageUrls.length - 1) {
                _imagePageController.animateToPage(
                  _currentImageIndex + 1,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: const SizedBox.expand(),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(imageUrls.length, (i) {
              final isActive = i == _currentImageIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Iconsax.gallery, size: 12, color: Colors.white),
                const SizedBox(width: 5),
                Text(
                  '${_currentImageIndex + 1} / ${imageUrls.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageOverlay(Property property) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.5, 1.0],
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
            ),
          ),
        ),
        Positioned(
          top: 60,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: property.typeColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              property.displayType,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
        if (property.verified)
          Positioned(
            top: 60,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.tick_circle, color: Colors.white, size: 14),
                  SizedBox(width: 5),
                  Text(
                    'Verified',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(Property property) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showContactOptions(property),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Contact Owner',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greyLight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () {
                  final provider = context.read<PropertyDetailProvider>();
                  final phone = provider.owner?.phoneNumber;
                  if (phone != null && phone.isNotEmpty) {
                    _launchCall(phone);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Owner phone not available'),
                      ),
                    );
                  }
                },
                icon: const Icon(Iconsax.call),
                color: AppColors.primary,
                iconSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactOptions(Property property) {
    final parentContext = context;
    final provider = context.read<PropertyDetailProvider>();
    final phone = provider.owner?.phoneNumber;
    final hasPhone = phone != null && phone.isNotEmpty;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Contact Owner',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (provider.owner?.fullName != null) ...[
                const SizedBox(height: 4),
                Text(
                  provider.owner!.fullName,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.message, color: AppColors.primary),
                ),
                title: const Text('Send Message'),
                subtitle: const Text('Chat with property owner'),
                onTap: () async {
                  Navigator.pop(sheetContext); // close bottom sheet first

                  ChatProvider chatProvider;
                  try {
                    chatProvider = parentContext.read<ChatProvider>();
                  } catch (_) {
                    if (!parentContext.mounted) return;
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Chat is initializing. Please restart the app and try again.',
                        ),
                      ),
                    );
                    return;
                  }

                  await chatProvider.init();
                  final conversation = await chatProvider
                      .openOrCreateConversation(
                        ownerId: property.ownerId,
                        propertyId: property.id,
                        propertyTitle: property.title,
                        propertyImage: property.mainImage,
                      );

                  if (!parentContext.mounted) return;

                  if (conversation != null) {
                    Navigator.push(
                      parentContext,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          conversation: conversation,
                          currentUserId: chatProvider.currentUser!.id,
                        ),
                      ),
                    );
                  } else if (chatProvider.currentUser == null) {
                    Navigator.pushNamed(parentContext, '/login');
                  } else if (chatProvider.currentUser!.id == property.ownerId) {
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      const SnackBar(
                        content: Text('You cannot message your own property.'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      const SnackBar(
                        content: Text('Unable to open chat right now.'),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: hasPhone
                        ? Colors.green.withValues(alpha: 0.1)
                        : AppColors.greyLight.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.call,
                    color: hasPhone ? Colors.green : AppColors.grey,
                  ),
                ),
                title: const Text('Call Now'),
                subtitle: Text(
                  hasPhone
                      ? 'Speak directly with owner'
                      : 'Phone not available',
                ),
                onTap: hasPhone
                    ? () {
                        Navigator.pop(sheetContext);
                        _launchCall(phone);
                      }
                    : null,
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: hasPhone
                        ? Colors.orange.withValues(alpha: 0.1)
                        : AppColors.greyLight.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.message_text,
                    color: hasPhone ? Colors.orange : AppColors.grey,
                  ),
                ),
                title: const Text('WhatsApp'),
                subtitle: Text(
                  hasPhone ? 'Chat on WhatsApp' : 'Phone not available',
                ),
                onTap: hasPhone
                    ? () {
                        Navigator.pop(sheetContext);
                        _launchWhatsApp(phone, property);
                      }
                    : null,
              ),
              const SizedBox(height: 8),
              Text(
                'Phone verification required to contact owner',
                style: TextStyle(fontSize: 12, color: AppColors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  IconData _getPropertyIcon(Property property) {
    switch (property.propertyType.toLowerCase()) {
      case 'land':
        return Iconsax.map;
      case 'commercial':
      case 'shop':
      case 'office':
        return Iconsax.building;
      case 'shortlet':
        return Iconsax.house;
      default:
        return Iconsax.home;
    }
  }
}
