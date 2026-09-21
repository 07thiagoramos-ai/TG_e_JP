import 'package:flutter/material.dart';
import 'package:tg_e_jp/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tg_e_jp/telaInicial.dart';

class CadastroForm extends StatefulWidget {
  const CadastroForm({super.key});

  @override
  State<CadastroForm> createState() => _CadastroFormState();
}

class _CadastroFormState extends State<CadastroForm> {
  final _chaveFormulario = GlobalKey<FormState>();

  String? nome;
  String? matricula;
  String? email;
  String? senha;

  Future<void> _criarConta() async {
    if (!_chaveFormulario.currentState!.validate()) return;
    _chaveFormulario.currentState!.save();

    final resultado = await Authentication().signUp(
      email: email!,
      senha: senha!
    );

    if (!mounted) return;

    if (resultado != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Authentication().traduzirRetorno(resultado))),
      );
      return;
    }

    final usuario = FirebaseAuth.instance.currentUser!;

    try {
      await FirebaseFirestore.instance
          .collection('participantes')
          .doc(usuario.uid)
          .set({
        'nome': nome,
        'matricula': int.parse(matricula!),
      });
    } on FirebaseException catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: ${erro.code}')),
      );
      return;
    }
    
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TelaInicial()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Criar conta")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _chaveFormulario,
            child: Column(
              children: [
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: "Nome",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))
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
                    nome = valor;
                  }
                ),

                const SizedBox(height: 20),

                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Matrícula",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                  ),
                  validator: (valor) {
                    if (valor!.isEmpty) {
                      return "Campo vazio";
                    }

                    if (int.tryParse(valor) == null) {
                      return "Apenas números";
                    }
                    return null;
                  },
                  onSaved: (valor) => matricula = valor,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))
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
                  decoration: const InputDecoration(
                    labelText: "Senha",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                  ),
                  validator: (valor) {
                    if (valor!.isEmpty) {
                      return "Campo vazio";
                    }

                    if (valor.length < 6) {
                      return "Mínimo de 6 caracteres";
                    }

                    return null;
                  },
                  onSaved: (valor) {
                    senha = valor;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 54,
                  width: 184,
                  child: ElevatedButton(
                    onPressed: _criarConta,
                    child: const Text("Criar"),
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