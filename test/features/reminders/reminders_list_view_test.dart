import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yusr_app/features/reminders/data/models/reminder_model.dart';
import 'package:yusr_app/features/reminders/presentation/widgets/reminders_list_view.dart';

void main() {
  testWidgets('supports toggle, edit tap and dismiss delete flows', (
    tester,
  ) async {
    final reminder = ReminderModel(
      id: '1',
      titleKey: 'Morning Athkar',
      subtitleKey: 'Daily',
      hour: 8,
      minute: 0,
      enabled: true,
      iconCodeInfo: Icons.auto_awesome.codePoint,
    );

    bool deleted = false;
    bool toggled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RemindersListView(
            reminders: <ReminderModel>[reminder],
            onDelete: (r) async {
              deleted = true;
            },
            onConfirmDelete: (r) async => true,
            onToggle: (r, enabled) async {
              toggled = true;
            },
            onTimeChanged: (r, time) async {},
            onRefresh: () async {},
          ),
        ),
      ),
    );

    await tester.tap(find.byType(Switch));
    await tester.pump();

    await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(toggled, isTrue);
    expect(deleted, isTrue);
  });
}
