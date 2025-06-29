// SPDX-FileCopyrightText: 2025 Eyad Issa <eyadlorenzo@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:almastudio/unibo_api.dart';
import 'package:almastudio/dashboard/dashboard.dart';
import 'oauth.dart';
import 'auth_screen.dart';

import 'package:intl/intl_default.dart'
    if (dart.library.html) 'package:intl/intl_browser.dart'
    if (dart.library.io) 'package:intl/intl_standalone.dart';

void main() async {
  await initializeDateFormatting('it_IT', null);
  await findSystemLocale();
  runApp(const AlmaStudio());
}

class AlmaStudio extends StatelessWidget {
  const AlmaStudio({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlmaStudio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 201, 17, 4),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 211, 16, 2),
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
        textTheme: ThemeData.light().textTheme.copyWith(
          headlineSmall: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          titleMedium: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: const AlmaHomePage(),
    );
  }
}

class AlmaHomePage extends StatefulWidget {
  const AlmaHomePage({super.key});

  @override
  State<AlmaHomePage> createState() => _AlmaHomePageState();
}

class _AlmaHomePageState extends State<AlmaHomePage> {
  late String _oauthState;
  late String _oauthNonce;
  late String _oauthCodeVerifier;
  late String _oauthCodeChallenge;
  late Future<OAuthToken?> _oauthTokens;

  @override
  void initState() {
    super.initState();
    // Generate state, nonce, PKCE verifier/challenge
    _oauthState = generateRandomB64();
    _oauthNonce = generateRandomB64();
    _oauthCodeVerifier = generateCodeVerifier();
    _oauthCodeChallenge = generateCodeChallenge(_oauthCodeVerifier);
    _oauthTokens = getOauthToken();
  }

  Future<void> _handleCallbackUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      final authCode = uri.queryParameters['code'];
      if (authCode == null) {
        throw Exception('No code found in callback URL');
      }

      // Exchange code for token
      final tokens = await pkceExchangeAuthToken(authCode, _oauthCodeVerifier);
      log('Successfully exchanged code for tokens!');
      saveOAuthToken(tokens);

      setState(() {
        // update the state to trigger UI update
        _oauthTokens = getOauthToken();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing callback URL: $e')),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<OAuthToken?>(
        future: _oauthTokens,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final token = snapshot.data;

          return token == null
              ? AuthScreen(
                  codeChallenge: _oauthCodeChallenge,
                  state: _oauthState,
                  nonce: _oauthNonce,
                  onCallbackSubmitted: _handleCallbackUrl,
                )
              : Dashboard(uniboApi: UniboAPI(token: token));
        },
      ),
    );
  }
}
