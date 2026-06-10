import 'package:flutter/material.dart';

class EditOrganizationProfileScreen extends StatefulWidget {
  final Map<String, String> initialData;

  const EditOrganizationProfileScreen({
    super.key,
    required this.initialData,
  });

  @override
  State<EditOrganizationProfileScreen> createState() =>
      _EditOrganizationProfileScreenState();
}

class _EditOrganizationProfileScreenState
    extends State<EditOrganizationProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _websiteController;
  late final TextEditingController _addressController;
  late final TextEditingController _serviceAreaController;
  late final TextEditingController _aboutController;
  late final TextEditingController _hoursController;
  late final TextEditingController _pickupController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialData['name'] ?? '');
    _emailController =
        TextEditingController(text: widget.initialData['email'] ?? '');
    _phoneController =
        TextEditingController(text: widget.initialData['phone'] ?? '');
    _websiteController =
        TextEditingController(text: widget.initialData['website'] ?? '');
    _addressController =
        TextEditingController(text: widget.initialData['address'] ?? '');
    _serviceAreaController =
        TextEditingController(text: widget.initialData['serviceArea'] ?? '');
    _aboutController =
        TextEditingController(text: widget.initialData['about'] ?? '');
    _hoursController =
        TextEditingController(text: widget.initialData['hours'] ?? '');
    _pickupController =
        TextEditingController(text: widget.initialData['pickup'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _serviceAreaController.dispose();
    _aboutController.dispose();
    _hoursController.dispose();
    _pickupController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all important fields'),
        ),
      );
      return;
    }

    Navigator.pop(context, {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'website': _websiteController.text.trim(),
      'address': _addressController.text.trim(),
      'serviceArea': _serviceAreaController.text.trim(),
      'about': _aboutController.text.trim(),
      'hours': _hoursController.text.trim(),
      'pickup': _pickupController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFFF6F7F9);
    const Color primary = Color(0xFFF57C00);
    const Color titleColor = Color(0xFF1D2939);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        foregroundColor: titleColor,
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
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
              _EditField(
                controller: _nameController,
                label: 'Organization Name',
                hint: 'Enter organization name',
                icon: Icons.apartment_rounded,
              ),
              const SizedBox(height: 14),
              _EditField(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter email',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 14),
              _EditField(
                controller: _phoneController,
                label: 'Phone',
                hint: 'Enter phone number',
                icon: Icons.call_outlined,
              ),
              const SizedBox(height: 14),
              _EditField(
                controller: _websiteController,
                label: 'Website',
                hint: 'Enter website',
                icon: Icons.language_outlined,
              ),
              const SizedBox(height: 14),
              _EditField(
                controller: _addressController,
                label: 'Address',
                hint: 'Enter full address',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 14),
              _EditField(
                controller: _serviceAreaController,
                label: 'Service Area',
                hint: 'e.g. Mirpur, Uttara, Dhanmondi',
                icon: Icons.map_outlined,
              ),
              const SizedBox(height: 14),
              _EditField(
                controller: _hoursController,
                label: 'Operating Hours',
                hint: 'e.g. 9 AM to 9 PM',
                icon: Icons.access_time_outlined,
              ),
              const SizedBox(height: 14),
              _EditField(
                controller: _pickupController,
                label: 'Pickup Capability',
                hint: 'Describe your pickup capability',
                icon: Icons.local_shipping_outlined,
              ),
              const SizedBox(height: 14),
              _EditField(
                controller: _aboutController,
                label: 'About Organization',
                hint: 'Write about your organization',
                icon: Icons.info_outline_rounded,
                maxLines: 4,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;

  const _EditField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF6B7280);
    const Color borderColor = Color(0xFFE3E8E4);
    const Color fieldBg = Color(0xFFF9FBFA);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: bodyColor,
              fontSize: 14.5,
            ),
            filled: true,
            fillColor: fieldBg,
            prefixIcon: maxLines == 1 ? Icon(icon, color: bodyColor) : null,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: maxLines == 1 ? 16 : 18,
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
          ),
        ),
      ],
    );
  }
}