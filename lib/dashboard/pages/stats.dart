// SPDX-FileCopyrightText: 2025 Eyad Issa <eyadlorenzo@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:almastudio/unibo_api.dart';

// --- Utility Widgets ---
class _StatsCard extends StatelessWidget {
  final Color? color;
  final Color? borderColor;
  final Widget child;

  const _StatsCard({required this.child, this.color, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor ?? Colors.grey[200]!, width: 1.2),
      ),
      color: color,
      child: Padding(padding: const EdgeInsets.all(20.0), child: child),
    );
  }
}

Widget _buildIconTitleRow(
  IconData icon,
  Color? iconColor,
  String title,
  BuildContext context,
) {
  return Row(
    children: [
      Icon(icon, color: iconColor, size: 32),
      const SizedBox(width: 12),
      Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    ],
  );
}

Widget _buildPieLegend(Color color, String label) {
  return Row(
    children: [
      Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(width: 4),
      Text(label),
    ],
  );
}

class StatsWidget extends StatelessWidget {
  final Future<StatsResponse> Function() dataFetcher;
  final Future<StudyPlanResponse> Function() studyPlanFetcher;

  const StatsWidget({
    super.key,
    required this.dataFetcher,
    required this.studyPlanFetcher,
  });

  Widget _degreeStatsCard(BuildContext context, StatsResponse stats) =>
      _StatsCard(
        color: Colors.blueGrey[50],
        borderColor: Colors.blueGrey[100],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIconTitleRow(
              Icons.school,
              Colors.blueGrey[400],
              'Degree Stats',
              context,
            ),
            const SizedBox(height: 8),
            Text(
              'Degree Average:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              stats.degree.average.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
      );

  Widget _examsStatsCard(BuildContext context, StatsResponse stats) =>
      _StatsCard(
        color: Colors.deepPurple[50],
        borderColor: Colors.deepPurple[100],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIconTitleRow(
              Icons.assignment,
              Colors.deepPurple[300],
              'Exams Stats',
              context,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Exams Average:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Text(
                  stats.exams.average.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Exams Count:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Text(
                  '${stats.exams.count}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Honours:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${stats.exams.honours}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (stats.exams.honours > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'L',
                            style: TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

  Widget _creditsStatsCard(
    BuildContext context,
    StatsResponse stats,
  ) => _StatsCard(
    color: Colors.green[50],
    borderColor: Colors.green[100],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIconTitleRow(
          Icons.pie_chart,
          Colors.green[400],
          'Credits Stats',
          context,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                'Credits Passed:',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Text(
              stats.credits.passed.toStringAsFixed(2),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                'Credits Required:',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Text(
              '${stats.credits.required}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: stats.credits.passed,
                  color: Colors.green,
                  title:
                      '${((stats.credits.passed / stats.credits.required) * 100).toStringAsFixed(1)}%',
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  value:
                      ((stats.credits.required - stats.credits.passed).clamp(
                            0,
                            stats.credits.required,
                          ))
                          as double,
                  color: Colors.grey[400],
                  title:
                      '${(((stats.credits.required - stats.credits.passed) / stats.credits.required) * 100).toStringAsFixed(1)}%',
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPieLegend(Colors.green, 'Passed'),
            const SizedBox(width: 16),
            _buildPieLegend(Colors.grey[400]!, 'Remaining'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                'Final Exam:',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Text(
              stats.credits.finalExam?.toString() ?? '-',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _averageProgressCard(
    BuildContext context,
    List<double> progressAverages,
  ) => _StatsCard(
    color: Colors.blue[50],
    borderColor: Colors.blue[100],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIconTitleRow(
          Icons.show_chart,
          Colors.blue[400],
          'Average Progress',
          context,
        ),
        const SizedBox(height: 12),
        Builder(
          builder: (context) {
            final minY =
                ((progressAverages.reduce((a, b) => a < b ? a : b) - 1).clamp(
                  0,
                  999,
                )).toDouble();
            final maxY =
                ((progressAverages.reduce((a, b) => a > b ? a : b) + 1).clamp(
                  0,
                  999,
                )).toDouble();
            return SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (value, meta) => (value % 2 == 0)
                            ? Text('${value.toInt() + 1}')
                            : const SizedBox.shrink(),
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.blueGrey[100]!, width: 1),
                  ),
                  minX: 0,
                  maxX: (progressAverages.length - 1).toDouble(),
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (int i = 0; i < progressAverages.length; i++)
                          FlSpot(i.toDouble(), progressAverages[i]),
                      ],
                      isCurved: false,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Shows the average after each new exam passed.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );

  Widget _weightedAverageProgressCard(
    BuildContext context,
    List<LearningActivity> activities,
  ) {
    final passed = activities
        .where(
          (e) =>
              e.outcome?.passed == true &&
              e.outcome?.value != null &&
              e.credits != null &&
              e.recordDate != null,
        )
        .toList();
    passed.sort((a, b) => a.recordDate!.compareTo(b.recordDate!));
    List<double> runningWeighted = [];
    double weightedSum = 0;
    double totalCfu = 0;
    for (int i = 0; i < passed.length; i++) {
      final mark = double.tryParse(passed[i].outcome!.value);
      final cfu = passed[i].credits?.toDouble() ?? 0;
      if (mark != null && cfu > 0) {
        weightedSum += mark * cfu;
        totalCfu += cfu;
      }
      final weightedAvg = totalCfu > 0
          ? (weightedSum / totalCfu) * 110 / 30
          : 0;
      runningWeighted.add(weightedAvg.toDouble());
    }
    if (runningWeighted.isEmpty) return const SizedBox.shrink();
    final minY = (runningWeighted.reduce((a, b) => a < b ? a : b) - 1)
        .clamp(0, 110)
        .toDouble();
    final maxY = (runningWeighted.reduce((a, b) => a > b ? a : b) + 1)
        .clamp(0, 110)
        .toDouble();
    return _StatsCard(
      color: Colors.cyan[50],
      borderColor: Colors.cyan[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconTitleRow(
            Icons.show_chart,
            Colors.cyan[400],
            'Weighted Average Progress',
            context,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) => (value % 2 == 0)
                          ? Text('${value.toInt() + 1}')
                          : const SizedBox.shrink(),
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.blueGrey[100]!, width: 1),
                ),
                minX: 0,
                maxX: (runningWeighted.length - 1).toDouble(),
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (int i = 0; i < runningWeighted.length; i++)
                        FlSpot(i.toDouble(), runningWeighted[i]),
                    ],
                    isCurved: false,
                    color: Colors.cyan,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Shows the weighted average (×110/30) after each new exam passed.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([dataFetcher(), studyPlanFetcher()]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: SelectableText(
                snapshot.error.toString(),
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No statistics data.'));
          }
          final stats = snapshot.data![0] as StatsResponse;
          final studyPlan = snapshot.data![1] as StudyPlanResponse;
          final activities = studyPlan.learningActivities;

          // Compute running averages for passed exams from activities
          List<double> progressAverages = [];
          if (activities.isNotEmpty) {
            final passed = activities
                .where(
                  (e) =>
                      e.outcome?.passed == true &&
                      e.outcome?.value != null &&
                      e.recordDate != null,
                )
                .toList();
            passed.sort((a, b) => a.recordDate!.compareTo(b.recordDate!));
            double sum = 0;
            for (int i = 0; i < passed.length; i++) {
              sum += double.tryParse(passed[i].outcome!.value) ?? 0;
              progressAverages.add(sum / (i + 1));
            }
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _degreeStatsCard(context, stats),
                  _examsStatsCard(context, stats),
                  _creditsStatsCard(context, stats),
                  if (progressAverages.isNotEmpty)
                    _averageProgressCard(context, progressAverages),
                  if (activities.isNotEmpty)
                    _weightedAverageProgressCard(context, activities),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
