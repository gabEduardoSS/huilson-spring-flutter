import 'package:flutter/material.dart';
import 'package:front/service/loginService.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.only(left: 50, right: 50, top: 40, bottom: 40),
          width: 500,
          height: 350,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text(
                  'Login',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 50,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Usuário',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    controller: _usernameController,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 50,
                  child: TextField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      filled: true,
                    fillColor: Colors.white,
                  ),
                  controller: _passwordController,
                ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (_usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                        sendLoginRequest(_usernameController.text, _passwordController.text);
                        setState(() {
                          _passwordController.clear();
                        });
                      }
                    },
                    child: const Text('Login'),
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