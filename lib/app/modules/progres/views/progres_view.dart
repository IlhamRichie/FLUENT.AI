import 'package:fluent_ai/app/modules/navbar/views/navbar_view.dart';
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
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: controller.refreshData,
            tooltip: 'Refresh',
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
                    const SizedBox(height: 24),
                    _buildProgressChart(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Metrik Kemampuan'),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
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
      bottomNavigationBar: const NavbarView(),
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
    return Obx(() => Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<String>(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
                                return const Color(0xFFD84040).withOpacity(0.2);
                              }
                              return Colors.transparent;
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
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: controller.selectedTimeframe.value ==
                                              timeframe
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
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<String>(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
                                return const Color(0xFFD84040).withOpacity(0.2);
                              }
                              return Colors.transparent;
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
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
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
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildProgressChart() {
    return Obx(() => Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: const Color(0xFFD84040).withOpacity(0.2),
              width: 1,
            ),
          ),
          color: const Color(0xFFD84040).withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.chartTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 250,
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      labelStyle: const TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                      ),
                    ),
                    primaryYAxis: NumericAxis(
                      minimum: 0,
                      maximum: controller.maxChartValue,
                      interval: 20,
                      labelStyle: const TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                      ),
                    ),
                    plotAreaBorderColor: Colors.transparent,
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
                          color: Color(0xFFD84040),
                        ),
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                          textStyle: TextStyle(
                            fontSize: 10,
                            color: Color(0xFFD84040),
                          ),
                        ),
                      ),
                    ],
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      color: const Color(0xFFD84040),
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
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
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
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

  Widget _buildSkillMetricCard(
      {required String title, required dynamic value}) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
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
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title == 'filler_words' ? '$value/menit' : '$value/100',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
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
    final color =
        colors[controller.improvementAreas.indexOf(area) % colors.length];

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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.alertCircle,
                    size: 18,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  area['area'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              area['description'],
              style: const TextStyle(
                color: Colors.black54,
                height: 1.5,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
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
                Expanded(
                  child: Text(
                    'Saran: ${area['suggestion']}',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
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
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildBadgeCard(controller.badges[index]),
            childCount: controller.badges.length,
          ),
        ));
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge) {
    final color = badge['unlocked'] ? const Color(0xFFD84040) : Colors.grey[400]!;

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
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                badge['icon'],
                size: 22,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              badge['title'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
            ] else ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Kunci',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}