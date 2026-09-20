import 'package:flutter/material.dart';
import 'package:tg_e_jp/telaInicial.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Eventos",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.green),
      home: TelaInicial(),
    );
  }
}