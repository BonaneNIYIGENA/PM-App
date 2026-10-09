/// Barrel file exposing every reusable component of the app.
///
/// Screens import `components/components.dart` and never reach into the
/// individual folders, so components can be moved without touching screens.
library;

export 'buttons/app_fab.dart';
export 'buttons/primary_button.dart';
export 'cards/activity_tile.dart';
export 'cards/sla_status_card.dart';
export 'cards/stat_card.dart';
export 'cards/task_list_card.dart';
export 'cards/task_overview_card.dart';
export 'charts/task_donut_chart.dart';
export 'chips/filter_chip_bar.dart';
export 'chips/status_chip.dart';
export 'inputs/app_dropdown_field.dart';
export 'inputs/app_notes_field.dart';
export 'inputs/app_search_bar.dart';
export 'inputs/app_text_field.dart';
export 'layout/app_bottom_nav.dart';
export 'layout/app_header.dart';
export 'layout/detail_row.dart';
export 'layout/section_title.dart';
export 'media/undraw_illustration.dart';
export 'media/user_avatar.dart';
