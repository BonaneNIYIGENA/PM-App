# taskMS — Project & SLA Task Tracker

taskMS is a Flutter mobile app for a small software team to assign project tasks, manage deadlines, track progress, and see which work needs attention. It uses local SQLite storage; it has no backend or live authentication service.

## Run the app

Use a Flutter emulator or connect an Android/iOS device. From the project root:

```bash
flutter pub get
flutter run
```

Choose a team profile on the first screen. The app creates a local database and seeds sample members and tasks on first launch so the dashboard has examples of the task workflow and SLA states. The database stays in the app’s private device storage and is not a project asset.

## Main workflow

1. Select a team member.
2. Review project progress and tasks needing attention on the dashboard.
3. Open **Tasks** to search or filter by task status or SLA state.
4. Create or edit a task with an assignee, priority, deadline, and description.
5. Open task details to update completion or delete the task.
6. Manage people from **Team**, or switch the selected profile from **Profile**.

## SLA rule

The `SlaService` applies the same rule wherever task status is shown:

- **Completed:** task status is completed.
- **Overdue:** task is incomplete and its deadline has passed.
- **At risk:** task is incomplete and due within the next 48 hours.
- **On track:** task is incomplete and due more than 48 hours from now.

## Code layout

| Location | Responsibility |
| --- | --- |
| `lib/models/` | Task and team-member data models |
| `lib/services/storage.dart` | SQLite schema, initial sample data, and local CRUD operations |
| `lib/services/sla_service.dart` | Shared SLA business rule |
| `lib/screens/` | User selection, dashboard, tasks, task form/details, team, profile, and statistics |
| `lib/theme/apptheme.dart` | Shared colors and Material theme |

Draft submission materials are in `docs/`: the short project report, technical report, contribution-tracker template, demo outline, and [manual test checklist](docs/manual_test_checklist.md). Replace placeholders with the group’s actual names, links, test evidence, and recorded contributions before submission.

The app shell loads tasks and members from SQLite. Screen actions update that shared state and the database; dashboard totals are calculated from the current task list rather than stored separately.

## Local data

SQLite is provided by [`sqflite`](https://pub.dev/packages/sqflite). Tasks and members are stored in the app’s platform data directory. Database files (`*.db`, `*.sqlite`, and `*.sqlite3`) are ignored by Git so device data is not committed.
