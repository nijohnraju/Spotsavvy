import 'package:flutter/material.dart';

Color greensavvy =  const Color.fromARGB(255, 139, 200, 98);
Color blacksavvy = const Color.fromARGB(255, 30, 30, 31);
Color whitesavvy = const Color.fromARGB(255, 250, 249, 246);

BoxDecoration customDecoration() {
    return BoxDecoration(
      color: const Color.fromARGB(255, 255, 255, 255),
      borderRadius: BorderRadius.circular(8),
      boxShadow: const [
        BoxShadow(
          offset: Offset(0, 2),
          color: Color.fromARGB(255, 195, 192, 192),
          blurRadius: 5,
        )
      ],
    );
  }