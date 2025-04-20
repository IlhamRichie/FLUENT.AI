import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/latihan_controller.dart';

class LatihanView extends GetView<LatihanController> {
  const LatihanView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LatihanView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'LatihanView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
