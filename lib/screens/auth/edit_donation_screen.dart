import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditDonationScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> donationData;

  const EditDonationScreen({
    super.key,
    required this.docId,
    required this.donationData,
  });

  @override
  State<EditDonationScreen> createState() => _EditDonationScreenState();
}

class _EditDonationScreenState extends State<EditDonationScreen> {
  late final TextEditingController _foodNameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _locationController;
  late final TextEditingController _expiryController;
  late final TextEditingController _notesController;
  late final TextEditingController _servesController;

  String? _selectedCategory;
  String? _selectedCondition;
  bool _isSaving = false;

  final List<String> _categories = const [
    'Cooked Food',
    'Dry Food',
    'Bakery',
    'Fruits',
    'Packaged Food',
  ];

  final List<String> _conditions = const [
    'Fresh',
    'Warm',
    'Packed',
    'Refrigerated',
  ];

  @override
  void initState() {
    super.initState();
    final data = widget.donationData;

    _foodNameController =
        TextEditingController(text: (data['foodName'] ?? '').toString());
    _quantityController =
        TextEditingController(text: (data['quantity'] ?? '').toString());
    _locationController =
        TextEditingController(text: (data['location'] ?? '').toString());
    _expiryController =
        TextEditingController(text: (data['expiry'] ?? '').toString());
    _notesController =
        TextEditingController(text: (data['notes'] ?? '').toString());
    _servesController =
        TextEditingController(text: (data['serves'] ?? '').toString());

    _selectedCategory = data['category']?.toString();
    _selectedCondition = data['condition']?.toString();
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    _expiryController.dispose();
    _notesController.dispose();
    _servesController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_foodNameController.text.trim().length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food name must be at least 3 characters')),
      );
      return;
    }

    if (_quantityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter quantity')),
      );
      return;
    }

    if (_locationController.text.trim().length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid pickup location')),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select food category')),
      );
      return;
    }

    if (_selectedCondition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select food condition')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('food_posts')
          .doc(widget.docId)
          .update({
        'foodName': _foodNameController.text.trim(),
        'quantity': _quantityController.text.trim(),
        'location': _locationController.text.trim(),
        'expiry': _expiryController.text.trim(),
        'notes': _notesController.text.trim(),
        'serves': _servesController.text.trim(),
        'category': _selectedCategory,
        'condition': _selectedCondition,
        'updatedAt': Timestamp.now(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFFF6F7F9);
    const Color primary = Color(0xFF2E7D32);
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF6B7280);
    const Color borderColor = Color(0xFFE3E8E4);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        foregroundColor: titleColor,
        title: const Text(
          'Edit Donation',
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
                color: Colors.black.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle('Basic Info'),
              const SizedBox(height: 12),
              _InputField(
                controller: _foodNameController,
                label: 'Food Name',
                hintText: 'e.g. Rice, Curry, Bread',
                icon: Icons.fastfood_outlined,
              ),
              const SizedBox(height: 14),
              _DropdownField(
                label: 'Food Category',
                value: _selectedCategory,
                items: _categories,
                icon: Icons.category_outlined,
                hint: 'Select category',
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 14),
              _InputField(
                controller: _quantityController,
                label: 'Quantity',
                hintText: 'e.g. 20 meal packs',
                icon: Icons.inventory_2_outlined,
              ),
              const SizedBox(height: 14),
              _InputField(
                controller: _servesController,
                label: 'Serves People',
                hintText: 'e.g. 15 people',
                icon: Icons.groups_outlined,
              ),
              const SizedBox(height: 22),
              const _SectionTitle('Pickup Details'),
              const SizedBox(height: 12),
              _InputField(
                controller: _locationController,
                label: 'Pickup Location',
                hintText: 'e.g. Mirpur, Dhaka',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 22),
              const _SectionTitle('Safety Info'),
              const SizedBox(height: 12),
              _DropdownField(
                label: 'Food Condition',
                value: _selectedCondition,
                items: _conditions,
                icon: Icons.verified_outlined,
                hint: 'Select condition',
                onChanged: (value) {
                  setState(() {
                    _selectedCondition = value;
                  });
                },
              ),
              const SizedBox(height: 14),
              _InputField(
                controller: _expiryController,
                label: 'Expiry / Best Before',
                hintText: 'e.g. Best before 8:00 PM',
                icon: Icons.timer_outlined,
              ),
              const SizedBox(height: 14),
              _InputField(
                controller: _notesController,
                label: 'Notes',
                hintText: 'Add condition, packaging, urgent pickup details',
                icon: Icons.notes_outlined,
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1D2939),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final int maxLines;

  const _InputField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    const Color borderColor = Color(0xFFE3E8E4);
    const Color bodyColor = Color(0xFF6B7280);
    const Color fieldBg = Color(0xFFF9FBFA);
    const Color titleColor = Color(0xFF1D2939);

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
            hintText: hintText,
            hintStyle: const TextStyle(color: bodyColor, fontSize: 14.5),
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
              borderSide: const BorderSide(color: titleColor, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final IconData icon;
  final String hint;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.icon,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const Color borderColor = Color(0xFFE3E8E4);
    const Color bodyColor = Color(0xFF6B7280);
    const Color fieldBg = Color(0xFFF9FBFA);
    const Color titleColor = Color(0xFF1D2939);

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
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: bodyColor),
            filled: true,
            fillColor: fieldBg,
            prefixIcon: Icon(icon, color: bodyColor),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: titleColor, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}