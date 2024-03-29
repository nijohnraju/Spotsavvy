import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:panigale/custom.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

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
              const SizedBox(height: 65),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.black, // Change the color to your preference
                ),
                child: Text(
                  'About Us',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Change the color to your preference
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutUsPage()),
                  );
                },
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
                  'Sign Out',
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

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'This is the About Us page.',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
