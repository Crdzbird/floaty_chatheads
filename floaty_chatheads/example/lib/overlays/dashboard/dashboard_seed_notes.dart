import 'package:flutter/material.dart';

import 'dashboard_note.dart';

/// Returns a new, growable list with the notes the dashboard starts with.
List<DashboardNote> dashboardSeedNotes() => [
      const DashboardNote(
        title: 'Welcome!',
        body: 'This is a near-fullscreen overlay with scrollable content. '
            'Try scrolling down to see more notes.',
        color: Colors.indigo,
        pinned: true,
      ),
      const DashboardNote(
        title: 'Shopping List',
        body: '- Milk\n- Eggs\n- Bread\n- Coffee\n- Bananas',
        color: Colors.teal,
      ),
      const DashboardNote(
        title: 'Meeting Notes',
        body: 'Discussed project timeline, assigned tasks to team members. '
            'Follow up next Monday for progress update.',
        color: Colors.deepOrange,
      ),
      const DashboardNote(
        title: 'Ideas',
        body: '1. Build a weather widget overlay\n'
            '2. Add voice memo support\n'
            '3. Integrate calendar events\n'
            '4. Dark mode toggle',
        color: Colors.purple,
      ),
      const DashboardNote(
        title: 'Reminders',
        body: '- Call dentist at 3 PM\n'
            '- Pick up dry cleaning\n'
            '- Reply to email from Sarah\n'
            '- Buy birthday gift',
        color: Colors.amber,
      ),
      const DashboardNote(
        title: 'Quote of the Day',
        body: '"The best way to predict the future is to create it." '
            '- Peter Drucker',
        color: Colors.cyan,
      ),
      const DashboardNote(
        title: 'Workout Plan',
        body: 'Mon: Upper body\n'
            'Tue: Cardio\n'
            'Wed: Lower body\n'
            'Thu: Rest\n'
            'Fri: Full body\n'
            'Sat: Yoga\n'
            'Sun: Rest',
        color: Colors.green,
      ),
    ];
