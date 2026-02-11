import 'package:flutter/material.dart';
import '../../widgets/dev_mode_banner.dart';

class FirstNameScreen extends StatefulWidget {
  const FirstNameScreen({super.key});
  @override
  State<FirstNameScreen> createState() => _FirstNameScreenState();
}

class _FirstNameScreenState extends State<FirstNameScreen> {
  final _ctrl = TextEditingController();
  bool get _isValid => RegExp(r"^[a-zA-ZÀ-ÿ '-]{2,50}$").hasMatch(_ctrl.text.trim());

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
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
                  value: 0.23,
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
                      const Text("What's your first name?", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("This is how it'll appear on your profile.", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      const SizedBox(height: 40),
                      TextField(
                        controller: _ctrl,
                        autofocus: true,
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(fontSize: 24),
                        decoration: InputDecoration(
                          hintText: 'First name',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: const UnderlineInputBorder(),
                          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFF6B6B), width: 2)),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isValid ? () => Navigator.pushNamed(context, '/onboarding/birthday') : null,
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
            onSkip: () => Navigator.pushNamed(context, '/onboarding/birthday'),
            label: 'Skip Name',
          ),
        ],
      ),
    );
  }
}
