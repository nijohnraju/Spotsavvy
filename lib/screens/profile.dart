import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  String? _name;
  @override
  void initState(){
    super.initState();
    _getCurrentUserName();
  }

  Future<void> _getCurrentUserName() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid.toString();

    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    String name = userSnapshot.get('Name');

    setState(() {
      _name = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Text(_name.toString());
  }
}