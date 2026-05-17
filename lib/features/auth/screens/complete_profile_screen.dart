import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:nigeria_lg_state_city/const.dart';
import 'package:nigeria_lg_state_city/nigeria_lg_state_city.dart';
import '../../../constants/colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/storage/secure_storage.dart';
import '../../profile/providers/profile_provider.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = StateLgaCityController();

  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  final _phoneFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _cityFocus = FocusNode();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _phoneFocus.addListener(() => setState(() {}));
    _addressFocus.addListener(() => setState(() {}));
    _cityFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _phoneFocus.dispose();
    _addressFocus.dispose();
    _cityFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final stateName = _locationController.selectedState?['name']?.trim() ?? '';
    if (stateName.isEmpty) {
      _showSnackBar('Please select your state', AppColors.warning);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await AuthService().completeProfile(
        phoneNumber: _phoneController.text.trim(),
        city: _cityController.text.trim(),
        state: stateName,
        lga: _locationController.selectedLga?['name']?.trim(),
        address: _addressController.text.trim(),
      );

      if (!mounted) return;
      // Capture before async gap
      final navigator = Navigator.of(context);
      final profileProvider = context.read<ProfileProvider>();
      await profileProvider.refreshProfile();
      navigator.pushNamedAndRemoveUntil('/', (r) => false);
    } catch (e) {
      if (mounted) _showSnackBar(e.toString(), AppColors.error);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _showSnackBar('Please complete your profile to continue', AppColors.warning);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Complete Your Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final profileProvider = context.read<ProfileProvider>();
                await SecureStorage().deleteToken();
                if (!mounted) return;
                await profileProvider.logout();
                navigator.pushNamedAndRemoveUntil('/', (r) => false);
              },
              child: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step indicator
                _buildStepIndicator(),
                const SizedBox(height: 28),

                // Intro text
                const Text(
                  'Just a few more details',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'We need your contact and location info to complete your account.',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 28),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _phoneController,
                        focusNode: _phoneFocus,
                        label: 'Phone Number',
                        hint: 'e.g. 08012345678',
                        icon: Iconsax.call,
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Phone number is required';
                          final clean = v.trim().replaceAll(RegExp(r'[\s\-]'), '');
                          if (!RegExp(r'^(0|\+234|234)[789]\d{9}$').hasMatch(clean)) {
                            return 'Enter a valid Nigerian phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _addressController,
                        focusNode: _addressFocus,
                        label: 'Street Address',
                        hint: 'e.g. 12 Adeola Street',
                        icon: Iconsax.location,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter your address'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _cityController,
                        focusNode: _cityFocus,
                        label: 'City',
                        hint: 'e.g. Benin City',
                        icon: Iconsax.building,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter your city'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownLabel('State'),
                      NigeriaStateDropdown(
                        controller: _locationController,
                        decoration: _dropdownDecoration('Select your state', Iconsax.map),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownLabel('Local Government Area'),
                      NigeriLgDropdown(
                        controller: _locationController,
                        decoration: _dropdownDecoration('Select your LGA', Iconsax.location_tick),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Complete Setup',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildDot(active: false, done: true),
        _buildLine(),
        _buildDot(active: true, done: false),
      ],
    );
  }

  Widget _buildDot({required bool active, required bool done}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: done
            ? AppColors.success
            : active
                ? AppColors.primary
                : AppColors.greyLight,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : Text(
                active ? '2' : '1',
                style: TextStyle(
                  color: active ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
      ),
    );
  }

  Widget _buildLine() {
    return Expanded(
      child: Container(height: 2, color: AppColors.success),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final hasFocus = focusNode.hasFocus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: hasFocus ? AppColors.primary : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasFocus
                  ? AppColors.primary
                  : AppColors.greyLight.withValues(alpha: 0.5),
              width: hasFocus ? 2 : 1,
            ),
            boxShadow: hasFocus
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.grey.withValues(alpha: 0.7), fontSize: 14),
              prefixIcon: Icon(icon, color: hasFocus ? AppColors.primary : AppColors.grey, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.grey.withValues(alpha: 0.7), fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.grey, size: 20),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.greyLight.withValues(alpha: 0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.greyLight.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
