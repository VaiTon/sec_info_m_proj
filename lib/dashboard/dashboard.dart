// SPDX-FileCopyrightText: 2025 Eyad Issa <eyadlorenzo@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:almastudio/dashboard/pages/me.dart';
import 'package:almastudio/dashboard/pages/stats.dart';
import 'package:almastudio/dashboard/pages/study_plan.dart';
import 'package:almastudio/dashboard/pages/enrolled_exams.dart';
import 'package:almastudio/oauth.dart';
import 'package:almastudio/unibo_api.dart';
import 'package:almastudio/main.dart';

class Dashboard extends StatefulWidget {
  final UniboAPI uniboApi;
  const Dashboard({super.key, required this.uniboApi});

  @override
  State<Dashboard> createState() => _DashboardState();
}

const double _kSmallWidthThreshold = 500;

class _DashboardState extends State<Dashboard> {
  String? _registrationNumber;
  final ScrollController _scrollController = ScrollController();

  Future<void> _logout(BuildContext context) async {
    await clearOauthToken();
    if (!context.mounted) return;
    // Rebuild MyHomePage by popping all routes and pushing it
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AlmaHomePage()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Scrollbar(
        thumbVisibility: true,
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,

          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: FutureBuilder(
              future: widget.uniboApi.getMe(),
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

                final careers = snapshot.data?.careers;
                if (careers == null || careers.isEmpty) {
                  return const Center(child: Text('No careers found.'));
                }

                // Set default registrationNumber to the latest registrationDate
                // if not already set
                if (_registrationNumber == null && careers.isNotEmpty) {
                  careers.sort((a, b) {
                    final aDate = a.registrationDate;
                    final bDate = b.registrationDate;
                    if (aDate == null && bDate == null) return 0;
                    if (aDate == null) return 1;
                    if (bDate == null) return -1;
                    return bDate.compareTo(aDate);
                  });
                  _registrationNumber = careers.first.registrationNumber;
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildProfileButton(context),
                    const SizedBox(height: 16),
                    _buildCareerDropdown(context, careers),

                    if (_registrationNumber != null &&
                        _registrationNumber!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildCareerTitle(context, careers),
                      _buildDashboardButtons(context, careers),
                    ],
                    const SizedBox(height: 40),
                    // Logout button at the bottom
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _logout(context),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    final textStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);

    final borderSide = BorderSide(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
      width: 2,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < _kSmallWidthThreshold;

        final maxWidth = isSmall ? double.infinity : 200.0;

        final padding = isSmall
            ? const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4)
            : const EdgeInsets.symmetric(vertical: 2.0);

        final buttonPadding = isSmall
            ? const EdgeInsets.symmetric(vertical: 18)
            : const EdgeInsets.symmetric(vertical: 18, horizontal: 32);

        final button = SizedBox(
          width: maxWidth,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.account_circle),
            label: const Text('Me'),
            style: OutlinedButton.styleFrom(
              padding: buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: textStyle,
              side: borderSide,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      MeWidget(dataFetcher: () => widget.uniboApi.getMe()),
                ),
              );
            },
          ),
        );

        if (isSmall) {
          return Padding(padding: padding, child: button);
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [button],
          );
        }
      },
    );
  }

  Widget _buildCareerDropdown(BuildContext context, List<Career> careers) {
    var dropdownItems = careers.map<DropdownMenuItem<String>>(
      (career) => DropdownMenuItem<String>(
        value: career.registrationNumber,
        child: Text(
          '${career.description} (${career.type} - ${career.id}) [${career.status}]',
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    var selectedRegNumber = _registrationNumber;
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth < _kSmallWidthThreshold
            ? double.infinity
            : 600.0;

        return SizedBox(
          width: maxWidth,
          child: DropdownButtonFormField<String>(
            value: selectedRegNumber,
            items: dropdownItems.toList(),
            isExpanded: true,
            isDense: false,
            onChanged: (value) {
              setState(() {
                _registrationNumber = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Select Career',
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            ),
          ),
        );
      },
    );
  }

  // _buildProfileInfo removed

  Widget _buildCareerTitle(BuildContext context, List<Career> careers) {
    final career = careers.firstWhere(
      (c) => c.registrationNumber == _registrationNumber,
    );
    return Text(
      "Career: ${career.description} [${career.type} - ${career.id}]",
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        color: Colors.blueGrey[700],
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDashboardButtons(BuildContext context, List<Career> careers) {
    final buttons = [
      _DashboardSquareButton(
        icon: Icons.table_chart,
        label: 'Study Plan',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StudyPlanTable(
                dataFetcher: () =>
                    widget.uniboApi.getStudyPlans(_registrationNumber!),
              ),
            ),
          );
        },
      ),
      _DashboardSquareButton(
        icon: Icons.bar_chart,
        label: 'Stats',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StatsWidget(
                dataFetcher: () =>
                    widget.uniboApi.getStats(_registrationNumber!),
                studyPlanFetcher: () =>
                    widget.uniboApi.getStudyPlans(_registrationNumber!),
              ),
            ),
          );
        },
      ),
      _DashboardSquareButton(
        icon: Icons.assignment,
        label: 'Enrolled Exams',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EnrolledExamsScreen(
                dataFetcher: () =>
                    widget.uniboApi.getEnrolledExams(_registrationNumber!),
              ),
            ),
          );
        },
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < _kSmallWidthThreshold) {
            // Small width: show as a vertical list with reduced margin
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: buttons
                  .map(
                    (btn) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: btn,
                    ),
                  )
                  .toList(),
            );
          } else {
            // Large width: show as a grid (Wrap)
            return Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: buttons,
            );
          }
        },
      ),
    );
  }
}

class _DashboardSquareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DashboardSquareButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.15),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                label,

                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
