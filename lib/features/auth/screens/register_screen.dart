import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../../constants/colors.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../profile/providers/profile_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nigeria_lg_state_city/nigeria_lg_state_city.dart';
import 'package:nigeria_lg_state_city/const.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  // Separate form keys per step so validation is scoped correctly
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  // controller from the nigeria_lg_state_city package
  final StateLgaCityController _locationController = StateLgaCityController();

  final _secureStorage = SecureStorage();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  int _currentStep = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _animationController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // ── Step navigation ─────────────────────────────────────────────────────────

  void _nextStep() {
    // BUG FIX: validate step 1 before advancing
    if (!_step1FormKey.currentState!.validate()) return;
    setState(() => _currentStep = 1);
  }

  void _previousStep() {
    setState(() => _currentStep = 0);
  }

  // ── Registration submit ─────────────────────────────────────────────────────

  Future<void> _handleRegister() async {
    // BUG FIX: validate step 2 form
    if (!_step2FormKey.currentState!.validate()) return;

    // BUG FIX: validate state selection explicitly
    final stateName = _locationController.selectedState?['name']?.trim() ?? '';
    if (stateName.isEmpty) {
      _showSnackBar('Please select your state', AppColors.warning);
      return;
    }

    if (!_agreeToTerms) {
      _showSnackBar(
        'Please agree to the terms and conditions',
        AppColors.warning,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient().post(
        ApiEndpoints.register,
        data: {
          'email': _emailController.text.trim(),
          'phone_number': _phoneController.text.trim(),
          'full_name': _fullNameController.text.trim(),
          'password': _passwordController.text,
          'city': _cityController.text.trim(),
          'state': stateName,
          'lga': _locationController.selectedLga?['name']?.trim() ?? '',
          'address': _addressController.text.trim(),
        },
      );

      final token = response['access_token'];
      final user = response['user'];

      if (token == null || user == null) {
        throw Exception('Invalid response: missing token or user data');
      }

      await _secureStorage.saveToken(token);
      await _secureStorage.saveUser(jsonEncode(user));

      if (mounted) {
        try {
          await context.read<ProfileProvider>().refreshProfile();
        } catch (e) {
          debugPrint('⚠️ Profile refresh failed (non-critical): $e');
        }

        if (mounted) {
          _showSnackBar(
            'Welcome! Account created successfully 🎉',
            AppColors.success,
          );
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        }
      }
    } on ApiException catch (e) {
      // BUG FIX: use statusCode directly from ApiException
      String message = 'Registration failed. Please try again.';
      if (e.statusCode == 400) {
        final detail = e.message.toLowerCase();
        if (detail.contains('email')) {
          message = 'This email is already registered';
        } else if (detail.contains('phone')) {
          message = 'This phone number is already registered';
        } else {
          message = e.message;
        }
      } else if (e.statusCode == 422) {
        message = 'Please check your details and try again';
      } else if (e.statusCode == 0) {
        message = 'Network error. Check your internet connection';
      }
      if (mounted) _showSnackBar(message, AppColors.error);
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'Something went wrong. Please try again.',
          AppColors.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const LoadingIndicator()
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBackButton(),
                          const SizedBox(height: 20),
                          _buildHeader(),
                          const SizedBox(height: 30),
                          // Step 1 — Personal info
                          if (_currentStep == 0)
                            _buildStepCard(
                              formKey: _step1FormKey,
                              child: Column(
                                children: [
                                  _buildStepIndicator(),
                                  const SizedBox(height: 24),
                                  _buildPersonalInfoStep(),
                                  const SizedBox(height: 24),
                                  _buildNextButton(),
                                  const SizedBox(height: 24),
                                  _buildDivider(),
                                  const SizedBox(height: 24),
                                  _buildGoogleButton(),
                                  const SizedBox(height: 16),
                                  _buildLoginLink(),
                                ],
                              ),
                            ),
                          // Step 2 — Address
                          if (_currentStep == 1)
                            _buildStepCard(
                              formKey: _step2FormKey,
                              child: Column(
                                children: [
                                  _buildStepIndicator(),
                                  const SizedBox(height: 24),
                                  _buildAddressStep(),
                                  const SizedBox(height: 24),
                                  // BUG FIX: show terms checkbox BEFORE button
                                  // and show clear disabled-state explanation
                                  _buildTermsCheckbox(),
                                  const SizedBox(height: 16),
                                  _buildAddressNavigationButtons(),
                                ],
                              ),
                            ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildStepCard({
    required GlobalKey<FormState> formKey,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -5,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Form(key: formKey, child: child),
    );
  }

  Widget _buildBackButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pop(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.greyLight.withValues(alpha: 0.3),
            ),
            boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 10)],
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Account 🏠',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _currentStep == 0
              ? 'Tell us about yourself'
              : 'Where are you located?',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepDot(0, 'Personal'),
        Expanded(
          child: Container(
            height: 2,
            color: _currentStep >= 1 ? AppColors.primary : AppColors.greyLight,
          ),
        ),
        _buildStepDot(1, 'Address'),
      ],
    );
  }

  Widget _buildStepDot(int step, String label) {
    final isActive = step <= _currentStep;
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primary : AppColors.greyLight,
          ),
          child: isActive
              ? const Icon(Icons.check, size: 18, color: Colors.white)
              : Center(
                  child: Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _fullNameController,
          label: 'Full Name',
          hint: 'Enter your full name',
          icon: Iconsax.user,
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Please enter your name';
            }
            if (v.trim().length < 3) {
              return 'Name must be at least 3 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email Address',
          hint: 'Enter your email',
          icon: Iconsax.sms,
          keyboardType: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Please enter your email';
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number',
          hint: '080XXXXXXXX',
          icon: Iconsax.call,
          keyboardType: TextInputType.phone,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Please enter your phone number';
            // Match Nigerian numbers: 0801..., 0901..., etc.
            if (!RegExp(r'^0[789][01]\d{8}$').hasMatch(v)) {
              return 'Enter a valid Nigerian phone number (e.g. 08012345678)';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildPasswordField(
          controller: _passwordController,
          label: 'Password',
          hint: 'Create a password (min 8 chars)',
          isVisible: _isPasswordVisible,
          onToggleVisibility: () =>
              setState(() => _isPasswordVisible = !_isPasswordVisible),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Please enter a password';
            if (v.length < 8) return 'Password must be at least 8 characters';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildPasswordField(
          controller: _confirmPasswordController,
          label: 'Confirm Password',
          hint: 'Re-enter your password',
          isVisible: _isConfirmPasswordVisible,
          onToggleVisibility: () => setState(
            () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Please confirm your password';
            if (v != _passwordController.text) return 'Passwords do not match';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAddressStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _addressController,
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
          label: 'City',
          hint: 'e.g. Lagos',
          icon: Iconsax.building,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Please enter your city' : null,
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
          decoration: _dropdownDecoration(
            'Select your LGA',
            Iconsax.location_tick,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.grey.withValues(alpha: 0.5)),
      prefixIcon: Container(
        margin: const EdgeInsets.all(12),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.greyLight.withValues(alpha: 0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }

  // ── BUG FIX: terms shown first, then button ─────────────────────────────────

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: _agreeToTerms,
          onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
          activeColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          side: BorderSide(color: AppColors.greyLight),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
            child: Text.rich(
              TextSpan(
                text: 'I agree to the ',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressNavigationButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _previousStep,
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Back'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            // BUG FIX: button always tappable; terms check happens inside handler
            // with a clear error message instead of silently disabling
            onPressed: _handleRegister,
            icon: const Icon(Icons.check_circle, size: 18),
            label: const Text(
              'Create Account',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _agreeToTerms
                  ? AppColors.primary
                  : AppColors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _nextStep,
        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
        label: const Text(
          'Continue',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.grey.withValues(alpha: 0.5)),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.greyLight.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.error),
            ),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    required String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.grey.withValues(alpha: 0.5)),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              child: Icon(Iconsax.lock, color: AppColors.primary, size: 20),
            ),
            suffixIcon: IconButton(
              onPressed: onToggleVisibility,
              icon: Icon(
                isVisible ? Iconsax.eye : Iconsax.eye_slash,
                color: AppColors.grey,
                size: 20,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.greyLight.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.error),
            ),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.greyLight)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ),
        Expanded(child: Divider(color: AppColors.greyLight)),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () =>
            _showSnackBar('Google Sign-Up coming soon!', AppColors.warning),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.greyLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/google.svg',
              height: 24,
              width: 24,
              placeholderBuilder: (_) =>
                  Icon(Icons.g_mobiledata, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Sign up with Google',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, '/login'),
          child: Text(
            'Sign In',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
