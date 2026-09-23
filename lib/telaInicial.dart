import 'package:flutter/material.dart';

class TelaInicial extends StatefulWidget {
  const new({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        title: Text("Tela inicial", style: TextStyle(color: Colors.white), )
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {}, 
                    child: Text("3S")
                  ),

                  ElevatedButton(
                    onPressed: () {}, 
                    child: Text("2")
                  ),                ],
              )
            )
          ],
        ),
      ),
    );
  }
}