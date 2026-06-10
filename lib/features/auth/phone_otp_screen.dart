import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_waste_app/features/admin/admin_dashboard_screen.dart';
import 'package:food_waste_app/features/donor/donor_dashboard_screen.dart';
import 'package:food_waste_app/features/organization/organization_dashboard_screen.dart';
import 'package:food_waste_app/features/auth/role_selection_screen.dart';

/// A professional phone OTP authentication screen with Firebase Phone Auth.
class PhoneOtpScreen extends StatefulWidget {
  const PhoneOtpScreen({super.key});

  @override
  State<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends State<PhoneOtpScreen>
    with TickerProviderStateMixin {
  // ------ controllers ------
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  // ------ state ------
  bool _isLoading = false;
  bool _codeSent = false;
  String _verificationId = '';
  int? _resendToken;
  String _selectedCountryCode = '+880';
  int _resendSeconds = 60;
  Timer? _resendTimer;
  ConfirmationResult? _confirmationResult;

  // ------ animation ------
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, String>> _countries = [
    {'code': '+880', 'flag': '🇧🇩', 'name': 'Bangladesh'},
    {'code': '+91', 'flag': '🇮🇳', 'name': 'India'},
    {'code': '+1', 'flag': '🇺🇸', 'name': 'USA'},
    {'code': '+44', 'flag': '🇬🇧', 'name': 'UK'},
  ];

  static const Color _green = Color(0xFF2E7D32);
  static const Color _greenLight = Color(0xFF43A047);
  static const Color _bgColor = Color(0xFFF8FBF8);

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _resendTimer?.cancel();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Firebase Phone Auth
  // ────────────────────────────────────────────────────────────────────────────

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showSnack('Please enter your phone number');
      return;
    }
    final fullPhone = '$_selectedCountryCode$phone';

    setState(() => _isLoading = true);

    if (kIsWeb) {
      try {
        final confirmationResult = await FirebaseAuth.instance.signInWithPhoneNumber(fullPhone);
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _codeSent = true;
          _confirmationResult = confirmationResult;
        });
        _slideController.forward();
        _startResendTimer();
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showSnack('Verification failed: $e');
      }
    } else {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhone,
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification on Android (rare)
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          _showSnack(e.message ?? 'Verification failed. Check your number.');
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _codeSent = true;
            _verificationId = verificationId;
            _resendToken = resendToken;
          });
          _slideController.forward();
          _startResendTimer();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    }
  }

  void _startResendTimer() {
    _resendSeconds = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      _showSnack('Please enter the 6-digit OTP');
      return;
    }

    setState(() => _isLoading = true);

    if (kIsWeb) {
      try {
        if (_confirmationResult == null) {
          setState(() => _isLoading = false);
          _showSnack('Verification session expired. Please resend OTP.');
          return;
        }
        final userCredential = await _confirmationResult!.confirm(otp);
        final uid = userCredential.user!.uid;

        final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (!mounted) return;

        if (!userDoc.exists) {
          // New user — navigate to role selection
          setState(() => _isLoading = false);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
          );
          return;
        }

        final role = userDoc.data()?['role'];

        setState(() => _isLoading = false);

        if (role == 'admin') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
        } else if (role == 'donor') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const DonorDashboardScreen()));
        } else if (role == 'organization') {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const OrganizationDashboardScreen()));
        } else {
          _showSnack('Unknown account role. Please contact support.');
        }
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showSnack(e.message ?? 'Invalid OTP. Please try again.');
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showSnack('Something went wrong: $e');
      }
    } else {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );

      await _signInWithCredential(credential);
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final uid = userCredential.user!.uid;

      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!mounted) return;

      if (!userDoc.exists) {
        // New user — navigate to role selection
        setState(() => _isLoading = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
        );
        return;
      }

      final role = userDoc.data()?['role'];

      setState(() => _isLoading = false);

      if (role == 'admin') {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
      } else if (role == 'donor') {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const DonorDashboardScreen()));
      } else if (role == 'organization') {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => const OrganizationDashboardScreen()));
      } else {
        _showSnack('Unknown account role. Please contact support.');
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack(e.message ?? 'Invalid OTP. Please try again.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack('Something went wrong: $e');
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ────────────────────────────────────────────────────────────────────────────
  // UI
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                  child: _codeSent ? _buildOtpSection() : _buildPhoneSection(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B5E20), _green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_codeSent) {
                setState(() {
                  _codeSent = false;
                  for (final c in _otpControllers) {
                    c.clear();
                  }
                  _slideController.reset();
                });
              } else {
                Navigator.pop(context);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _codeSent ? 'Verify OTP' : 'Phone Login',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                _codeSent
                    ? 'Enter the code sent to your phone'
                    : 'Sign in with your mobile number',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────── Phone number entry ────────────
  Widget _buildPhoneSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.phone_android_rounded,
                color: _green, size: 40),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Enter your phone number',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF12202F),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'We\'ll send a 6-digit verification code to this number.',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 32),
        // Country code + phone input
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Country selector
              GestureDetector(
                onTap: _showCountryPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                  decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.08),
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _countries.firstWhere(
                                (c) => c['code'] == _selectedCountryCode)['flag'] ??
                            '🏳',
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _selectedCountryCode,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _green,
                          fontSize: 15,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down,
                          color: _green, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 2),
              // Phone number field
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF12202F),
                  ),
                  decoration: const InputDecoration(
                    hintText: '01XXXXXXXXX',
                    hintStyle: TextStyle(
                      color: Color(0xFFBDBDBD),
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildPrimaryButton(
          label: 'Send OTP',
          icon: Icons.send_rounded,
          onPressed: _isLoading ? null : _sendOtp,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            '🔒 Your number is safe. We don\'t share it.',
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.grey.shade500,
            ),
          ),
        ),
      ],
    );
  }

  // ──────────── OTP entry ────────────
  Widget _buildOtpSection() {
    final phone = _phoneController.text.trim();
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mark_email_read_rounded,
                  color: _green, size: 40),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Enter OTP',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF12202F),
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF6B7280), height: 1.5),
              children: [
                const TextSpan(text: 'Code sent to '),
                TextSpan(
                  text: '$_selectedCountryCode $phone',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF12202F),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          // 6 OTP boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) => _buildOtpBox(i)),
          ),
          const SizedBox(height: 36),
          _buildPrimaryButton(
            label: 'Verify & Sign In',
            icon: Icons.verified_rounded,
            onPressed: _isLoading ? null : _verifyOtp,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 28),
          // Resend timer
          Center(
            child: _resendSeconds > 0
                ? RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF6B7280)),
                      children: [
                        const TextSpan(text: 'Resend code in '),
                        TextSpan(
                          text: '${_resendSeconds}s',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: _green,
                          ),
                        ),
                      ],
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      for (final c in _otpControllers) {
                        c.clear();
                      }
                      _sendOtp();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: _green.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '🔄 Resend OTP',
                        style: TextStyle(
                          color: _green,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Color(0xFF12202F),
        ),
        decoration: InputDecoration(
          counterText: '',
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _green, width: 2.5),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (val) {
          if (val.isNotEmpty && index < 5) {
            _otpFocusNodes[index + 1].requestFocus();
          } else if (val.isEmpty && index > 0) {
            _otpFocusNodes[index - 1].requestFocus();
          }
          // Auto-verify when all 6 digits entered
          final otp = _otpControllers.map((c) => c.text).join();
          if (otp.length == 6 && !_isLoading) {
            _verifyOtp();
          }
        },
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_green, _greenLight],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Country',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF12202F),
              ),
            ),
            const SizedBox(height: 16),
            ..._countries.map((country) => ListTile(
                  leading: Text(
                    country['flag']!,
                    style: const TextStyle(fontSize: 28),
                  ),
                  title: Text(
                    country['name']!,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: Text(
                    country['code']!,
                    style: const TextStyle(
                      color: _green,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedCountryCode = country['code']!;
                    });
                    Navigator.pop(ctx);
                  },
                )),
          ],
        ),
      ),
    );
  }
}
