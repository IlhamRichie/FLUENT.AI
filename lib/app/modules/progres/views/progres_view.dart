import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/progres_controller.dart';

class ProgresView extends GetView<ProgresController> {
  const ProgresView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ProgresView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ProgresView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
