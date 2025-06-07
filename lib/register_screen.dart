import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers with default values
  final TextEditingController _nameController = TextEditingController(
    text: "John Doe",
  );
  final TextEditingController _bioController = TextEditingController(
    text: "Passionate software developer and outdoor enthusiast.",
  );
  final TextEditingController _profilePictureUrlController =
      TextEditingController(text: "https://example.com/profile.jpg");
  final TextEditingController _preferencesController = TextEditingController(
    text: "Loves hiking, coffee, and sci-fi movies.",
  );

  Future<void> _registerUser() async {
    final url = Uri.parse(
      'http://user-service:8082/api/UserProfiles',
    ); // Replace with your API URL
    final body = jsonEncode({
      'name': _nameController.text,
      'bio': _bioController.text,
      'profilePictureUrl': _profilePictureUrlController.text,
      'preferences': _preferencesController.text,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        // Registration successful
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
      } else {
        // Handle errors
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${response.body}')));
      }
    } catch (e) {
      // Handle network errors
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
              ),
              TextField(
                controller: _profilePictureUrlController,
                decoration: const InputDecoration(
                  labelText: 'Profile Picture URL',
                ),
              ),
              TextField(
                controller: _preferencesController,
                decoration: const InputDecoration(labelText: 'Preferences'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerUser,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
