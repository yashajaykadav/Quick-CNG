// lib/screens/verification_form_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerificationFormScreen extends StatefulWidget {
  const VerificationFormScreen({super.key});

  @override
  State<VerificationFormScreen> createState() => _VerificationFormScreenState();
}

class _VerificationFormScreenState extends State<VerificationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _stationController = TextEditingController();
  final _contactController = TextEditingController();
  String _selectedRole = 'worker';
  bool _isSubmitting = false;

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final user = FirebaseAuth.instance.currentUser;

    try {
      await FirebaseFirestore.instance.collection('verification_requests').add({
        'userId': user?.uid,
        'fullName': _nameController.text.trim(),
        'stationName': _stationController.text.trim(),
        'contact': _contactController.text.trim(),
        'role': _selectedRole,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Request submitted! Admin will verify soon.")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify as Worker/Owner")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text("Submit details for manual verification by Admin.",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 25),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? "Enter your name" : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _stationController,
              decoration: const InputDecoration(labelText: "Station Name", border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? "Enter station name" : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _contactController,
              decoration: const InputDecoration(labelText: "Contact Number", border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? "Enter contact info" : null,
            ),
            const SizedBox(height: 16),

            const Text("I am applying as:", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Radio(value: 'worker', groupValue: _selectedRole, onChanged: (v) => setState(() => _selectedRole = v as String)),
                const Text("Worker"),
                Radio(value: 'owner', groupValue: _selectedRole, onChanged: (v) => setState(() => _selectedRole = v as String)),
                const Text("Owner"),
              ],
            ),
            const SizedBox(height: 30),

            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRequest,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit Request", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}