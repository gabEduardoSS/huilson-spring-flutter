import 'package:flutter/material.dart';
import 'package:front/service/loginService.dart';
import 'package:front/widgets/topMessage.dart';
import 'package:front/service/apiCheck.dart';
import 'package:front/service/apiException.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarApi();
    });
  }

  Future<void> _verificarApi() async {
    try {
      await checkApiStatus();
    } on ApiException catch (e) {
      if (!mounted) return;
      TopMessage.show(context, e.message);
    }
  }

  Future<void> _login() async{
      if (_usernameController.text.isEmpty || _passwordController.text.isEmpty){
          TopMessage.show(context, "Preencha usuário e senha");
          return;
      }
      try{
        String? res = await sendLoginRequest(_usernameController.text, _passwordController.text);
        if(!mounted) return;
        if(res == "200"){
          TopMessage.show(context, "Logado com sucesso", color: Colors.green);
        } else if (res == "401"){
          TopMessage.show(context, "Credenciais inválidas");
        } else {
          TopMessage.show(context, "Erro ao logar");
        }

      } on ApiException catch (e){
        if(!mounted) return;
        TopMessage.show(context, e.message);
      } finally{
          setState(() {    
            _passwordController.clear();
          });
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        _login();
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