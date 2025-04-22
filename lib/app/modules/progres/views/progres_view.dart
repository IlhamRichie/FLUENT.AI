import 'package:fluent_ai/app/modules/progres/controllers/progres_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ProgresView extends GetView<ProgresController> {
  const ProgresView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Progres Saya',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.share2, color: Colors.black),
            onPressed: () =>
                Get.snackbar('Berbagi', 'Fitur berbagi progres akan datang!'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimeframeSelector(),
            const SizedBox(height: 16),
            _buildProgressChart(),
            const SizedBox(height: 24),
            _buildSkillMetrics(),
            const SizedBox(height: 24),
            _buildImprovementAreas(),
            const SizedBox(height: 24),
            _buildBadgesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    return Obx(() => Row(
          children: [
            Expanded(
              child: SegmentedButton<String>(
                segments: controller.timeframes
                    .map((timeframe) => ButtonSegment<String>(
                          value: timeframe,
                          label: Text(timeframe),
                        ))
                    .toList(),
                selected: {controller.selectedTimeframe.value},
                onSelectionChanged: (Set<String> newSelection) {
                  controller.changeTimeframe(newSelection.first);
                },
                showSelectedIcon: false,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SegmentedButton<String>(
                segments: controller.chartDataOptions
                    .map((data) => ButtonSegment<String>(
                          value: data,
                          label: Text(data),
                        ))
                    .toList(),
                selected: {controller.selectedChartData.value},
                onSelectionChanged: (Set<String> newSelection) {
                  controller.changeChartData(newSelection.first);
                },
                showSelectedIcon: false,
              ),
            ),
          ],
        ));
  }

  Widget _buildProgressChart() {
    return Obx(() => Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.chartTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 250,
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    primaryYAxis: NumericAxis(
                      minimum: 0,
                      maximum: controller.maxChartValue,
                      interval: 20,
                    ),
                    series: <CartesianSeries>[
                      LineSeries<Map<String, dynamic>, String>(
                        dataSource: controller.currentProgressData,
                        xValueMapper: (data, _) =>
                            controller.getXAxisLabel(data),
                        yValueMapper: (data, _) =>
                            controller.getChartValue(data),
                        color: controller.chartColor,
                        width: 3,
                        markerSettings: const MarkerSettings(isVisible: true),
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true),
                      ),
                    ],
                    tooltipBehavior: TooltipBehavior(enable: true),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildSkillMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Metrik Kemampuan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: controller.skillMetrics.entries
                  .map((entry) => _buildSkillMetricCard(
                        title: entry.key,
                        value: entry.value,
                      ))
                  .toList(),
            )),
      ],
    );
  }

  Widget _buildSkillMetricCard(
      {required String title, required dynamic value}) {
    // Convert skill name to display format
    String displayTitle = title.replaceAll('_', ' ').capitalizeFirst!;
    IconData icon;
    Color color;

    switch (title) {
      case 'expression':
        icon = LucideIcons.smile;
        color = Colors.orange;
        break;
      case 'narrative':
        icon = LucideIcons.text;
        color = Colors.green;
        break;
      case 'clarity':
        icon = LucideIcons.volume2;
        color = Colors.blue;
        break;
      case 'confidence':
        icon = LucideIcons.zap;
        color = Colors.purple;
        break;
      case 'filler_words':
        icon = LucideIcons.volumeX;
        color = Colors.red;
        break;
      default:
        icon = LucideIcons.star;
        color = Colors.amber;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(
                  displayTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title == 'filler_words' ? '$value/menit' : '$value/100',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (title != 'filler_words') ...[
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: value / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImprovementAreas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Area Perbaikan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Column(
              children: controller.improvementAreas
                  .map((area) => _buildImprovementCard(area))
                  .toList(),
            )),
      ],
    );
  }

  Widget _buildImprovementCard(Map<String, dynamic> area) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              area['area'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(area['description']),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: area['progress'],
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(LucideIcons.lightbulb, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Saran: ${area['suggestion']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pencapaian & Badge',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: controller.badges
                  .map((badge) => _buildBadgeCard(badge))
                  .toList(),
            )),
      ],
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: badge['unlocked'] ? Colors.white : Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              badge['icon'],
              size: 32,
              color: badge['unlocked'] ? Colors.amber : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              badge['title'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: badge['unlocked'] ? Colors.black : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              badge['date'],
              style: TextStyle(
                fontSize: 10,
                color: badge['unlocked'] ? Colors.grey : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
