import 'package:flutter/material.dart';

import '../../core/models/activity_model.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../media/user_avatar.dart';

/// One row of the "Recent Activity" feed.
///
/// Renders `Sarah updated UI Design`, with the task name in bold, and the
/// relative time underneath.
class ActivityTile extends StatelessWidget {
  const ActivityTile({super.key, required this.activity});

  final ActivityModel activity;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        UserAvatar(
          size: 36,
          imageAsset: activity.avatar,
          initials: UserAvatar.initialsFrom(activity.userName),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: '${activity.userName} updated ',
                      style: AppTextStyles.body,
                    ),
                    TextSpan(
                      text: activity.taskTitle,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(activity.timeAgo, style: AppTextStyles.caption),
            ],
          ),
        ),
      ],
    );
  }
}
