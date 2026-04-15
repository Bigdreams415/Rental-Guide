import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../constants/colors.dart';
import 'package:nigeria_lg_state_city/const.dart';
import 'package:nigeria_lg_state_city/nigeria_lg_state_city.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../widgets/video_section.dart';
import '../widgets/document_verification_section.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PostPropertyScreen extends StatefulWidget {
  const PostPropertyScreen({super.key});

  @override
  State<PostPropertyScreen> createState() => _PostPropertyScreenState();
}

class _PostPropertyScreenState extends State<PostPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isSubmitting = false;
  bool _agreeInfo = false; // user must agree to accuracy of information

  // Step 1: Basic Info
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedPropertyType;
  String? _selectedListingType;

  // Step 2: Location
  // using package controller instead of manual strings
  final _locationController = StateLgaCityController();
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();

  // Step 3: Details & Pricing
  final _priceController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _toiletsController = TextEditingController();
  final _squareMetersController = TextEditingController();
  final _plotSizeController = TextEditingController();

  // Step 3: Features
  final List<String> _selectedFeatures = [];
  final _customFeatureController = TextEditingController();
  static const List<String> _commonFeatures = [
    'Parking',
    'Swimming Pool',
    'Security',
    'Furnished',
    'Garden',
    'Gym',
    'CCTV',
    'Water Supply',
    'Electricity (24/7)',
    'Generator',
    'Solar Panel',
    'Air Conditioning',
    'Balcony',
    'Walk-in Closet',
    'POP Ceiling',
    'Tiled Floors',
    'Kitchen Cabinets',
    'Burglary Proofs',
    'Fenced',
    'Gated Community',
    'Borehole',
    'Boys Quarters (BQ)',
    'Store Room',
    'Ensuite Rooms',
  ];

  // Step 4: Images (direct upload)
  final List<XFile> _images = [];
  final Map<String, String> _imageCaptions = {};
  final ImagePicker _imagePicker = ImagePicker();

  // Step 5: Ownership Documents
  final List<String> _ownershipDocuments = [];
  Map<String, String> _verificationDocumentData = {};
  // document types are managed by DocumentVerificationSection widget

  // Enum values matching backend
  static const Map<String, String> _propertyTypes = {
    'House': 'house',
    'Land': 'land',
    'Commercial': 'commercial',
    'Shop': 'shop',
    'Office': 'office',
    'Warehouse': 'warehouse',
    'Event Center': 'event_center',
    'Shortlet': 'shortlet',
  };

  static const Map<String, String> _listingTypes = {
    'For Sale': 'sale',
    'For Rent': 'rent',
    'For Lease': 'lease',
    'Short Stay': 'shortlet',
  };

  final List<String> _stepTitles = [
    'Basic Info',
    'Location',
    'Details',
    'Media',
    'Documents',
  ];

  String? _videoUrl;
  String? _selectedDocument;

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _toiletsController.dispose();
    _squareMetersController.dispose();
    _plotSizeController.dispose();
    _customFeatureController.dispose();
    // image controllers removed; image picker used instead
    super.dispose();
  }

  void _goToStep(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep = step);
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < _stepTitles.length - 1) {
        _goToStep(_currentStep + 1);
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Basic Info
        if (_selectedPropertyType == null) {
          _showError('Please select a property type');
          return false;
        }
        if (_selectedListingType == null) {
          _showError('Please select a listing type');
          return false;
        }
        if (_titleController.text.trim().isEmpty) {
          _showError('Please enter a property title');
          return false;
        }
        if (_descriptionController.text.trim().isEmpty) {
          _showError('Please enter a description');
          return false;
        }
        return true;

      case 1: // Location
        if (_locationController.selectedState == null) {
          _showError('Please select a state');
          return false;
        }
        if (_locationController.selectedLga == null) {
          _showError('Please select an LGA');
          return false;
        }
        // city is optional in package or can be null
        if (_addressController.text.trim().isEmpty) {
          _showError('Please enter an address');
          return false;
        }
        return true;

      case 2: // Details
        if (_priceController.text.trim().isEmpty) {
          _showError('Please enter a price');
          return false;
        }
        final price = double.tryParse(_priceController.text.trim());
        if (price == null || price <= 0) {
          _showError('Please enter a valid price');
          return false;
        }
        return true;

      case 3: // Media
        if (_images.isEmpty) {
          _showError('Please add at least one property image');
          return false;
        }
        return true;

      case 4: // Documents
        if (_selectedDocument == null || _selectedDocument!.isEmpty) {
          _showError('Please select a verification document');
          return false;
        }
        if (!_agreeInfo) {
          _showError(
            'Please confirm that the information you provided is accurate.',
          );
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submitProperty() async {
    if (!_validateCurrentStep()) return;

    // NEW: Validate document selection (already handled above along with agreement)

    setState(() => _isSubmitting = true);

    try {
      // Prepare files and fields for multipart upload
      final List<File> files = _images.map((x) => File(x.path)).toList();
      final List<String> captions = _images
          .map((x) => _imageCaptions[x.path] ?? '')
          .toList();

      final Map<String, String> fields = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'property_type': _propertyTypes[_selectedPropertyType] ?? '',
        'listing_type': _listingTypes[_selectedListingType] ?? '',
        'address': _addressController.text.trim(),
        'city': _locationController.selectedCity?['name'] ?? '',
        'state': _locationController.selectedState?['name'] ?? '',
        'lga': _locationController.selectedLga?['name'] ?? '',
        'price': _priceController.text.trim(),
        'features': jsonEncode(_selectedFeatures),
        'verification_document': jsonEncode(_verificationDocumentData),
        'video_url': _videoUrl ?? '',
        'image_captions': jsonEncode(captions),
      };

      debugPrint(
        '📤 Submitting property (multipart) fields: ${jsonEncode(fields)}',
      );

      await ApiClient().postMultipart(
        ApiEndpoints.createProperty,
        fields: fields,
        files: files,
        fileFieldName: 'images',
        requiresAuth: true,
      );

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      debugPrint('❌ Submit error: $e');
      if (mounted) {
        _showError('Failed to post property: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.tick_circle,
                size: 60,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Property Submitted!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Your property has been submitted for verification. You\'ll be notified once it\'s approved.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _resetForm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _addressController.clear();
    _landmarkController.clear();
    _priceController.clear();
    _bedroomsController.clear();
    _bathroomsController.clear();
    _toiletsController.clear();
    _squareMetersController.clear();
    _plotSizeController.clear();
    _customFeatureController.clear();

    setState(() {
      _selectedPropertyType = null;
      _selectedListingType = null;
      // clear controller selections
      _locationController.selectState(null);
      _locationController.selectLga(null);
      _locationController.selectCity(null);
      _selectedFeatures.clear();
      _images.clear();
      _selectedDocument = null;
      _videoUrl = null;
      _currentStep = 0;
    });
    _pageController.jumpToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStepIndicator(),
            Expanded(
              child: Form(
                key: _formKey,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() => _currentStep = index);
                  },
                  children: [
                    _buildStep1BasicInfo(),
                    _buildStep2Location(),
                    _buildStep3Details(),
                    _buildStep4Media(),
                    _buildStep5Documents(),
                  ],
                ),
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  // ─── HEADER ──────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Iconsax.add_square, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Post Your Property',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Step ${_currentStep + 1} of ${_stepTitles.length}: ${_stepTitles[_currentStep]}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── STEP INDICATOR ──────────────────────────────────────
  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: AppColors.surface,
      child: Row(
        children: List.generate(_stepTitles.length, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? AppColors.success
                              : isActive
                              ? AppColors.primary
                              : AppColors.greyLight,
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isActive
                                        ? Colors.white
                                        : AppColors.grey,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _stepTitles[index],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (index < _stepTitles.length - 1)
                  Container(
                    width: 16,
                    height: 2,
                    color: isCompleted
                        ? AppColors.success
                        : AppColors.greyLight,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ─── STEP 1: BASIC INFO ─────────────────────────────────
  Widget _buildStep1BasicInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Property Type'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _propertyTypes.keys.map((type) {
              final isSelected = _selectedPropertyType == type;
              return GestureDetector(
                onTap: () => setState(() => _selectedPropertyType = type),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.greyLight,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Listing Type'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _listingTypes.keys.map((type) {
              final isSelected = _selectedListingType == type;
              return GestureDetector(
                onTap: () => setState(() => _selectedListingType = type),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.secondary : AppColors.surface,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.secondary
                          : AppColors.greyLight,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _titleController,
            label: 'Property Title *',
            hint: 'e.g., 3-Bedroom Duplex with BQ',
            icon: Iconsax.home,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _descriptionController,
            label: 'Description *',
            hint: 'Describe your property in detail...',
            icon: Iconsax.document_text,
            maxLines: 5,
          ),
        ],
      ),
    );
  }

  // ─── STEP 2: LOCATION ───────────────────────────────────
  Widget _buildStep2Location() {
    // data now handled by controller; we don't need cities/lgas lists
    // final cities = ...;
    // final lgas = ...;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Property Location'),
          const SizedBox(height: 16),
          // using package dropdowns
          NigeriaStateDropdown(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'State *',
              hintText: 'Select state',
              prefixIcon: Icon(Iconsax.map),
            ),
          ),
          const SizedBox(height: 16),
          NigeriLgDropdown(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'LGA *',
              hintText: 'Select LGA',
              prefixIcon: Icon(Iconsax.location),
            ),
          ),
          const SizedBox(height: 16),
          NigeriaCityDropdown(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'City *',
              hintText: 'Select city',
              prefixIcon: Icon(Iconsax.building),
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _addressController,
            label: 'Address *',
            hint: 'e.g., 15 Ogui Road, Independence Layout',
            icon: Iconsax.location,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _landmarkController,
            label: 'Landmark (optional)',
            hint: 'e.g., Near University Teaching Hospital',
            icon: Iconsax.flag,
          ),
        ],
      ),
    );
  }

  // ─── STEP 3: DETAILS & FEATURES ─────────────────────────
  Widget _buildStep3Details() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Pricing'),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _priceController,
            label: 'Price (₦) *',
            hint: 'e.g., 25000000',
            icon: Iconsax.wallet,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Property Specs'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _bedroomsController,
                  label: 'Bedrooms',
                  hint: '0',
                  icon: Iconsax.home_hashtag,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _bathroomsController,
                  label: 'Bathrooms',
                  hint: '0',
                  icon: Iconsax.drop,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _toiletsController,
                  label: 'Toilets',
                  hint: '0',
                  icon: Iconsax.home_1,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _squareMetersController,
                  label: 'Area (sq m)',
                  hint: '0',
                  icon: Iconsax.ruler,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _plotSizeController,
                  label: 'Plot Size',
                  hint: 'e.g., 100x100',
                  icon: Iconsax.size,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Features & Amenities'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _commonFeatures.map((feature) {
              final isSelected = _selectedFeatures.contains(feature);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedFeatures.remove(feature);
                    } else {
                      _selectedFeatures.add(feature);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.greyLight,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Icon(
                            Icons.check,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      Text(
                        feature,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Custom feature
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _customFeatureController,
                  label: '',
                  hint: 'Add custom feature...',
                  icon: Iconsax.add,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: IconButton(
                  onPressed: () {
                    final feature = _customFeatureController.text.trim();
                    if (feature.isNotEmpty &&
                        !_selectedFeatures.contains(feature)) {
                      setState(() {
                        _selectedFeatures.add(feature);
                        _customFeatureController.clear();
                      });
                    }
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.all(12),
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
          if (_selectedFeatures
              .where((f) => !_commonFeatures.contains(f))
              .isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Custom features:',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedFeatures
                  .where((f) => !_commonFeatures.contains(f))
                  .map(
                    (f) => Chip(
                      label: Text(f, style: const TextStyle(fontSize: 12)),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () =>
                          setState(() => _selectedFeatures.remove(f)),
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─── STEP 4: MEDIA (IMAGES + VIDEO) ─────────────────────
  Widget _buildStep4Media() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Property Images *'),
          const SizedBox(height: 8),
          Text(
            'Upload images for your property. The first image will be the main image.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // Pick images button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                try {
                  final List<XFile> picked = await _imagePicker.pickMultiImage(
                    imageQuality: 80,
                  );
                  if (picked.isNotEmpty) {
                    setState(() {
                      // add new images
                      for (var p in picked) {
                        if (!_images.any((e) => e.path == p.path)) {
                          _images.add(p);
                        }
                      }
                    });
                  }
                } catch (e) {
                  _showError('Failed to pick images');
                }
              },
              icon: const Icon(Iconsax.gallery_add),
              label: const Text('Pick Images'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Image previews
          if (_images.isNotEmpty)
            ...List.generate(_images.length, (index) {
              final img = _images[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: index == 0 ? AppColors.primary : AppColors.greyLight,
                    width: index == 0 ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(img.path),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Iconsax.image,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (index == 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'MAIN',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              if (index == 0) const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  initialValue: _imageCaptions[img.path] ?? '',
                                  onChanged: (v) =>
                                      _imageCaptions[img.path] = v,
                                  decoration: InputDecoration(
                                    hintText: 'Caption (optional)',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            img.name,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() {
                        _imageCaptions.remove(_images[index].path);
                        _images.removeAt(index);
                      }),
                      icon: Icon(
                        Iconsax.trash,
                        size: 20,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              );
            }),

          if (_images.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.greyLight),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Iconsax.gallery, size: 48, color: AppColors.grey),
                    const SizedBox(height: 12),
                    Text(
                      'No images uploaded yet',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          // NEW: Video Section
          VideoSection(
            onVideoAdded: (videoUrl) {
              setState(() {
                _videoUrl = videoUrl;
              });
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─── STEP 5: DOCUMENT VERIFICATION ───────────────────────
  Widget _buildStep5Documents() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Property Verification *'),
          const SizedBox(height: 8),
          Text(
            'To verify your ownership, please select ONE document type. Your property will be reviewed before going live.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // NEW: Document Verification Widget (Single Selection)
          DocumentVerificationSection(
            onDocumentSelected: (doc) {
              setState(() {
                _selectedDocument = doc;
              });
            },
            onDocumentDataChanged: (data) {
              setState(() {
                _selectedDocument = (data['document_type'] as String?) ?? '';
                _verificationDocumentData = {
                  'document_type': (data['document_type'] ?? '').toString(),
                  'document_number': (data['document_number'] ?? '').toString(),
                  'issued_by': (data['issued_by'] ?? '').toString(),
                };
                if (_selectedDocument != null &&
                    _selectedDocument!.isNotEmpty) {
                  _ownershipDocuments.clear();
                  _ownershipDocuments.add(_selectedDocument!);
                } else {
                  _ownershipDocuments.clear();
                }
              });
            },
            selectedDocument: _selectedDocument,
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _agreeInfo
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : AppColors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _agreeInfo,
                  onChanged: (v) => setState(() => _agreeInfo = v ?? false),
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _agreeInfo = !_agreeInfo),
                    child: Text(
                      'I confirm that all information provided is accurate and truthful. '
                      'I understand that submitting false or misleading property details '
                      'violates our Terms of Service and I will be held solely responsible '
                      'for any consequences arising from inaccurate information.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─── NAVIGATION BUTTONS ─────────────────────────────────
  Widget _buildNavigationButtons() {
    final isLastStep = _currentStep == _stepTitles.length - 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: BorderSide(color: AppColors.greyLight),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting
                  ? null
                  : isLastStep
                  ? _submitProperty
                  : _nextStep,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      isLastStep ? Iconsax.tick_circle : Iconsax.arrow_right_3,
                      color: Colors.white,
                    ),
              label: Text(
                _isSubmitting
                    ? 'Submitting...'
                    : isLastStep
                    ? 'Submit Property'
                    : 'Next',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isLastStep
                    ? AppColors.success
                    : AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── REUSABLE WIDGETS ───────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.greyLight.withValues(alpha: 0.5),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.grey.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, color: AppColors.grey, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
