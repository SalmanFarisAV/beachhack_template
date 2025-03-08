import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TapToTalkBottomSheet extends StatefulWidget {
  final Function(String) onSuggestionSelected;

  const TapToTalkBottomSheet({super.key, required this.onSuggestionSelected});

  @override
  _TapToTalkBottomSheetState createState() => _TapToTalkBottomSheetState();
}

class _TapToTalkBottomSheetState extends State<TapToTalkBottomSheet> {
  List<List<String>> wordSets = [
    [
      "I",
      "You",
      "Where",
      "Help",
      "Our",
      "Can",
      "We",
      "They",
      "Will",
      "My",
      "Should",
      "Could"
    ],
  ];

  int currentGridIndex = 0;
  final PageController _pageController = PageController();
  List<String> keywordList = [];
  List<String> sentenceList = []; // Replace with your sentence list
  bool isBottomSheetOpen = true;

  // Text-to-speech
  final FlutterTts flutterTts = FlutterTts();
  String? currentlyPlayingSentence;

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  void _initializeTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.3);
    await flutterTts.awaitSpeakCompletion(true);
  }

  void _playSentence(String sentence) async {
    if (currentlyPlayingSentence == sentence) {
      await flutterTts.stop();
      setState(() {
        currentlyPlayingSentence = null;
      });
    } else {
      await flutterTts.stop();
      setState(() {
        currentlyPlayingSentence = sentence;
      });

      await flutterTts.speak(sentence);

      await flutterTts.awaitSpeakCompletion(true);

      setState(() {
        currentlyPlayingSentence = null;
      });
    }
  }

  void _handleKeywordSelection(String keyword) async {
    setState(() {
      keywordList.add(keyword);
    });

    await _generateNextKeywords();
  }

  void _clearKeywords() {
    setState(() {
      keywordList.clear();
      if (wordSets.isNotEmpty) {
        wordSets = [wordSets[0]];
      }
      currentGridIndex = 0;
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _generateNextKeywords() async {
    final inputText = keywordList.join(' ');

    final apiUrl = Uri.parse(
        'http://10.0.2.2:5000/predict_next_word?input_text=$inputText');

    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final nextKeywords = List<String>.from(responseData['suggestions']);

      setState(() {
        wordSets.add(nextKeywords);
        currentGridIndex++;
        _pageController.animateToPage(
          currentGridIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Failed to generate keywords: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tap to Talk',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.clear,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: wordSets.length,
              onPageChanged: (index) {
                setState(() {
                  currentGridIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final currentWords = wordSets[index];
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: currentWords.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _handleKeywordSelection(currentWords[index]),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: theme.colorScheme.onSurface,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            textAlign: TextAlign.center,
                            currentWords[index],
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (keywordList.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: sentenceList.where((sentence) {
                  return _containsKeywords(sentence, keywordList);
                }).length,
                itemBuilder: (context, index) {
                  final matchedSentences = sentenceList.where((sentence) {
                    return _containsKeywords(sentence, keywordList);
                  }).toList();
                  final sentence = matchedSentences[index];
                  return ListTile(
                    leading: currentlyPlayingSentence == sentence
                        ? Icon(
                            Icons.volume_up,
                            color: theme.colorScheme.onSurface,
                          )
                        : null,
                    title: Text(
                      sentence,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    onTap: () {
                      widget.onSuggestionSelected(sentence);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  bool _containsKeywords(String sentence, List<String> keywords) {
    final wordsInSentence = sentence.toLowerCase().split(RegExp(r'\W+'));
    return keywords
        .every((keyword) => wordsInSentence.contains(keyword.toLowerCase()));
  }
}
