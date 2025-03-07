import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart'; // Add flutter_tts
import 'package:taptalk/global.dart';
import 'package:taptalk/recent.dart';
import 'package:taptalk/scentence.dart';
import 'dart:convert';
import 'login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isDarkMode = false;
  bool isBottomSheetOpen = false; // Track if the bottom sheet is open

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
  String? currentlyPlayingSentence; // Track the currently playing sentence

  @override
  void initState() {
    super.initState();
    _initializeTts(); // Initialize TTS settings
  }

  // Initialize TTS settings
  void _initializeTts() async {
    await flutterTts.setLanguage("en-US"); // Set language
    await flutterTts.setPitch(1); // Set pitch
    await flutterTts.setSpeechRate(0.4); // Set speech rate
    await flutterTts.awaitSpeakCompletion(true); // Wait for speech completion
  }

  void _playSentence(String sentence) async {
    if (currentlyPlayingSentence == sentence) {
      // If the same sentence is tapped again, stop playing
      await flutterTts.stop();
      setState(() {
        currentlyPlayingSentence = null; // Clear the currently playing sentence
      });
    } else {
      // Stop any ongoing speech
      await flutterTts.stop();

      // Play the new sentence
      setState(() {
        currentlyPlayingSentence =
            sentence; // Set the currently playing sentence
      });

      await flutterTts.speak(sentence);

      // Wait for the speech to complete
      await flutterTts.awaitSpeakCompletion(true);

      // After speech completes, clear the currently playing sentence
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
    flutterTts.stop(); // Stop TTS when the widget is disposed
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  void _handleKeywordSelection(String keyword) async {
    setState(() {
      keywordList.add(keyword); // Add keyword to the list
      isBottomSheetOpen = true; // Open the bottom sheet
    });

    // Call Flask backend to generate the next set of keywords
    await _generateNextKeywords();
  }

  void _clearKeywords() {
    setState(() {
      keywordList.clear(); // Clear the keyword list
      isBottomSheetOpen = false; // Close the bottom sheet

      // Keep only the first list in wordSets
      if (wordSets.isNotEmpty) {
        wordSets = [wordSets[0]];
      }

      // Reset the current grid index to 0
      currentGridIndex = 0;

      // Animate back to the first grid
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  // Function to call Flask backend and generate the next set of keywords
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
    return MaterialApp(
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(), // Apply theme
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "TapTalk",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _logout(context),
            ),
          ],
        ),
        drawer: Drawer(
          // Hamburger menu
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.black,
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              // In the HomePage's drawer menu
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
                  // Navigator.pop(context);
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
                  isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: _toggleDarkMode,
                ),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            // PageView for sliding grids
            PageView.builder(
              controller: _pageController,
              itemCount: wordSets.length,
              onPageChanged: (index) {
                setState(() {
                  currentGridIndex = index; // Update the current grid index
                });
              },
              itemBuilder: (context, index) {
                final currentWords =
                    wordSets[index]; // Get the current word set
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
                              color: isDarkMode ? Colors.white : Colors.black,
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
                                color: isDarkMode ? Colors.white : Colors.black,
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
                    color: isDarkMode ? Colors.white : Colors.black,
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
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            // Bottom Sheet as a persistent widget
            if (isBottomSheetOpen)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height *
                      0.3, // Adjust height as needed
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.black : Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    border: Border.all(
                      color: isDarkMode ? Colors.white : Colors.black,
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
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: isDarkMode ? Colors.white : Colors.black,
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
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    )
                                  : null,
                              title: Text(
                                sentence,
                                style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
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
      ),
    );
  }

  // Helper function to check if a sentence contains all keywords as whole words
  bool _containsKeywords(String sentence, List<String> keywords) {
    final wordsInSentence = sentence.toLowerCase().split(RegExp(r'\W+'));
    return keywords
        .every((keyword) => wordsInSentence.contains(keyword.toLowerCase()));
  }
}
