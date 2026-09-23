import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

PreferredSizeWidget appBarGeral(BuildContext context, String titulo) {
  return AppBar(
    backgroundColor: Colors.blueAccent,
    centerTitle: true,
    title: Text(titulo, style: TextStyle(color: Colors.white), )
  );
}