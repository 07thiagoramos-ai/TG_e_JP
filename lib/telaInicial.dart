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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(20),
              ),
              margin: EdgeInsets.all(40),
              padding: EdgeInsets.all(80),
              child: Column(
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