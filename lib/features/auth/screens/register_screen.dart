// register_screen.dart - REDESIGNED VERSION
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import '../../../constants/colors.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../profile/providers/profile_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nigeria_lg_state_city/const.dart';
import 'package:nigeria_lg_state_city/nigeria_lg_state_city.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final StateLgaCityController _locationController = StateLgaCityController();

  final _secureStorage = SecureStorage();

  // Focus nodes
  final _fullNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _cityFocus = FocusNode();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  int _currentStep = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _animationController.forward();

    // Add focus listeners
    _fullNameFocus.addListener(() => setState(() {}));
    _emailFocus.addListener(() => setState(() {}));
    _phoneFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
    _confirmPasswordFocus.addListener(() => setState(() {}));
    _addressFocus.addListener(() => setState(() {}));
    _cityFocus.addListener(() => setState(() {}));
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
    _fullNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _addressFocus.dispose();
    _cityFocus.dispose();
    _animationController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (!_step1FormKey.currentState!.validate()) return;
    setState(() => _currentStep = 1);
  }

  void _previousStep() {
    setState(() => _currentStep = 0);
  }

  Future<void> _handleRegister() async {
    if (!_step2FormKey.currentState!.validate()) return;

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

  Future<void> _handleGoogleRegister() async {
    setState(() => _isLoading = true);
    try {
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: '169258422207-ll76eii2kjcqko525tm7vk5ce6pp7i38.apps.googleusercontent.com',
      );
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // user cancelled

      final auth = await googleUser.authentication;
      final idToken = auth.idToken;
      if (idToken == null) throw Exception('Google did not return an ID token');

      final result = await AuthService().signInWithGoogle(idToken);

      if (!mounted) return;
      final navigator = Navigator.of(context);
      await context.read<ProfileProvider>().refreshProfile();

      if (!result.user.isProfileComplete) {
        navigator.pushNamedAndRemoveUntil('/complete-profile', (r) => false);
      } else {
        navigator.pushNamedAndRemoveUntil('/', (r) => false);
      }
    } catch (e) {
      if (mounted) _showSnackBar(e.toString(), AppColors.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Apple Sign-In — coming in v2
  // Future<void> _handleAppleRegister() async {
  //   setState(() => _isLoading = true);
  //   try {
  //     await Future.delayed(const Duration(seconds: 1));
  //     if (mounted) _showSnackBar('Apple Sign-Up coming soon!', AppColors.warning);
  //   } finally {
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: AppColors.textPrimary,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            ),
          ),
        ),
        leadingWidth: 60,
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildPremiumHeader(),
                        const SizedBox(height: 32),
                        _buildStepIndicator(),
                        const SizedBox(height: 32),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.08,
                                ),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                                spreadRadius: -5,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(28),
                          child: _currentStep == 0
                              ? Form(
                                  key: _step1FormKey,
                                  child: _buildPersonalInfoStep(),
                                )
                              : Form(
                                  key: _step2FormKey,
                                  child: _buildAddressStep(),
                                ),
                        ),
                        const SizedBox(height: 24),
                        _buildPremiumTermsText(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildPremiumHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.1),
                AppColors.secondary.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            'GET STARTED',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _currentStep == 0 ? 'Create your\naccount' : 'Your location\ndetails',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _currentStep == 0
              ? 'Join thousands of property seekers in Nigeria'
              : 'Help us personalize your property search',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStepDot(0, 'Personal'),
          Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _currentStep >= 1
                      ? [AppColors.primary, AppColors.primaryLight]
                      : [AppColors.greyLight, AppColors.greyLight],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          _buildStepDot(1, 'Address'),
        ],
      ),
    );
  }

  Widget _buildStepDot(int step, String label) {
    final isActive = step <= _currentStep;
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isActive
                ? LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isActive ? null : AppColors.greyLight,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: isActive
              ? const Icon(Icons.check, size: 20, color: Colors.white)
              : Center(
                  child: Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPremiumTextField(
          controller: _fullNameController,
          focusNode: _fullNameFocus,
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
        const SizedBox(height: 14),
        _buildPremiumTextField(
          controller: _emailController,
          focusNode: _emailFocus,
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
        const SizedBox(height: 14),
        _buildPremiumTextField(
          controller: _phoneController,
          focusNode: _phoneFocus,
          label: 'Phone Number',
          hint: '080XXXXXXXX',
          icon: Iconsax.call,
          keyboardType: TextInputType.phone,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Please enter your phone number';
            if (!RegExp(r'^0[789][01]\d{8}$').hasMatch(v)) {
              return 'Enter a valid Nigerian number';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        _buildPremiumPasswordField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          label: 'Password',
          hint: 'Create a password (min 8 chars)',
          isVisible: _isPasswordVisible,
          onToggle: () =>
              setState(() => _isPasswordVisible = !_isPasswordVisible),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Please enter a password';
            if (v.length < 8) return 'Password must be at least 8 characters';
            return null;
          },
        ),
        const SizedBox(height: 14),
        _buildPremiumPasswordField(
          controller: _confirmPasswordController,
          focusNode: _confirmPasswordFocus,
          label: 'Confirm Password',
          hint: 'Re-enter your password',
          isVisible: _isConfirmPasswordVisible,
          onToggle: () => setState(
            () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Please confirm your password';
            if (v != _passwordController.text) return 'Passwords do not match';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildPremiumDivider(),
        const SizedBox(height: 14),
        _buildPremiumSocialButtons(),
        const SizedBox(height: 16),
        _buildNextButton(),
        const SizedBox(height: 14),
        _buildLoginLink(),
      ],
    );
  }

  Widget _buildAddressStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPremiumTextField(
          controller: _addressController,
          focusNode: _addressFocus,
          label: 'Street Address',
          hint: 'e.g. 12 Adeola Street',
          icon: Iconsax.location,
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Please enter your address'
              : null,
        ),
        const SizedBox(height: 14),
        _buildPremiumTextField(
          controller: _cityController,
          focusNode: _cityFocus,
          label: 'City',
          hint: 'e.g. Lagos',
          icon: Iconsax.building,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Please enter your city' : null,
        ),
        const SizedBox(height: 14),
        _buildPremiumDropdownLabel('State'),
        NigeriaStateDropdown(
          controller: _locationController,
          decoration: _premiumDropdownDecoration(
            'Select your state',
            Iconsax.map,
          ),
        ),
        const SizedBox(height: 14),
        _buildPremiumDropdownLabel('Local Government Area'),
        NigeriLgDropdown(
          controller: _locationController,
          decoration: _premiumDropdownDecoration(
            'Select your LGA',
            Iconsax.location_tick,
          ),
        ),
        const SizedBox(height: 16),
        _buildTermsCheckbox(),
        const SizedBox(height: 16),
        _buildAddressNavigationButtons(),
      ],
    );
  }

  Widget _buildPremiumTextField({
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
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            boxShadow: hasFocus
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
            border: Border.all(
              color: hasFocus
                  ? AppColors.primary
                  : AppColors.greyLight.withValues(alpha: 0.3),
              width: hasFocus ? 2 : 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.grey.withValues(alpha: 0.4),
                fontSize: 13,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(10),
                child: Icon(
                  icon,
                  color: hasFocus ? AppColors.primary : AppColors.grey,
                  size: 18,
                ),
              ),
              isDense: true,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggle,
    required String? Function(String?)? validator,
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
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            boxShadow: hasFocus
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
            border: Border.all(
              color: hasFocus
                  ? AppColors.primary
                  : AppColors.greyLight.withValues(alpha: 0.3),
              width: hasFocus ? 2 : 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: !isVisible,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.grey.withValues(alpha: 0.4),
                fontSize: 13,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(9),
                child: Icon(
                  Iconsax.lock,
                  color: hasFocus ? AppColors.primary : AppColors.grey,
                  size: 17,
                ),
              ),
              suffixIcon: IconButton(
                onPressed: onToggle,
                icon: Icon(
                  isVisible ? Iconsax.eye : Iconsax.eye_slash,
                  color: AppColors.grey,
                  size: 17,
                ),
                padding: EdgeInsets.zero,
                splashRadius: 16,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                visualDensity: VisualDensity.compact,
              ),
              isDense: true,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 16,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumDropdownLabel(String label) {
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

  InputDecoration _premiumDropdownDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.grey.withValues(alpha: 0.4),
        fontSize: 13,
      ),
      prefixIcon: Container(
        margin: const EdgeInsets.all(10),
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
      isDense: true,
      prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
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
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    );
  }

  Widget _buildTermsCheckbox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLight.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Transform.scale(
            scale: 0.9,
            child: Checkbox(
              value: _agreeToTerms,
              onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              side: BorderSide(color: AppColors.greyLight, width: 1.5),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
              child: Text.rich(
                TextSpan(
                  text: 'I agree to the ',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
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
      ),
    );
  }

  Widget _buildNextButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.greyLight.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR SIGN UP WITH',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.greyLight.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumSocialButtons() {
    return _buildSocialButton(
      onTap: _handleGoogleRegister,
      label: 'Continue with Google',
      iconPath: 'assets/icons/google.svg',
      fallbackIcon: Icons.g_mobiledata,
    );
    // Apple Sign-In — v2
    // const SizedBox(width: 12),
    // _buildSocialButton(
    //   onTap: _handleAppleRegister,
    //   label: 'Apple',
    //   fallbackIcon: Icons.apple,
    //   isApple: true,
    // ),
  }

  Widget _buildSocialButton({
    required VoidCallback onTap,
    required String label,
    required IconData fallbackIcon,
    String? iconPath,
    bool isApple = false,
  }) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: isApple ? AppColors.textPrimary : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.greyLight.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconPath != null)
                SvgPicture.asset(
                  iconPath,
                  height: 18,
                  width: 18,
                  placeholderBuilder: (context) => Icon(
                    fallbackIcon,
                    color: isApple ? Colors.white : AppColors.primary,
                    size: 18,
                  ),
                )
              else
                Icon(
                  fallbackIcon,
                  color: isApple ? Colors.white : AppColors.primary,
                  size: 18,
                ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isApple ? Colors.white : AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressNavigationButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.greyLight.withValues(alpha: 0.3),
              ),
            ),
            child: OutlinedButton(
              onPressed: _previousStep,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Back',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: _agreeToTerms
                    ? [AppColors.primary, AppColors.primaryDark]
                    : [AppColors.grey, AppColors.greyDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: _agreeToTerms
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: ElevatedButton(
              onPressed: _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Create',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.check_circle, size: 18),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Sign In',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumTermsText() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'By signing up, you agree to our\nTerms of Service and Privacy Policy',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary.withValues(alpha: 0.6),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
