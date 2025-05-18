// lib/app/modules/progres/views/progres_view.dart
import 'package:fluent_ai/app/modules/navbar/views/navbar_view.dart';
import 'package:fluent_ai/app/modules/progres/controllers/progres_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ProgresView extends GetView<ProgresController> {
  const ProgresView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primaryColor = controller.parseColor('#D84040'); // Warna utama aplikasi Anda

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey[200],
        automaticallyImplyLeading: false,
        title: Text(
          'Progres Saya',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.grey[850],
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(LucideIcons.rotateCw, size: 22, color: Colors.grey[700]),
            onPressed: controller.refreshData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Obx(() { // Obx utama untuk menangani state loading
        if (controller.isLoading.value && controller.currentProgressData.isEmpty) {
          return _buildShimmerPage(theme);
        }
        return CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(child: _buildTimeframeSelector(theme, primaryColor)),
            SliverToBoxAdapter(child: _buildProgressChart(theme, primaryColor)),
            _buildSectionHeader('Metrik Kemampuan', LucideIcons.barChart3),
            _buildSkillMetricsGrid(theme),
            _buildSectionHeader('Area Perbaikan', LucideIcons.target),
            _buildImprovementAreasList(theme),
            _buildSectionHeader('Pencapaian & Badge', LucideIcons.trophy),
            _buildBadgesGrid(theme),
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        );
      }),
      bottomNavigationBar: const NavbarView(),
    );
  }

  Widget _buildShimmerPage(ThemeData theme) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 120, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
              const SizedBox(height: 24),
              Container(height: 280, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
              const SizedBox(height: 24),
              Container(height: 20, width: 200, color: Colors.white),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.95,
                ),
                itemCount: 4,
                itemBuilder: (context, index) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 24),
              Container(height: 20, width: 150, color: Colors.white),
              const SizedBox(height: 16),
              Container(height: 100, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData iconData) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Row(
          children: [
            Icon(iconData, color: Colors.grey[700], size: 22),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeframeSelector(ThemeData theme, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Card(
        elevation: 2,
        shadowColor: Colors.grey[200],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _customSegmentedButton(controller.timeframes, controller.selectedTimeframe, controller.changeTimeframe, primaryColor),
              const SizedBox(height: 12),
              _customSegmentedButton(controller.chartDataOptions, controller.selectedChartData, controller.changeChartData, primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customSegmentedButton(RxList<String> options, RxString selectedOption, Function(String) onSelectionChanged, Color primaryColor) {
     return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_,__)=> const SizedBox(width: 8),
        itemBuilder: (context, index){
          final option = options[index];
          return Obx(() => ChoiceChip(
            label: Text(option),
            selected: selectedOption.value == option,
            onSelected: (_) => onSelectionChanged(option),
            backgroundColor: Colors.grey[100],
            selectedColor: primaryColor.withOpacity(0.15),
            labelStyle: TextStyle(
              color: selectedOption.value == option ? primaryColor : Colors.grey[700],
              fontWeight: selectedOption.value == option ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: selectedOption.value == option ? primaryColor : Colors.grey[300]!,
                width: 1.2,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            showCheckmark: false,
          ));
        }
      ),
    );
  }


  Widget _buildProgressChart(ThemeData theme, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        shadowColor: Colors.grey[200],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(()=> Text(
                controller.chartTitle,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: Colors.grey[800]),
              )),
              const SizedBox(height: 20),
              Obx(() => SizedBox(
                height: 260,
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(
                    majorGridLines: const MajorGridLines(width: 0),
                    axisLine: const AxisLine(width: 0),
                    labelStyle: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                  primaryYAxis: NumericAxis(
                    minimum: 0,
                    maximum: controller.maxChartValue,
                    interval: controller.intervalChartValue,
                    axisLine: const AxisLine(width: 0),
                    majorTickLines: const MajorTickLines(size: 0),
                    labelStyle: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                  plotAreaBorderWidth: 0,
                  series: <CartesianSeries>[
                    SplineSeries<Map<String, dynamic>, String>(
                      dataSource: controller.currentProgressData.toList(),
                      xValueMapper: (data, _) => controller.getXAxisLabel(data),
                      yValueMapper: (data, _) => controller.getChartValue(data),
                      color: primaryColor,
                      width: 3.5,
                      markerSettings: MarkerSettings(
                        isVisible: true,
                        shape: DataMarkerType.circle,
                        borderWidth: 3,
                        borderColor: Colors.white,
                        color: primaryColor,
                        height: 9, width: 9
                      ),
                      dataLabelSettings: DataLabelSettings( // PERBAIKAN DI SINI
                        isVisible: true,
                        textStyle: TextStyle(fontSize: 10, color: primaryColor, fontWeight: FontWeight.bold),
                        labelAlignment: ChartDataLabelAlignment.top,
                        margin: const EdgeInsets.all(5), // Mengganti 'padding' dengan 'margin'
                      ),
                      animationDuration: 800,
                    ),
                  ],
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    color: primaryColor,
                    header: '',
                    textStyle: const TextStyle(color: Colors.white, fontSize: 12),
                    // padding: const EdgeInsets.all(10), // Padding di TooltipBehavior valid
                    shouldAlwaysShow: false,
                    canShowMarker: false,
                    format: 'point.x : point.y',
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillMetricsGrid(ThemeData theme) {
    return Obx(() {
      if (controller.skillMetrics.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.95,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final entry = controller.skillMetrics.entries.elementAt(index);
              return _buildSkillMetricCard(title: entry.key, value: entry.value, theme: theme);
            },
            childCount: controller.skillMetrics.length,
          ),
        ),
      );
    });
  }

  Widget _buildSkillMetricCard({required String title, required dynamic value, required ThemeData theme}) {
    String displayTitle = title.replaceAll('_', ' ').capitalizeFirst!;
    IconData icon; Color color;

    switch (title) {
      case 'expression': icon = LucideIcons.smile; color = Colors.orange.shade600; break;
      case 'narrative': icon = LucideIcons.fileText; color = Colors.green.shade600; break;
      case 'clarity': icon = LucideIcons.megaphone; color = Colors.blue.shade600; break;
      case 'confidence': icon = LucideIcons.zap; color = Colors.purple.shade600; break;
      case 'filler_words': icon = LucideIcons.messageSquare; color = Colors.red.shade600; break; // PERBAIKAN ICON DI SINI
      default: icon = LucideIcons.activity; color = Colors.teal.shade600;
    }

    return Card(
      elevation: 1.5,
      shadowColor: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 22, color: color),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayTitle, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.grey[800])),
                const SizedBox(height: 5),
                Text(
                  title == 'filler_words' ? '$value per menit' : '$value / 100',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
            if (title != 'filler_words')
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: (value is int ? value.toDouble() : value) / 100,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 8,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImprovementAreasList(ThemeData theme) {
     return Obx(() {
      if (controller.improvementAreas.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final area = controller.improvementAreas[index];
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildImprovementCard(area, theme),
            );
          },
          childCount: controller.improvementAreas.length,
        ),
      );
    });
  }

  Widget _buildImprovementCard(Map<String, dynamic> area, ThemeData theme) {
    final Color cardColor = controller.parseColor(area['color'] ?? '#7F8C8D');

    return Card(
      elevation: 1.5,
      shadowColor: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: cardColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(LucideIcons.edit3, size: 18, color: cardColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    area['area'],
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: cardColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(area['description'], style: TextStyle(color: Colors.grey[600], height: 1.4, fontSize: 13.5)),
            const SizedBox(height: 12),
             if (area['progress'] != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: (area['progress'] is int ? area['progress'].toDouble() : area['progress']),
                    backgroundColor: cardColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(cardColor),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${((area['progress'] is int ? area['progress'].toDouble() : area['progress']) * 100).toInt()}% Tercapai',
                    style: TextStyle(fontSize: 11, color: cardColor, fontWeight: FontWeight.w500),
                  ),
                ),
             ],
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blueGrey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blueGrey[100]!)
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(LucideIcons.lightbulb, size: 18, color: Colors.blueGrey[600]),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Saran: ${area['suggestion']}',
                      style: TextStyle(color: Colors.blueGrey[700], fontSize: 12.5, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesGrid(ThemeData theme) {
    return Obx(() {
      if (controller.badges.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildBadgeCard(controller.badges[index], theme),
            childCount: controller.badges.length,
          ),
        ),
      );
    });
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge, ThemeData theme) {
    final Color badgeColor = controller.parseColor(badge['color'] ?? '#D84040');
    final bool isUnlocked = badge['unlocked'];

    return Card(
      elevation: isUnlocked ? 1.5 : 0.5,
      shadowColor: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isUnlocked ? Colors.white : Colors.grey[200],
      child: Opacity(
        opacity: isUnlocked ? 1.0 : 0.6,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUnlocked ? badgeColor.withOpacity(0.1) : Colors.grey[300],
                  shape: BoxShape.circle,
                  border: isUnlocked ? Border.all(color: badgeColor.withOpacity(0.3), width: 1.5) : null,
                ),
                child: Icon(badge['icon'] as IconData?, size: 26, color: isUnlocked ? badgeColor : Colors.grey[600]),
              ),
              const SizedBox(height: 10),
              Text(
                badge['title'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 12.5,
                  color: isUnlocked ? Colors.grey[800] : Colors.grey[700],
                ),
                maxLines: 2, overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                isUnlocked ? badge['date'] : 'Terkunci',
                style: TextStyle(fontSize: 10.5, color: isUnlocked ? badgeColor : Colors.grey[600], fontWeight: isUnlocked ? FontWeight.w500 : FontWeight.normal),
              ),
            ],
          ),
        ),
      ),
    );
  }
}