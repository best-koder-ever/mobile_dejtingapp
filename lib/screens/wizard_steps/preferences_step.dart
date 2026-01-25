import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/wizard_models.dart';

/// Wizard Step 2: Search preferences (who you're looking for)
/// Matches backend: PATCH /api/wizard/step/2
class PreferencesStep extends StatefulWidget {
  final WizardStepPreferencesDto? initialData;
  final Function(WizardStepPreferencesDto) onDataChanged;

  const PreferencesStep({
    super.key,
    this.initialData,
    required this.onDataChanged,
  });

  @override
  State<PreferencesStep> createState() => _PreferencesStepState();
}

class _PreferencesStepState extends State<PreferencesStep> {
  String? _preferredGender;
  int _minAge = 18;
  int _maxAge = 35;
  int _maxDistance = 50; // km
  final TextEditingController _bioController = TextEditingController();

  final List<String> _genderOptions = ['Male', 'Female', 'Everyone', 'Non-binary'];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _preferredGender = widget.initialData!.preferredGender;
      _minAge = widget.initialData!.minAge ?? 18;
      _maxAge = widget.initialData!.maxAge ?? 35;
      _maxDistance = widget.initialData!.maxDistance ?? 50;
      _bioController.text = widget.initialData!.bio ?? '';
    }
    _notifyParent();
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  void _notifyParent() {
    final dto = WizardStepPreferencesDto(
      preferredGender: _preferredGender,
      minAge: _minAge,
      maxAge: _maxAge,
      maxDistance: _maxDistance,
      bio: _bioController.text.isNotEmpty ? _bioController.text : null,
    );
    widget.onDataChanged(dto);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Column(
              children: [
                Icon(Icons.favorite_border, size: 72, color: Colors.pink[300]),
                const SizedBox(height: 16),
                const Text(
                  'Who Are You Looking For?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Set your search preferences',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Preferred Gender
          const Text(
            'Interested in',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _genderOptions.map((gender) {
              final isSelected = _preferredGender == gender;
              return ChoiceChip(
                label: Text(gender),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _preferredGender = selected ? gender : null;
                  });
                  _notifyParent();
                },
                selectedColor: Colors.pink[400],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[800],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                backgroundColor: Colors.grey[100],
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Age Range
          const Text(
            'Age Range',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Between $_minAge and $_maxAge years old',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                RangeSlider(
                  values: RangeValues(_minAge.toDouble(), _maxAge.toDouble()),
                  min: 18,
                  max: 100,
                  divisions: 82,
                  activeColor: Colors.pink[400],
                  labels: RangeLabels(_minAge.toString(), _maxAge.toString()),
                  onChanged: (values) {
                    setState(() {
                      _minAge = values.start.round();
                      _maxAge = values.end.round();
                    });
                    _notifyParent();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Distance
          const Text(
            'Maximum Distance',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Up to $_maxDistance km away',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Slider(
                  value: _maxDistance.toDouble(),
                  min: 1,
                  max: 300,
                  divisions: 299,
                  activeColor: Colors.pink[400],
                  label: '$_maxDistance km',
                  onChanged: (value) {
                    setState(() {
                      _maxDistance = value.round();
                    });
                    _notifyParent();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Bio (optional)
          const Text(
            'Write a short bio (Optional)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bioController,
            decoration: InputDecoration(
              hintText: 'Tell potential matches a bit about yourself...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[50],
              counterText: '${_bioController.text.length}/500',
              helperText: 'You can add this later if you prefer',
              helperStyle: TextStyle(color: Colors.grey[600]),
            ),
            maxLines: 4,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
            inputFormatters: [
              LengthLimitingTextInputFormatter(500),
            ],
            onChanged: (_) {
              setState(() {}); // Update counter
              _notifyParent();
            },
          ),
          const SizedBox(height: 24),

          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.orange[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You can adjust these preferences anytime from your settings',
                    style: TextStyle(
                      color: Colors.orange[900],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
