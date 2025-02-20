import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';

class UserDataBarChart extends StatelessWidget {
  final LeaderboardModel user;

  const UserDataBarChart({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // We'll use cheater, toxicity, and honour reports for the chart.
    final reportValues = [
      user.cheaterReports.toDouble(),
      user.toxicityReports.toDouble(),
      user.honourReports.toDouble(),
    ];

    // Determine the maximum y-value with some headroom.
    final double maxValue = reportValues.isEmpty
        ? 10
        : (reportValues.reduce((a, b) => a > b ? a : b)) * 1.2;
    final double finalMaxY = maxValue < 10 ? 10 : maxValue;

    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          maxY: finalMaxY,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            // ============================
            // LEFT Y-AXIS TITLES
            // ============================
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40, // space for y-axis labels
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            // ============================
            // BOTTOM X-AXIS TITLES
            // ============================
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  switch (value.toInt()) {
                    case 0:
                      return const Text('Cheater',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ));
                    case 1:
                      return const Text('Toxicity',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ));
                    case 2:
                      return const Text('Honour',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ));
                    default:
                      return const Text('');
                  }
                },
              ),
            ),
            // Hide top & right titles if desired
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          // ============================
          // BAR GROUPS
          // ============================
          barGroups: List.generate(3, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: reportValues[index],
                  color: Colors.blue, // single color for all bars
                  width: 22,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
