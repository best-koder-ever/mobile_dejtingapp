import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/wizard_models.dart';

/// Wizard Step 1: Basic profile information (name, DOB, gender)
/// Matches backend: PATCH /api/wizard/step/1
class BasicInfoStep extends StatefulWidget {
  final WizardStepBasicInfoDto? initialData;
  final Function(WizardStepBasicInfoDto) onDataChanged;

  const BasicInfoStep({
    super.key,
    this.initialData,
    required this.onDataChanged,
  });

  @override
  State<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends State<BasicInfoStep> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  DateTime? _selectedDate;
  String? _selectedGender;

  final List<String> _genderOptions = ['Male', 'Female', 'Non-binary', 'Other'];

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.initialData?.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.initialData?.lastName ?? '');
    _selectedDate = widget.initialData?.dateOfBirth;
    _selectedGender = widget.initialData?.gender;

    // Notify parent on init if data exists
    if (widget.initialData != null) {
      widget.onDataChanged(widget.initialData!);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _notifyParent() {
    if (_firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _selectedDate != null &&
        _selectedGender != null) {
      final dto = WizardStepBasicInfoDto(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        dateOfBirth: _selectedDate!,
        gender: _selectedGender!,
      );
      widget.onDataChanged(dto);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Icon(Icons.person, size: 72, color: Colors.pink[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'Let\'s Get to Know You',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start by sharing some basic information',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // First Name
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                hintText: 'Enter your first name',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              textCapitalization: TextCapitalization.words,
              inputFormatters: [
                LengthLimitingTextInputFormatter(50),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your first name';
                }
                return null;
              },
              onChanged: (_) => _notifyParent(),
            ),
            const SizedBox(height: 20),

            // Last Name
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                hintText: 'Enter your last name',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              textCapitalization: TextCapitalization.words,
              inputFormatters: [
                LengthLimitingTextInputFormatter(50),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your last name';
                }
                return null;
              },
              onChanged: (_) => _notifyParent(),
            ),
            const SizedBox(height: 20),

            // Date of Birth
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  hintText: 'Select your date of birth',
                  prefixIcon: const Icon(Icons.cake_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                child: _selectedDate == null
                    ? Text(
                        'Tap to select',
                        style: TextStyle(color: Colors.grey[600]),
                      )
                    : Text(
                        '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
            if (_selectedDate != null && !_isAgeValid())
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 12),
                child: Text(
                  'You must be at least 18 years old',
                  style: TextStyle(color: Colors.red[700], fontSize: 12),
                ),
              ),
            const SizedBox(height: 20),

            // Gender
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: InputDecoration(
                labelText: 'Gender',
                hintText: 'Select your gender',
                prefixIcon: const Icon(Icons.wc_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: _genderOptions.map((gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select your gender';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
                _notifyParent();
              },
            ),
            const SizedBox(height: 32),

            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your information is private and will only be used to create your profile',
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isAgeValid() {
    if (_selectedDate == null) return true;
    final age = DateTime.now().difference(_selectedDate!).inDays ~/ 365;
    return age >= 18;
  }

  Future<void> _selectDate() async {
    final initialDate = _selectedDate ??
        DateTime(
          DateTime.now().year - 25, // Default to 25 years ago
          DateTime.now().month,
          DateTime.now().day,
        );

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      helpText: 'Select Your Date of Birth',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.pink[400]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
      _notifyParent();
    }
  }
}
