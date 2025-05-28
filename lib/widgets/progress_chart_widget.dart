import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:raga_saarthi/models/progress_model.dart';
import 'package:intl/intl.dart';

class ProgressChartWidget extends StatefulWidget {
  final List<PerformanceHistoryEntry> history;

  const ProgressChartWidget({
    Key? key,
    required this.history,
  }) : super(key: key);

  @override
  _ProgressChartWidgetState createState() => _ProgressChartWidgetState();
}

class _ProgressChartWidgetState extends State<ProgressChartWidget> {
  int _selectedMetricIndex = 0;
  final List<String> _metrics = [
    'Overall Score',
    'Aaroh Adherence',
    'Rhythm Stability',
  ];

  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.history.isEmpty) {
      return const Center(
        child: Text('No performance data available'),
      );
    }

    return Column(
      children: [
        // Metric selector
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _metrics.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(_metrics[index]),
                  selected: _selectedMetricIndex == index,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedMetricIndex = index;
                      });
                    }
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Chart
        Expanded(
          child: LineChart(
            _mainData(),
          ),
        ),
      ],
    );
  }

  LineChartData _mainData() {
    // Sort history by date
    final sortedHistory = List<PerformanceHistoryEntry>.from(widget.history)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Get data based on selected metric
    List<FlSpot> spots = [];
    for (int i = 0; i < sortedHistory.length; i++) {
      final entry = sortedHistory[i];
      double value;

      switch (_selectedMetricIndex) {
        case 0:
          value = entry.overallScore;
          break;
        case 1:
          value = entry.aarohAdherence;
          break;
        case 2:
          value = entry.rhythmStability;
          break;
        default:
          value = entry.overallScore;
      }

      spots.add(FlSpot(i.toDouble(), value));
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 20,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d).withOpacity(0.2),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d).withOpacity(0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final int index = value.toInt();
              if (index >= 0 && index < sortedHistory.length) {
                final date = sortedHistory[index].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('MM/dd').format(date),
                    style: const TextStyle(
                      color: Color(0xff68737d),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 20,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}',
                style: const TextStyle(
                  color: Color(0xff67727d),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d).withOpacity(0.2)),
      ),
      minX: 0,
      maxX: sortedHistory.length - 1.0,
      minY: 0,
      maxY: 100,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.deepPurple,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}