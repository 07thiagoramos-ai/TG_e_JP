import 'package:flutter/material.dart';
import 'package:tg_e_jp/funcao/widget.dart';

class TelaInicial extends StatefulWidget {
  const new({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarGeral(context, "Tela inicial"),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {}, 
                    child: Text("1")
                  ),

                  ElevatedButton(
                    onPressed: () {}, 
                    child: Text("2")
                  ),  

                  ElevatedButton(
                    onPressed: () {}, 
                    child: Text("3")
                  )              
                ],
              )
            )
          ],
        ),
      ),
    );
  }
}