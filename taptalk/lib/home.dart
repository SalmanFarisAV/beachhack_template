import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:taptalk/chat.dart';
import 'package:taptalk/global.dart';
import 'package:taptalk/recent.dart';
import 'package:taptalk/scentence.dart';
import 'dart:convert';
import 'login.dart';
import 'theme_provider.dart'; // Import the ThemeProvider

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isBottomSheetOpen = false;

  // List of words for the grids
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
  List<String> sentenceList = sentenceListA;

  // Text-to-speech
  final FlutterTts flutterTts = FlutterTts();
  String? currentlyPlayingSentence;

  // State variable for the selected option
  String selectedOption = 'Hospital'; // Default selected option

  // Controller for the input bar
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  // Initialize TTS settings
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

      // Add the sentence to the recentList (without duplicates)
      if (!recentList.contains(sentence)) {
        recentList.add(sentence);
      }
      
    
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _handleKeywordSelection(String keyword) async {
    setState(() {
      keywordList.add(keyword);
      isBottomSheetOpen = true;
    });

    await _generateNextKeywords();
  }

  void _clearKeywords() {
    setState(() {
      keywordList.clear();
      isBottomSheetOpen = false;

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

  void _refreshWordSets() {
    if (recentList.isNotEmpty) {
      // Find the first sentence in recentList that is not in sentenceListA
      final newSentence = recentList.firstWhere(
        (sentence) => !sentenceListA.contains(sentence),
        orElse: () => '',
      );

      if (newSentence.isNotEmpty) {
        // Take the first word of the new sentence
        final firstWord = newSentence.split(' ').first;

        setState(() {
          if (wordSets.isNotEmpty && wordSets[0].isNotEmpty) {
            // Replace the first keyword in the first grid
            wordSets[0][10] = firstWord;
          }
        });

        setState(() {
          sentenceListA.add(newSentence);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get the current theme
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "TapTalk",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshWordSets,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 24,
                ),
              ),
            ),
            // Selectable options
            RadioListTile(
              title: const Text('General'),
              value: 'General',
              groupValue: selectedOption,
              onChanged: (value) {
                setState(() {
                  selectedOption = value.toString();
                });
              },
            ),
            RadioListTile(
              title: const Text('Hospital'),
              value: 'Hospital',
              groupValue: selectedOption,
              onChanged: (value) {
                setState(() {
                  selectedOption = value.toString();
                });
              },
            ),
            RadioListTile(
              title: const Text('Market'),
              value: 'Market',
              groupValue: selectedOption,
              onChanged: (value) {
                setState(() {
                  selectedOption = value.toString();
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Recently Used'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RecentPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Chat'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.record_voice_over),
              title: const Text('Speech Therapy'),
              onTap: () {
                // Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                themeProvider.themeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeProvider.toggleTheme(); // Toggle theme
                },
              ),
            ),
            // Logout button in the drawer
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Input bar at the top
          Padding(
            padding:
                const EdgeInsets.only(top: 8, bottom: 0, right: 16, left: 16),
            child: TextField(
              controller: _inputController,
              decoration: InputDecoration(
                hintText: 'Type a sentence and press Enter...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final sentence = _inputController.text.trim();
                    if (sentence.isNotEmpty) {
                      _playSentence(sentence);
                      _inputController.clear();
                    }
                  },
                ),
              ),
              onSubmitted: (sentence) {
                if (sentence.trim().isNotEmpty) {
                  _playSentence(sentence);
                  _inputController.clear();
                }
              },
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                // PageView for sliding grids
                PageView.builder(
                  controller: _pageController,
                  itemCount: wordSets.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentGridIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final currentWords = wordSets[index];
                    return Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1,
                        ),
                        itemCount: currentWords.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () =>
                                _handleKeywordSelection(currentWords[index]),
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
                      ),
                    );
                  },
                ),
                // Left arrow (for previous grid)
                if (currentGridIndex > 0)
                  Positioned(
                    left: 8,
                    top: MediaQuery.of(context).size.height / 2 + 70,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: theme.colorScheme.onSurface,
                      ),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                // Right arrow (for next grid)
                if (currentGridIndex < wordSets.length - 1)
                  Positioned(
                    right: 0,
                    top: MediaQuery.of(context).size.height / 2 + 70,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_forward,
                        color: theme.colorScheme.onSurface,
                      ),
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          // Bottom Sheet as a persistent widget
          if (isBottomSheetOpen)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.25,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  border: Border.all(
                    color: theme.colorScheme.onSurface,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Suggestions',
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
                          onPressed: _clearKeywords,
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: sentenceList.where((sentence) {
                          return _containsKeywords(sentence, keywordList);
                        }).length,
                        itemBuilder: (context, index) {
                          final matchedSentences =
                              sentenceList.where((sentence) {
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
                            onTap: () => _playSentence(sentence),
                          );
                        },
                      ),
                    ),
                  ],
                ),
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
