import 'package:flutter/material.dart';
import 'package:tg_e_jp/telaInicial.dart';
import 'authentication.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _chaveFormulario = GlobalKey<FormState>();

  String? email;
  String? senha;
  String? nome;
  bool _esconderSemha = false;
  bool aceito = false;

  final pass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var border = const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(100.0)),
    );

    var space = const SizedBox(height: 10);
    return Form(
      key: _chaveFormulario,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          // email
          TextFormField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.email_outlined),
              labelText: 'Email',
              border: border,
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Campo vazio';
              }
              return null;
            },
            onSaved: (val) {
              email = val;
            },
            keyboardType: TextInputType.emailAddress,
          ),

          space,

          // password
          TextFormField(
            controller: pass,
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: const Icon(Icons.lock_outline),
              border: border,
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _esconderSemha = !_esconderSemha;
                  });
                },
                child: Icon(
                  _esconderSemha ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
            onSaved: (val) {
              senha = val;
            },
            obscureText: !_esconderSemha,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Campo vazio';
              }
              return null;
            },
          ),
          space,
          // confirm passwords
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Confirme a senha',
              prefixIcon: const Icon(Icons.lock_outline),
              border: border,
            ),
            obscureText: true,
            validator: (value) {
              if (value != pass.text) {
                return 'valores não coincidem';
              }
              return null;
            },
          ),
          space,

          // signUP button
          SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_chaveFormulario.currentState!.validate()) {
                  _chaveFormulario.currentState!.save();

                  Authentication().signUp(email: email!, senha: senha!)
                      .then((result) {
                        if (result == null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TelaInicial(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                Authentication().traduzirRetorno(result),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          );
                        }
                      });
                }
              },
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24.0)),
                ),
              ),
              child: const Text('Registre-se'),
            ),
          ),
        ],
      ),
    );
  }
}
