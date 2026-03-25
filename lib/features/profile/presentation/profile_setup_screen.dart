import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/visi_rive_logo.dart';
import '../providers/profile_notifier.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _locationFocusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _nameFocusNode.dispose();
    _locationFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const VisiRiveLogo(),

              const SizedBox(height: 32),

              TextField(
                controller: _nameController,
                focusNode: _nameFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Jak Cię nazywać?',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _locationController,
                focusNode: _locationFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Gdzie pracujesz? (np. Hamar)',
                  border: OutlineInputBorder(),
                ),
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: () {
                  final name = _nameController.text.trim();
                  final location = _locationController.text.trim();
                  if (name.isEmpty) return;
                  ref
                      .read(profileNotifierProvider.notifier)
                      .updateProfile(name: name, location: location);
                },
                child: const Text('Zapisz profil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
