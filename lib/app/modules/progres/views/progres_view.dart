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
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.share2, size: 20),
            onPressed: () => Get.snackbar('Berbagi', 'Fitur berbagi progres akan datang!'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD84040)),
            ),
          );
        }
        
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimeframeSelector(),
                    const SizedBox(height: 16),
                    _buildProgressChart(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Metrik Kemampuan'),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: _buildSkillMetricsGrid(),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Area Perbaikan'),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: _buildImprovementAreasList(),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Pencapaian & Badge'),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: _buildBadgesGrid(),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    return Obx(() => Row(
          children: [
            Expanded(
              child: SegmentedButton<String>(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return const Color(0xFFD84040).withOpacity(0.2);
                      }
                      return Colors.white;
                    },
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                segments: controller.timeframes
                    .map((timeframe) => ButtonSegment<String>(
                          value: timeframe,
                          label: Text(
                            timeframe,
                            style: TextStyle(
                              color: controller.selectedTimeframe.value == timeframe
                                  ? const Color(0xFFD84040)
                                  : Colors.grey[700],
                            ),
                          ),
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
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return const Color(0xFFD84040).withOpacity(0.2);
                      }
                      return Colors.white;
                    },
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                segments: controller.chartDataOptions
                    .map((data) => ButtonSegment<String>(
                          value: data,
                          label: Text(
                            data,
                            style: TextStyle(
                              color: controller.selectedChartData.value == data
                                  ? const Color(0xFFD84040)
                                  : Colors.grey[700],
                            ),
                          ),
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
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          color: Colors.white,
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
                        color: const Color(0xFFD84040),
                        width: 3,
                        markerSettings: const MarkerSettings(
                          isVisible: true,
                          shape: DataMarkerType.circle,
                          borderWidth: 2,
                          borderColor: Colors.white,
                        ),
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                          textStyle: TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      color: const Color(0xFFD84040),
                      textStyle: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildSkillMetricsGrid() {
    return Obx(() => SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final entry = controller.skillMetrics.entries.elementAt(index);
              return _buildSkillMetricCard(
                title: entry.key,
                value: entry.value,
              );
            },
            childCount: controller.skillMetrics.length,
          ),
        ));
  }

  Widget _buildSkillMetricCard({required String title, required dynamic value}) {
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
        color = const Color(0xFFD84040);
        break;
      default:
        icon = LucideIcons.star;
        color = Colors.amber;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      color: color.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              displayTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title == 'filler_words' ? '$value/menit' : '$value/100',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (title != 'filler_words') ...[
              const SizedBox(height: 8),
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

  Widget _buildImprovementAreasList() {
    return Obx(() => SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildImprovementCard(controller.improvementAreas[index]),
            ),
            childCount: controller.improvementAreas.length,
          ),
        ));
  }

  Widget _buildImprovementCard(Map<String, dynamic> area) {
    final colors = [
      const Color(0xFFD84040),
      Colors.blue,
      Colors.green,
      Colors.purple,
    ];
    final color = colors[controller.improvementAreas.indexOf(area) % colors.length];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      color: color.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.alertCircle,
                    size: 20,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  area['area'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              area['description'],
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: area['progress'],
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(LucideIcons.lightbulb, size: 16, color: color),
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

  Widget _buildBadgesGrid() {
    return Obx(() => SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildBadgeCard(controller.badges[index]),
            childCount: controller.badges.length,
          ),
        ));
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge) {
    final color = badge['unlocked'] ? const Color(0xFFD84040) : Colors.grey;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      color: color.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                badge['icon'],
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              badge['title'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (badge['unlocked']) ...[
              const SizedBox(height: 4),
              Text(
                badge['date'],
                style: TextStyle(
                  fontSize: 10,
                  color: color.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}