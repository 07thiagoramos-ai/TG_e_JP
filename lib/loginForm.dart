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
        child: Container(width: 450, height: 400,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(255, 0, 0, 0)),
          borderRadius: BorderRadius.circular(15),
           ),
          child: Form(
                key: _chaveFormulario,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                      Text(
                          "Acessar conta",
                           style: TextStyle(
                           fontSize: 24,
                           fontWeight: FontWeight.bold,
                           ),
                        ),
                    SizedBox(height: 5),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                         ),
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
                      decoration: InputDecoration(
                        labelText: "Senha",
                        border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _carregando ? null : _entrar,
                      child: _carregando
                          ? const CircularProgressIndicator()
                          : const Text(
                              "Entrar",
                              style: TextStyle(
                                fontSize: 18
                                ,
                              ),
                            ),
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
          )
        ),
      ),
    );
  }
}