// recent.dart
import 'package:flutter/material.dart';
import 'global.dart';

class RecentPage extends StatelessWidget {
  const RecentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recently Played Sentences'),
      ),
      body: ListView.builder(
        itemCount: recentList.length,
        itemBuilder: (context, index) {
          final sentence = recentList[index];
          return ListTile(
            title: Text(sentence),
          );
        },
      ),
    );
  }
}
