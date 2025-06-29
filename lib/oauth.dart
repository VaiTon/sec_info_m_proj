// SPDX-FileCopyrightText: 2025 Eyad Issa <eyadlorenzo@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Generates a random string for state or nonce (URL-safe, 16 bytes by default)
String generateRandomB64({int length = 16}) {
  final random = Random.secure();
  final values = List<int>.generate(length, (i) => random.nextInt(256));
  return base64UrlEncode(values).replaceAll('=', '');
}

/// Generates a PKCE code verifier (43-128 chars, URL-safe)
String generateCodeVerifier({int length = 64}) {
  final random = Random.secure();
  final values = List<int>.generate(length, (i) => random.nextInt(256));
  return base64UrlEncode(values).replaceAll('=', '');
}

/// Generates a PKCE code challenge from a code verifier (S256)
String generateCodeChallenge(String codeVerifier) {
  final bytes = utf8.encode(codeVerifier);
  final digest = sha256.convert(bytes);
  return base64UrlEncode(digest.bytes).replaceAll('=', '');
}

final FlutterSecureStorage _storage = const FlutterSecureStorage();

class OAuthToken {
  final String accessToken;
  final String refreshToken;

  const OAuthToken({required this.accessToken, required this.refreshToken});
}

void saveOAuthToken(OAuthToken token) async {
  await _storage.write(key: "_oauth_token", value: token.accessToken);
  await _storage.write(key: "_oauth_refresh_token", value: token.refreshToken);
}

Future<OAuthToken?> getOauthToken() async {
  String? accessToken = await _storage.read(key: "_oauth_token");
  String? refreshToken = await _storage.read(key: "_oauth_refresh_token");

  if (accessToken != null && refreshToken != null) {
    return OAuthToken(accessToken: accessToken, refreshToken: refreshToken);
  } else {
    return null;
  }
}

Future<void> clearOauthToken() async {
  await _storage.delete(key: "_oauth_token");
  await _storage.delete(key: "_oauth_refresh_token");
}

final _oauthTokenEndpoint = Uri.parse('https://idp.unibo.it/adfs/oauth2/token');
final oauthAuthorizationEndpoint = Uri.parse(
  'https://idp.unibo.it/adfs/oauth2/authorize',
);

Future<OAuthToken> pkceExchangeAuthToken(
  String authToken,
  String codeVerifier,
) async {
  // Exchange code for token

  final response = await http.post(
    _oauthTokenEndpoint,
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {
      'grant_type': 'authorization_code',
      'client_id': 'd4c8cecc-4b43-419b-b0c9-d84ce688e508',
      'redirect_uri': 'https://myunibo.unibo.it/signin',
      'code': authToken,
      'code_verifier': codeVerifier,
      'resource': 'https://myunibo.unibo.it/mobileapp-relying-party',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Token request failed: ${response.body}');
  }

  final data = jsonDecode(response.body);

  final accessToken = data['access_token'] as String?;
  final refreshToken = data['refresh_token'] as String?;

  if (accessToken == null || refreshToken == null) {
    throw Exception('Token response missing access_token or refresh_token');
  }

  return OAuthToken(accessToken: accessToken, refreshToken: refreshToken);
}

final oauthClientId = 'd4c8cecc-4b43-419b-b0c9-d84ce688e508';
final oauthRedirectUri = 'https://myunibo.unibo.it/signin';
final oauthResource = 'https://myunibo.unibo.it/mobileapp-relying-party';

Uri createAuthUrl({
  required String codeChallenge,
  required String state,
  required String nonce,
}) {
  final params = {
    'client_id': oauthClientId,
    'redirect_uri': oauthRedirectUri,
    'resource': oauthResource,
    'response_type': 'code',
    'response_mode': 'query',
    'code_challenge_method': 'S256',
    'code_challenge': codeChallenge,
    'state': state,
    'nonce': nonce,
  };

  final redirectUri = oauthAuthorizationEndpoint.replace(
    queryParameters: params,
  );

  return redirectUri;
}
