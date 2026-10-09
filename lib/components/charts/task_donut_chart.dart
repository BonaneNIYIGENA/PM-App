import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/theme/app_text_styles.dart';

/// One slice of a [TaskDonutChart].
class DonutSegment {
  const DonutSegment({required this.color, required this.value});

  final Color color;
  final int value;
}

/// Donut chart with the total number of tasks rendered in its hole.
class TaskDonutChart extends StatelessWidget {
  const TaskDonutChart({
    super.key,
    required this.segments,
    required this.total,
    this.size = 130,
  });

  final List<DonutSegment> segments;

  /// Number shown in the middle of the chart.
  final int total;

  final double size;

  @override
  Widget build(BuildContext context) {
    // fl_chart cannot lay out a pie without a positive value, so the chart is
    // only drawn once the segments carry data.
    final bool hasData = segments.any(
      (DonutSegment segment) => segment.value > 0,
    );

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          if (hasData)
            PieChart(
              PieChartData(
                sections: <PieChartSectionData>[
                  for (final DonutSegment segment in segments)
                    PieChartSectionData(
                      color: segment.color,
                      value: segment.value.toDouble(),
                      showTitle: false,
                      radius: size * 0.16,
                    ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: size * 0.28,
                startDegreeOffset: -90,
              ),
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('$total', style: AppTextStyles.metric),
              Text('Tasks', style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}
