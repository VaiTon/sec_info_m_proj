// SPDX-FileCopyrightText: 2025 Eyad Issa <eyadlorenzo@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'package:flutter/material.dart';

class JsonDisplayScreen extends StatefulWidget {
  final String title;
  final Future<dynamic> Function() dataFetcher;
  const JsonDisplayScreen({
    super.key,
    required this.title,
    required this.dataFetcher,
  });

  @override
  State<JsonDisplayScreen> createState() => _JsonDisplayScreenState();
}

class _JsonDisplayScreenState extends State<JsonDisplayScreen> {
  dynamic _data;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await widget.dataFetcher();
      setState(() {
        _data = data;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? SelectableText(_error!, style: const TextStyle(color: Colors.red))
            : SingleChildScrollView(
                child: SelectableText(
                  _prettyPrintJson(_data ?? {}),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
      ),
    );
  }

  String _prettyPrintJson(Map<String, dynamic> json) {
    return const JsonEncoder.withIndent('  ').convert(json);
  }
}
