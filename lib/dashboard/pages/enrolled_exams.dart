// SPDX-FileCopyrightText: 2025 Eyad Issa <eyadlorenzo@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:almastudio/unibo_api.dart';

class EnrolledExamsScreen extends StatelessWidget {
  EnrolledExamsScreen({super.key, required this.dataFetcher});

  final Future<List<EnrolledExam>> Function() dataFetcher;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enrolled Exams')),
      body: FutureBuilder(
        future: dataFetcher(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: SelectableText(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No past or future enrolled exams'),
            );
          }

          final exams = snapshot.data!;
          final now = DateTime.now();
          final upcomingExams = exams.where((e) => e.date.isAfter(now)).toList();
          final pastExams = exams.where((e) => e.date.isBefore(now)).toList();

          if (upcomingExams.isEmpty && pastExams.isEmpty) {
            return const Center(
              child: Text('No past or future enrolled exams'),
            );
          }

          return Scrollbar(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                if (upcomingExams.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
                    child: Text(
                      'Upcoming Exams',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...upcomingExams.map((exam) => _buildSubjectCard(context, exam)),
                  const SizedBox(height: 24),
                ],
                if (pastExams.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
                    child: Text(
                      'Past Exams',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...pastExams.map((exam) => _buildSubjectCard(context, exam)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Card _buildSubjectCard(BuildContext context, EnrolledExam exam) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blueGrey[100]!, width: 1.2),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment, color: Colors.blueGrey[400], size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "${exam.learningActivity.description}: ${exam.description}",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (exam.cancelable)
                  const Text(
                    ' (Cancelable)',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else if (exam.date.isBefore(DateTime.now()))
                  const Text(
                    ' (Past Exam)',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  const SizedBox(width: 24),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: Colors.blueGrey[300],
                ),
                const SizedBox(width: 6),
                Text(
                  DateFormat.yMd().add_Hm().format(exam.date.toLocal()),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 16),
                Icon(Icons.place, size: 18, color: Colors.blueGrey[300]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    exam.place,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.person, size: 18, color: Colors.blueGrey[300]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${exam.teacher.firstName} ${exam.teacher.lastName}',
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.numbers, size: 18, color: Colors.blueGrey[300]),
                const SizedBox(width: 6),
                Text(
                  'Placement: ${exam.placement}/${exam.placementBase}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
