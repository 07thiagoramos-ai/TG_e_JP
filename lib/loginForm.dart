import 'package:flutter/material.dart';
import 'package:tg_e_jp/authentication.dart';
import 'package:tg_e_jp/cadastroForm.dart';
import 'package:tg_e_jp/funcao/widget.dart';
import 'package:tg_e_jp/telaInicial.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _chaveFormulario = GlobalKey<FormState>();

  String? email;
  String? senha;

  bool _carregando = false;

  Future<void> _entrar() async {
    if (!_chaveFormulario.currentState!.validate()) return;
    _chaveFormulario.currentState!.save();

    setState(() => _carregando = true);

    final resultado = await Authentication().signIn(
      email: email!,
      senha: senha!,
    );

    if (!mounted) return;

    setState(() => _carregando = false);

    if (resultado != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Authentication().traduzirRetorno(resultado))),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TelaInicial()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarGeral(context, "Login"),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _chaveFormulario,
            child: Column(
              children: [
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  validator: (valor) {
                    if (valor!.isEmpty) {
                      return "Campo vazio";
                    } else {
                      return null;
                    }
                  },
                  onSaved: (valor) {
                    email = valor;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Senha",
                    border: OutlineInputBorder(),
                  ),
                  validator: (valor) {
                    if (valor!.isEmpty) {
                      return "Campo vazio";
                    } else {
                      return null;
                    }
                  },
                  onSaved: (valor) {
                    senha = valor;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 54,
                  width: 184,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : _entrar,
                    child: _carregando
                        ? const CircularProgressIndicator()
                        : const Text("Entrar"),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CadastroForm(),
                      ),
                    );
                  },
                  child: const Text("Criar conta"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}