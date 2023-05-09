import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:panigale/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:panigale/custom.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _inscription = false;

  Future signIn() async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException {
      return const Center(child: Text('Something went wrong'));
    }
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  Future signUp() async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      addUserDetails(
        _name.text.trim(),
        _emailController.text.trim(),
        _phone.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      return Center(child: Text('Something went wrong $e'));
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  Future addUserDetails(String name, String email, String phone) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid.toString();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({'Name': name, 'Email': email, 'Phone': phone, 'uid': uid});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 150,
                  width: 320,
                  child: Image(
                    image: AssetImage("assets/images/logo.png"),
                    fit: BoxFit.fitWidth,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Visibility(
                  visible: _inscription,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: customDecoration(),
                    child: TextField(
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                      controller: _name,
                      decoration: InputDecoration(
                        hintText: "Name",
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: blacksavvy,
                          fontWeight: FontWeight.normal,
                        ),
                        prefixIcon:
                            Icon(Icons.person_outline, color: greensavvy),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: _inscription,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: customDecoration(),
                    child: TextField(
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                      controller: _phone,
                      decoration: InputDecoration(
                        hintText: "Phone",
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: blacksavvy,
                          fontWeight: FontWeight.normal,
                        ),
                        prefixIcon: Icon(
                          Icons.smartphone,
                          color: greensavvy,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: customDecoration(),
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: "Email",
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: blacksavvy,
                        fontWeight: FontWeight.normal,
                      ),
                      prefixIcon: Icon(
                        Icons.mail_outline,
                        color: greensavvy,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: customDecoration(),
                  child: TextField(
                    obscureText: true,
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: "Password",
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: blacksavvy,
                        fontWeight: FontWeight.normal,
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: greensavvy,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: !_inscription,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Forgot password ?",
                        style: TextStyle(
                            color: greensavvy,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: _inscription ? 30 : 0,
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: greensavvy,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  icon: const Icon(
                    Icons.lock_open,
                    size: 32,
                    color: Color.fromARGB(203, 28, 28, 28),
                  ),
                  label: Text(
                    _inscription ? "Sign Up" : "Sign In",
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                  onPressed: !_inscription ? signIn : signUp,
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _inscription = !_inscription;
                    });
                  },
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: InkWell(
                        child: RichText(
                          text: TextSpan(
                            text: _inscription
                                ? "Do you have an account ? "
                                : "New User ?",
                            style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                            children: [
                              TextSpan(
                                text: _inscription
                                    ? "Sign in"
                                    : " Create an account",
                                style: TextStyle(
                                    color: greensavvy,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
