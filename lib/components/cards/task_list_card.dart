import 'package:flutter/material.dart';

import '../../core/models/task_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../chips/status_chip.dart';
import '../media/user_avatar.dart';

/// Summary card for one task inside the task list.
class TaskListCard extends StatelessWidget {
  const TaskListCard({
    super.key,
    required this.task,
    this.onTap,
    this.onMenuTap,
  });

  final TaskModel task;

  /// Opens the task details screen.
  final VoidCallback? onTap;

  /// Opens the contextual menu of the card.
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          task.title,
                          style: AppTextStyles.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          task.category,
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: onMenuTap,
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                    child: const Padding(
                      padding: EdgeInsets.all(AppSpacing.xs),
                      child: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: <Widget>[
                  UserAvatar(
                    size: 28,
                    imageAsset: task.assigneeAvatar,
                    initials: UserAvatar.initialsFrom(task.assignee),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      task.formattedDueDate,
                      style: AppTextStyles.caption,
                    ),
                  ),
                  StatusChip(status: task.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
