// lib/screens/login_page.dart
import 'package:flutter/material.dart';
import '../repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  String errorMsg = "";

  void login() async {
    String uname = usernameCtrl.text.trim();
    String pass = passwordCtrl.text;

    final user = await Repo.instance.login(uname, pass);
    if (user != null) {
      // bisa simpan info user di navigator / state management; untuk sementara pindah ke menu
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/menu', arguments: user.username);
    } else {
      setState(() {
        errorMsg = "Username atau password salah!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag, size: 80, color: Colors.blue),
            const Text("WELCOME BACK!", style: TextStyle(fontSize: 22)),
            TextField(controller: usernameCtrl, decoration: const InputDecoration(labelText: "Username")),
            TextField(controller: passwordCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
            const SizedBox(height: 10),
            Text(errorMsg, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: login, child: const Text("Login")),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text("Create Account"),
            ),
          ],
        ),
      ),
    );
  }
}
