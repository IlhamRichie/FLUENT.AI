// lib/app/modules/profil/views/activity_log_view.dart

import 'package:fluent_ai/app/modules/profil/models/activity_log_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timeline_tile/timeline_tile.dart';
import '../controllers/activity_log_controller.dart';

class ActivityLogView extends GetView<ActivityLogController> {
  const ActivityLogView({super.key});

  // Fungsi helper untuk memilih ikon dan warna berdasarkan jenis aktivitas
  Map<String, dynamic> _getActivityStyle(String activity) {
    final lowerCaseActivity = activity.toLowerCase();
    if (lowerCaseActivity.contains('login')) {
      return {'icon': LucideIcons.logIn, 'color': Colors.green.shade600};
    }
    if (lowerCaseActivity.contains('terminated')) {
      return {'icon': LucideIcons.shieldAlert, 'color': Colors.orange.shade800};
    }
    if (lowerCaseActivity.contains('update')) {
      return {'icon': LucideIcons.userCog, 'color': Colors.blue.shade600};
    }
    // Default
    return {'icon': LucideIcons.history, 'color': Colors.grey.shade600};
  }

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('id', timeago.IdMessages());

    return Scaffold(
      backgroundColor: Colors.white, // Background putih bersih
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Log Aktivitas',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFD84040), // Sesuaikan dengan warna primer Anda
            ),
          );
        }
        if (controller.activityLogs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.fileClock,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 20),
                Text(
                  'Belum Ada Aktivitas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Text(
                    'Semua aktivitas akun Anda akan tercatat di sini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => controller.fetchActivityLog(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: controller.activityLogs.length,
            itemBuilder: (context, index) {
              final log = controller.activityLogs[index];
              final style = _getActivityStyle(log.activity);

              return TimelineTile(
                alignment: TimelineAlign.manual,
                lineXY: 0.1, // Posisi garis timeline
                isFirst: index == 0,
                isLast: index == controller.activityLogs.length - 1,
                indicatorStyle: IndicatorStyle(
                  width: 40,
                  height: 40,
                  indicator: Container(
                    decoration: BoxDecoration(
                      color: style['color'].withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        style['icon'],
                        color: style['color'],
                        size: 20,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.all(4),
                ),
                beforeLineStyle: LineStyle(
                  color: Colors.grey.shade200,
                  thickness: 2,
                ),
                endChild: Container(
                  constraints: const BoxConstraints(minHeight: 100),
                  padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        log.activity,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeago.format(log.timestamp.toLocal(), locale: 'id'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${log.deviceInfo} • ${log.ipAddress}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}