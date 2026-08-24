import 'package:flutter/material.dart';

class Cabecalho extends StatelessWidget {
  const Cabecalho({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 53,
      width: double.infinity,
      color: Colors.white,

      child: Row(
        children: [

          // LOGO
          Padding(
            padding: const EdgeInsets.only(
              left: 7,
            ),

            child: Image.asset(
              'imgs/logo.png',
              width: 57,
              height: 50,
              fit: BoxFit.contain,
            ),
          ),

          const Spacer(),

          // MENU
          IconButton(
            onPressed: () {},

            icon: const Icon(
              Icons.menu,
              color: Colors.black,
              size: 23,
            ),
          ),

          // USUÁRIO
          IconButton(
            onPressed: () {},

            icon: const Icon(
              Icons.person_outline,
              color: Colors.black,
              size: 21,
            ),
          ),

          const SizedBox(width: 2),
        ],
      ),
    );
  }
}