import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/virtualhrd_controller.dart';

class VirtualhrdView extends GetView<VirtualhrdController> {
  const VirtualhrdView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VirtualhrdView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'VirtualhrdView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
