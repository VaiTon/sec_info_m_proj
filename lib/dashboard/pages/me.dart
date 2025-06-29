// SPDX-FileCopyrightText: 2025 Eyad Issa <eyadlorenzo@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:almastudio/unibo_api.dart';

class MeWidget extends StatelessWidget {
  final Future<MeResponse> Function() dataFetcher;

  const MeWidget({super.key, required this.dataFetcher});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Information')),
      body: FutureBuilder<MeResponse>(
        future: dataFetcher(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: SelectableText(
                snapshot.error.toString(),
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No personal information found.'));
          }
          final me = snapshot.data!;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (me.photo?.isNotEmpty ?? false)
                  Image.memory(
                    base64.decode(me.photo!),
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  )
                else
                  const Icon(
                    Icons.account_circle,
                    size: 100,
                    color: Colors.grey,
                  ),
                const SizedBox(height: 16),
                Text(
                  '${me.name} ${me.surname}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ID:',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(width: 8),
                    Chip(label: Text(me.id)),
                  ],
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text(me.email),
                  avatar: Icon(Icons.email, size: 18, color: Colors.blueGrey),
                ),
                const SizedBox(height: 8),
                Chip(
                  avatar: Icon(
                    me.admin ? Icons.verified_user : Icons.person,
                    color: me.admin ? Colors.green : Colors.blueGrey,
                  ),
                  label: Text(me.admin ? 'Admin' : 'User'),
                  backgroundColor: me.admin
                      ? Colors.green[50]
                      : Colors.blueGrey[50],
                  labelStyle: TextStyle(
                    color: me.admin ? Colors.green[800] : Colors.blueGrey[800],
                    fontWeight: FontWeight.bold,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
