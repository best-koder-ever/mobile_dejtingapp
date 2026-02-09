import 'package:flutter/material.dart';
import '../../widgets/dev_mode_banner.dart';

class BirthdayScreen extends StatefulWidget {
  const BirthdayScreen({super.key});
  @override
  State<BirthdayScreen> createState() => _BirthdayScreenState();
}

class _BirthdayScreenState extends State<BirthdayScreen> {
  int? _month;
  final _dayCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();

  bool get _isValid {
    if (_month == null) return false;
    final d = int.tryParse(_dayCtrl.text);
    final y = int.tryParse(_yearCtrl.text);
    if (d == null || y == null) return false;
    if (y < 1900 || y > DateTime.now().year) return false;
    if (d < 1 || d > DateUtils.getDaysInMonth(y, _month!)) return false;
    return _calcAge(DateTime(y, _month!, d)) >= 18;
  }

  int _calcAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) age--;
    return age;
  }

  void _next() {
    final d = int.parse(_dayCtrl.text);
    final y = int.parse(_yearCtrl.text);
    final dob = DateTime(y, _month!, d);
    if (_calcAge(dob) < 18) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("Age Requirement"),
          content: const Text("You must be 18 or older to use this app."),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Go back"))],
        ),
      );
      return;
    }
    Navigator.pushNamed(context, '/onboarding/gender');
  }

  void _onChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    _dayCtrl.addListener(_onChanged);
    _yearCtrl.addListener(_onChanged);
  }

  @override
  void dispose() {
    _dayCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.popUntil(context, (route) => route.isFirst))],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.42,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFFF6B6B)),
                  minHeight: 4,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Your b-day?", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<int>(
                              value: _month,
                              decoration: const InputDecoration(labelText: "Month", border: OutlineInputBorder()),
                              items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text("${i + 1}"))),
                              onChanged: (v) => setState(() => _month = v),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _dayCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: "Day", border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: _yearCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: "Year", border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text("Your profile shows your age, not your birthdate.", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isValid ? _next : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isValid ? const Color(0xFFFF6B6B) : Colors.grey,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                          ),
                          child: const Text("Next", style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          DevModeSkipButton(
            onSkip: () => Navigator.pushNamed(context, '/onboarding/gender'),
            label: 'Skip Birthday',
          ),
        ],
      ),
    );
  }
}
