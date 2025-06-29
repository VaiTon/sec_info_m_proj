// SPDX-FileCopyrightText: 2025 Eyad Issa <eyadlorenzo@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:almastudio/unibo_api.dart';

class StudyPlanTable extends StatefulWidget {
  final Future<StudyPlanResponse> Function() dataFetcher;

  const StudyPlanTable({super.key, required this.dataFetcher});

  @override
  State<StudyPlanTable> createState() => _StudyPlanTableState();
}

class _StudyPlanTableState extends State<StudyPlanTable> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
          // Give the FutureBuilder a moment to refetch
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: FutureBuilder(
          future: widget.dataFetcher(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return SelectableText(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              );
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Text('No study plan data.');
            }

            var activities = snapshot.data!.learningActivities;
            if (activities.isEmpty) {
              return const Text('No learning activities found.');
            }

            final completedCount = activities
                .where((a) => a.outcome?.passed == true)
                .length;
            final totalCount = activities.length;
            final completionRatio = totalCount > 0
                ? completedCount / totalCount
                : 0.0;

            // Sort: by recordDate descending, then by description ascending
            activities = List.of(activities);
            activities.sort((a, b) {
              if (a.recordDate != null && b.recordDate != null) {
                return b.recordDate!.compareTo(a.recordDate!);
              } else if (a.recordDate != null) {
                return -1;
              } else if (b.recordDate != null) {
                return 1;
              } else {
                return a.description.compareTo(b.description);
              }
            });

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.school, color: Colors.blueGrey[400]),
                          const SizedBox(width: 8),
                          Text(
                            'Completed exams',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: Colors.blueGrey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            '$completedCount / $totalCount',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.blueGrey[900],
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: completionRatio,
                          minHeight: 10,
                          backgroundColor: Colors.blueGrey[100],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green[400]!,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: activities.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      final isRecorded = activity.recordDate != null;

                      final outcome = activity.outcome;

                      return _buildSubjCard(
                        isRecorded,
                        activity,
                        context,
                        outcome,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Card _buildSubjCard(
    bool isRecorded,
    LearningActivity activity,
    BuildContext context,
    Outcome? outcome,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0, // Remove shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isRecorded ? Colors.green : Colors.grey.shade400,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    activity.description,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (isRecorded)
                  Tooltip(
                    message: 'Recorded',
                    child: Icon(Icons.verified, color: Colors.green[700]),
                  ),
              ],
            ),
            if (outcome != null && outcome.passed) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green, width: 1.2),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (activity.outcome?.passed ?? false) ...[
                      Text(
                        'Passed',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        outcome.value,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.green[800],
                        ),
                      ),
                      if (outcome.honours) ...[
                        const SizedBox(width: 8),
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'L',
                            style: TextStyle(
                              color: Colors.amber[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (isRecorded)
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      DateFormat.yMMMMEEEEd().format(activity.recordDate!),
                      style: TextStyle(
                        color: Colors.green[800],
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            _InfoRow(label: 'Code', value: activity.code),
            _InfoRow(label: 'Year', value: activity.programmeYear.toString()),
            _InfoRow(label: 'Credits', value: activity.credits.toString()),
            _InfoRow(
              label: 'Useful',
              value: activity.useful ?? false ? 'Yes' : 'No',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}
