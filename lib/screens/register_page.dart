// lib/screens/register_page.dart
import 'package:flutter/material.dart';
import '../repository.dart';
import '../models/user.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final fullnameCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  String error = "";

  void register() async {
    final fname = fullnameCtrl.text.trim();
    final uname = usernameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final pass = passwordCtrl.text;

    if (fname.isEmpty || uname.isEmpty || pass.isEmpty) {
      setState(() {
        error = "Nama, username dan password wajib diisi.";
      });
      return;
    }

    final exists = await Repo.instance.findUserByUsername(uname);
    if (exists != null) {
      setState(() {
        error = "Username sudah dipakai.";
      });
      return;
    }

    final hashed = await Repo.instance.hashPassword(pass);

    final user = User(
      fullname: fname,
      username: uname,
      email: email,
      password: hashed,
    );

    await Repo.instance.createUser(user);
    // kembali ke login
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
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
            const Text("Create Account", style: TextStyle(fontSize: 22)),
            TextField(controller: fullnameCtrl, decoration: const InputDecoration(labelText: "Fullname")),
            TextField(controller: usernameCtrl, decoration: const InputDecoration(labelText: "Username")),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: passwordCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
            const SizedBox(height: 10),
            Text(error, style: const TextStyle(color: Colors.red)),
            ElevatedButton(onPressed: register, child: const Text("Register")),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              child: const Text("Already have account? Sign In"),
            ),
          ],
        ),
      ),
    );
  }
}
