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

                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildCareerDropdown(context, careers),
                    const SizedBox(height: 24),
                    _buildProfileInfo(context),
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

  Widget _buildCareerDropdown(BuildContext context, List<Career> careers) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Select Career',
            border: InputBorder.none, // Remove the inner border
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          ),
          isExpanded: true,
          items: careers
              .map<DropdownMenuItem<String>>(
                (career) => DropdownMenuItem<String>(
                  value: career.registrationNumber,
                  child: Text(
                    '${career.description} (${career.type} - ${career.id}) [${career.status}]',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _registrationNumber = value;
            });
          },
          value: _registrationNumber,
        ),
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context) {
    return Column(
      children: [
        Text(
          "Profile Information",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.blueGrey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _DashboardSquareButton(
                icon: Icons.account_circle,
                label: 'Me',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          MeWidget(dataFetcher: () => widget.uniboApi.getMe()),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

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
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 16,
        children: [
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
        ],
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 120,
          height: 120,
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
