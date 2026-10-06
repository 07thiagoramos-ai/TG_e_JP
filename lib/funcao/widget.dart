import 'package:flutter/material.dart';

PreferredSizeWidget appBarGeral(BuildContext context, String titulo) {
  return AppBar(
    backgroundColor: Colors.blueAccent,
    centerTitle: true,
    title: Text(titulo, style: TextStyle(color: Colors.white),),
    iconTheme: IconThemeData(color: Colors.white),
  );
}
