import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../controllers/device_management_controller.dart';

class DeviceManagementView extends GetView<DeviceManagementController> {
  const DeviceManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Perangkat'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.sessions.isEmpty) {
          return const Center(child: Text('Tidak ada sesi aktif ditemukan.'));
        }
        return ListView.builder(
          itemCount: controller.sessions.length,
          itemBuilder: (context, index) {
            final session = controller.sessions[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(LucideIcons.smartphone, size: 40),
                title: Text(
                  session.deviceInfo,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session.ipAddress),
                    Text('Terakhir aktif: ${timeago.format(session.lastSeen, locale: 'id')}'),
                    if (session.isCurrent)
                      const Text(
                        '(Perangkat ini)',
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
                trailing: session.isCurrent
                    ? null
                    : IconButton(
                        icon: const Icon(LucideIcons.logOut, color: Colors.red),
                        onPressed: () => controller.terminateSession(session.sessionId),
                      ),
              ),
            );
          },
        );
      }),
    );
  }
}