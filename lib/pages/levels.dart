import 'package:flutter/material.dart';


class Levels extends StatelessWidget {
  const Levels({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Level'),),
      body: const Text('Select Level'),
    );
  }
}
