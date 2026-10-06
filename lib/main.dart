import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tg_e_jp/authentication.dart';
import 'package:tg_e_jp/eventos/telaEventos.dart';
import 'package:tg_e_jp/firebase_options.dart';
import 'package:tg_e_jp/loginForm.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final logado = await Authentication().sessaoSalva();
  runApp(MyApp(logado: logado));
}

class MyApp extends StatelessWidget {
  final bool logado;
  const MyApp({super.key, required this.logado});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TG e JP',
      debugShowCheckedModeBanner: false,
      home: logado ? const TelaEventos() : const LoginForm(),
    );
  }
}