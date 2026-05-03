import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = AuthService();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final majorController = TextEditingController();

  String? error;
  bool loading = false;

  Future<void> register() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      await _auth.registerStudent(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        major: majorController.text,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email (.edu)"),
            ),
            TextField(
              controller: majorController,
              decoration: InputDecoration(labelText: "Major"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),

            if (error != null)
              Text(error!, style: TextStyle(color: Colors.red)),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : register,
              child: Text("Register"),
            ),

            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
              child: Text("Login instead"),
            ),
          ],
        ),
      ),
    );
  }
}
