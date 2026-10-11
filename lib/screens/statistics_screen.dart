import 'package:flutter/material.dart';

import '../models/tasks.dart';
import '../services/sla_service.dart';
import '../theme/apptheme.dart';
import '../widgets/common.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key, required this.tasks});
  final List<ProjectTask> tasks;

  @override
  Widget build(BuildContext context) {
    int count(bool Function(ProjectTask) test) => tasks.where(test).length;
    SlaStatus sla(ProjectTask t) => SlaService.calculate(t);
    final c = context.colors;
    final rows = [
      (
        'To do',
        count((t) => t.status == 'todo'),
        context.scheme.onSurfaceVariant,
      ),
      ('In progress', count((t) => t.status == 'inProgress'), c.info),
      ('Completed', count((t) => t.isCompleted), c.success),
      ('At risk', count((t) => sla(t) == SlaStatus.atRisk), c.warning),
      ('Overdue', count((t) => sla(t) == SlaStatus.overdue), c.danger),
    ];
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 66,
        leading: const Padding(
          padding: EdgeInsets.only(left: 20),
          child: AppBackButton(),
        ),
        title: const Text('Project statistics'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          FadeSlideIn(
            child: Text(
              'A snapshot calculated from the project task list.',
              style: TextStyle(color: context.scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < rows.length; i++)
            FadeSlideIn(
              index: i + 1,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _StatRow(
                  label: rows[i].$1,
                  count: rows[i].$2,
                  total: tasks.length,
                  color: rows[i].$3,
                ),
              ),
            ),
          const SizedBox(height: 6),
          FadeSlideIn(
            index: 7,
            child: AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.rule_rounded, color: context.scheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'SLA rule: completed tasks are Completed; unfinished tasks past their deadline are Overdue; tasks due within 48 hours are At risk; all others are On track.',
                      style: TextStyle(
                        height: 1.45,
                        color: context.scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });
  final String label;
  final int count;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : count / total;
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '$count / $total',
                style: TextStyle(color: color, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: fraction),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 8,
                color: color,
                backgroundColor: color.withValues(alpha: .15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
