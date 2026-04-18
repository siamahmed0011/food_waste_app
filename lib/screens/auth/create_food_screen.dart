import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateFoodScreen extends StatefulWidget {
  const CreateFoodScreen({super.key});

  @override
  State<CreateFoodScreen> createState() => _CreateFoodScreenState();
}

class _CreateFoodScreenState extends State<CreateFoodScreen> {
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _servesController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedCategory;
  String? _selectedCondition;
  DateTime? _pickupDate;
  TimeOfDay? _pickupTime;
  bool _isPublishing = false;

  final List<String> _categories = [
    'Cooked Food',
    'Dry Food',
    'Bakery',
    'Fruits',
    'Packaged Food',
  ];

  final List<String> _conditions = ['Fresh', 'Warm', 'Packed', 'Refrigerated'];

  @override
  void dispose() {
    _foodNameController.dispose();
    _quantityController.dispose();
    _servesController.dispose();
    _locationController.dispose();
    _expiryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (!context.mounted) return;

    if (picked != null) {
      setState(() {
        _pickupDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (!context.mounted) return;

    if (picked != null) {
      setState(() {
        _pickupTime = picked;
      });
    }
  }

  Future<void> _publishPost() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please sign in first')));
      return;
    }

    if (_foodNameController.text.trim().isEmpty ||
        _quantityController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty ||
        _selectedCategory == null ||
        _selectedCondition == null ||
        _pickupDate == null ||
        _pickupTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all important fields')),
      );
      return;
    }

    setState(() {
      _isPublishing = true;
    });

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final donorData = userDoc.data() ?? {};
      final donorName = (donorData['name'] ?? 'Donor').toString();

      await FirebaseFirestore.instance.collection('food_posts').add({
        'donorId': user.uid,
        'donorName': donorName,
        'foodName': _foodNameController.text.trim(),
        'quantity': _quantityController.text.trim(),
        'serves': _servesController.text.trim(),
        'location': _locationController.text.trim(),
        'expiry': _expiryController.text.trim(),
        'notes': _notesController.text.trim(),
        'category': _selectedCategory,
        'condition': _selectedCondition,
        'pickupDate': _formattedDate(),
        'pickupTime': _formattedTime(),
        'status': 'available',
        'createdAt': Timestamp.now(),
        'imageUrl': '',
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food post published successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (context.mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  String _formattedDate() {
    if (_pickupDate == null) return 'Select pickup date';
    return '${_pickupDate!.day}/${_pickupDate!.month}/${_pickupDate!.year}';
  }

  String _formattedTime() {
    if (_pickupTime == null) return 'Select pickup time';
    final hour = _pickupTime!.hourOfPeriod == 0
        ? 12
        : _pickupTime!.hourOfPeriod;
    final minute = _pickupTime!.minute.toString().padLeft(2, '0');
    final period = _pickupTime!.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
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
          'Post Food',
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
              const Text(
                'Create a donation post',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Share food details so nearby organizations can request pickup.',
                style: TextStyle(fontSize: 14.5, color: bodyColor, height: 1.6),
              ),
              const SizedBox(height: 22),
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
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _PickerCard(
                      label: 'Pickup Date',
                      value: _formattedDate(),
                      icon: Icons.calendar_today_outlined,
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PickerCard(
                      label: 'Pickup Time',
                      value: _formattedTime(),
                      icon: Icons.access_time_outlined,
                      onTap: _pickTime,
                    ),
                  ),
                ],
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
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FBF8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Preview Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _foodNameController.text.trim().isEmpty
                          ? 'Food name will appear here'
                          : _foodNameController.text.trim(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_selectedCategory ?? "Category"} • ${_quantityController.text.trim().isEmpty ? "Quantity" : _quantityController.text.trim()}',
                      style: const TextStyle(color: bodyColor, fontSize: 13.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _locationController.text.trim().isEmpty
                          ? 'Pickup location'
                          : _locationController.text.trim(),
                      style: const TextStyle(color: bodyColor, fontSize: 13.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPublishing ? null : _publishPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _isPublishing
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
                          'Publish Post',
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
                (item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
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

class _PickerCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
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
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: fieldBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(icon, color: bodyColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(color: bodyColor, fontSize: 14.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
