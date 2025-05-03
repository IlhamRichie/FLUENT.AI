import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/sertifikat_detail_controller.dart';

class SertifikatDetailView extends GetView<SertifikatDetailController> {
  const SertifikatDetailView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SertifikatDetailView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'SertifikatDetailView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
