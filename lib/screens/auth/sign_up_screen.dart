import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  final String role;

  const SignUpScreen({super.key, required this.role});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ownerController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController roadController = TextEditingController();
  final TextEditingController houseController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? selectedOrganizationType;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  final List<String> organizationTypes = [
    'NGO',
    'Food Bank',
    'Charity Foundation',
    'Volunteer Group',
    'Community Organization',
  ];

  bool get isOrg => widget.role.toLowerCase() == "ngo";

  @override
  void dispose() {
    nameController.dispose();
    ownerController.dispose();
    phoneController.dispose();
    emailController.dispose();
    districtController.dispose();
    cityController.dispose();
    roadController.dispose();
    houseController.dispose();
    addressController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signUpUser() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;

      if (widget.role == "donor") {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'role': 'donor',
          'name': nameController.text.trim(),
          'phone': phoneController.text.trim(),
          'email': emailController.text.trim(),
          'district': districtController.text.trim(),
          'city': cityController.text.trim(),
          'roadNo': roadController.text.trim(),
          'houseNo': houseController.text.trim(),
          'createdAt': Timestamp.now(),
        });

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/donorDashboard');
      } else {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'role': 'organization',
          'organizationName': nameController.text.trim(),
          'ownerName': ownerController.text.trim(),
          'phone': phoneController.text.trim(),
          'email': emailController.text.trim(),
          'organizationType': selectedOrganizationType ?? '',
          'address': addressController.text.trim(),
          'createdAt': Timestamp.now(),
        });

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/organizationDashboard');
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = 'Signup failed';

      if (e.code == 'email-already-in-use') {
        message = 'This email is already in use';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak';
      } else if (e.message != null && e.message!.isNotEmpty) {
        message = e.message!;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _inputLabel(String title, {bool required = false}) {
    const titleColor = Color(0xFF12202F);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: title,
          style: const TextStyle(
            fontSize: 13.6,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
          children: required
              ? const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
                ]
              : [],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint, {
    Widget? suffixIcon,
    IconData? prefixIcon,
  }) {
    const borderColor = Color(0xFFE3E8E4);
    const fieldBg = Color(0xFFF9FBFA);
    const bodyColor = Color(0xFF6B7280);
    const titleColor = Color(0xFF12202F);

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: bodyColor,
        fontSize: 14.5,
      ),
      filled: true,
      fillColor: fieldBg,
      prefixIcon: prefixIcon != null
          ? Icon(
              prefixIcon,
              color: bodyColor,
              size: 21,
            )
          : null,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: titleColor,
          width: 1.2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool requiredField = false,
    bool obscure = false,
    Widget? suffixIcon,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _inputLabel(label, required: requiredField),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: _inputDecoration(
            hint,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
          ),
          validator: validator,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF6F7F9);
    const primary = Color(0xFF2E7D32);
    const titleColor = Color(0xFF12202F);
    const bodyColor = Color(0xFF6B7280);
    const cardBorder = Color(0xFFE6EBE7);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              decoration: BoxDecoration(
                color:
                    isOrg ? const Color(0xFFF8F5FF) : const Color(0xFFF2F8F1),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(34),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 46,
                          width: 46,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: titleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      isOrg
                          ? Icons.apartment_rounded
                          : Icons.volunteer_activism_rounded,
                      size: 58,
                      color: isOrg ? const Color(0xFF7B61FF) : primary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    isOrg ? 'Join as Organization' : 'Become a Donor',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isOrg
                        ? 'Create your organization account to receive and manage food donations.'
                        : 'Create your donor account to share safe surplus food with nearby organizations.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: bodyColor,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: cardBorder),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            if (isOrg) ...[
                              _buildTextField(
                                label: 'Organization Name',
                                controller: nameController,
                                hint: 'Enter organization name',
                                requiredField: true,
                                prefixIcon: Icons.business_rounded,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter organization name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Owner Name',
                                controller: ownerController,
                                hint: 'Enter owner / contact person',
                                requiredField: true,
                                prefixIcon: Icons.person_outline_rounded,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter owner name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Phone',
                                controller: phoneController,
                                hint: '+8801XXXXXXXXX',
                                prefixIcon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Email Address',
                                controller: emailController,
                                hint: 'Enter your email',
                                requiredField: true,
                                prefixIcon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Enter valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: _inputLabel('Organization Type'),
                              ),
                              DropdownButtonFormField<String>(
                                initialValue: selectedOrganizationType,
                                items: organizationTypes.map((type) {
                                  return DropdownMenuItem<String>(
                                    value: type,
                                    child: Text(type),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedOrganizationType = value;
                                  });
                                },
                                decoration: _inputDecoration(
                                  'Select type (optional)',
                                  prefixIcon: Icons.category_outlined,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Address',
                                controller: addressController,
                                hint: 'Area, City, District',
                                prefixIcon: Icons.location_on_outlined,
                              ),
                            ] else ...[
                              _buildTextField(
                                label: 'Donor Name',
                                controller: nameController,
                                hint: 'Enter full name',
                                requiredField: true,
                                prefixIcon: Icons.person_outline_rounded,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter donor name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Phone',
                                controller: phoneController,
                                hint: '+8801XXXXXXXXX',
                                prefixIcon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Email Address',
                                controller: emailController,
                                hint: 'Enter your email',
                                requiredField: true,
                                prefixIcon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Enter valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'District',
                                controller: districtController,
                                hint: 'e.g. Dhaka',
                                prefixIcon: Icons.map_outlined,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'City',
                                controller: cityController,
                                hint: 'e.g. Mirpur',
                                prefixIcon: Icons.location_city_outlined,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Road No.',
                                controller: roadController,
                                hint: 'Road number',
                                prefixIcon: Icons.alt_route_rounded,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'House No.',
                                controller: houseController,
                                hint: 'House number',
                                prefixIcon: Icons.home_outlined,
                              ),
                            ],

                            const SizedBox(height: 16),

                            _buildTextField(
                              label: 'Password',
                              controller: passwordController,
                              hint: 'Enter password',
                              requiredField: true,
                              obscure: obscurePassword,
                              prefixIcon: Icons.lock_outline_rounded,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: bodyColor,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter password';
                                }
                                if (value.length < 6) {
                                  return 'Minimum 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Confirm Password',
                              controller: confirmPasswordController,
                              hint: 'Confirm password',
                              requiredField: true,
                              obscure: obscureConfirmPassword,
                              prefixIcon: Icons.lock_reset_rounded,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscureConfirmPassword =
                                        !obscureConfirmPassword;
                                  });
                                },
                                icon: Icon(
                                  obscureConfirmPassword
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: bodyColor,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm password';
                                }
                                if (value != passwordController.text) {
                                  return 'Password does not match';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          signUpUser();
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isOrg
                                      ? const Color(0xFF7B61FF)
                                      : primary,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: (isOrg
                                          ? const Color(0xFF7B61FF)
                                          : primary)
                                      .withValues(alpha: 0.5),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.6,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        isOrg
                                            ? 'Create Organization Account'
                                            : 'Create Donor Account',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: const TextStyle(
                            color: bodyColor,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: primary,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'By creating an account you agree to our Terms and Conditions and Privacy Policy.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: bodyColor,
                          fontSize: 13.2,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}