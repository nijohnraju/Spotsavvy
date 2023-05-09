import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:panigale/custom.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Text(
                'Signed In as',
                style: TextStyle(color: blacksavvy, fontSize: 18),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                user.email!,
                style: TextStyle(
                    color: blacksavvy,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              const SizedBox(
                height: 40,
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: greensavvy,
                ),
                icon: Icon(
                  Icons.arrow_back,
                  size: 32,
                  color: blacksavvy,
                ),
                label: Text(
                  'sign out',
                  style: TextStyle(
                      fontSize: 24,
                      color: blacksavvy,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () => FirebaseAuth.instance.signOut(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
