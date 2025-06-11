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

        // Adding a legend for better understanding
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(Icons.touch_app, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Tap on points to see score details',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

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
    // Sort history by date (ensuring chronological order)
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
            interval: _calculateXAxisInterval(sortedHistory.length),
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
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) { // ADD THIS
            return Colors.deepPurple.withOpacity(0.8);
          },
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((touchedSpot) {
              final index = touchedSpot.x.toInt();
              if (index >= 0 && index < sortedHistory.length) {
                final entry = sortedHistory[index];
                final date = DateFormat('MMM d, yyyy').format(entry.date);
                return LineTooltipItem(
                  '${touchedSpot.y.toStringAsFixed(1)}%\n$date',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }
              return null;
            }).toList();
          },
        ),
        touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
          // Optional: Implement any additional touch handling here
        },
        handleBuiltInTouches: true,
      ),
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
              // Show score value next to the dot
              return FlDotCirclePainter(
                radius: 5,
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

  double _calculateXAxisInterval(int dataLength) {
    // Show fewer labels when there are more data points
    if (dataLength > 15) {
      return (dataLength / 4).floorToDouble(); // Show only ~4 labels for many data points
    } else if (dataLength > 10) {
      return (dataLength / 5).floorToDouble(); // Show ~5 labels
    } else if (dataLength > 5) {
      return 2; // Show every other label when 6-10 data points
    }
    return 1; // Show all labels when 5 or fewer data points
  }
}