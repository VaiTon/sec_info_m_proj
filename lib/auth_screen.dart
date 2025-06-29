// SPDX-FileCopyrightText: 2025 Eyad Issa <eyadlorenzo@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:almastudio/oauth.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class AuthScreen extends StatefulWidget {
  final String codeChallenge;
  final String state;
  final String nonce;
  final void Function(String) onCallbackSubmitted;

  final TextEditingController callbackController = TextEditingController();

  AuthScreen({
    super.key,
    required this.codeChallenge,
    required this.state,
    required this.nonce,
    required this.onCallbackSubmitted,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool clickedLink = false;

  @override
  Widget build(BuildContext context) {
    final redirectUrl = createAuthUrl(
      codeChallenge: widget.codeChallenge,
      state: widget.state,
      nonce: widget.nonce,
    );

    return Center(
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary.withAlpha(100),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.lock_outline,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome to AlmaStudio',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Center(
                child: OutlinedButton(
                  onPressed: () async {
                    await url_launcher.launchUrl(
                      redirectUrl,
                      mode: url_launcher.LaunchMode.externalApplication,
                    );
                    setState(() {
                      clickedLink = true;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: const Text('Click here to authenticate'),
                  ),
                ),
              ),

              if (clickedLink) ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: TextField(
                    onSubmitted: widget.onCallbackSubmitted,
                    controller: widget.callbackController,
                    decoration: const InputDecoration(
                      labelText: 'Enter callback URL after login',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    widget.onCallbackSubmitted(widget.callbackController.text);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: const Text('Submit Callback URL'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
