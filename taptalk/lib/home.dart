import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final List<List<String>> wordSets = [
    [
      "I",
      "You",
      "He",
      "She",
      "It",
      "We",
      "They",
      "Can",
      "Will",
      "Must",
      "Should",
      "Would"
    ],
    [
      "severe",
      "dizzy",
      "weak",
      "tired",
      "blurry",
      "nauseous",
      "sore",
      "sharp",
      "heart",
      "stomach",
      "headache",
      "breathing"
    ],
    // Add more word sets as needed
  ];

  int currentGridIndex = 0; // Track the current grid index
  final PageController _pageController =
      PageController(); // For sliding navigation
  List<String> keywordList = []; // Store selected keywords
  List<String> sentenceList = [
    // Predefined sentences for matching
    "I feel dizzy",
    "I have a headache",
    "My stomach hurts",
    "I feel weak and tired",
    "I have blurry vision",
    "I feel nauseous",
    "I have a sore throat",
    "I feel sharp pain in my chest",
    "I have difficulty breathing",
    "I feel severe pain",
  ];

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

  void _handleKeywordSelection(String keyword) {
    setState(() {
      keywordList.add(keyword); // Add keyword to the list
      if (currentGridIndex < wordSets.length - 1) {
        currentGridIndex++; // Move to the next grid
        _pageController.animateToPage(
          currentGridIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
      isBottomSheetOpen = true; // Open the bottom sheet
    });
  }

  void _clearKeywords() {
    setState(() {
      keywordList.clear(); // Clear the keyword list
      isBottomSheetOpen = false; // Close the bottom sheet
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(), // Apply theme
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Home",
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
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Recently Used'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text('Chat'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.record_voice_over),
                title: const Text('Speech Therapy'),
                onTap: () {
                  Navigator.pop(context);
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
                            onPressed:
                                _clearKeywords, // Clear keywords and close bottom sheet
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: sentenceList.where((sentence) {
                            return keywordList.every((keyword) => sentence
                                .toLowerCase()
                                .contains(keyword.toLowerCase()));
                          }).length,
                          itemBuilder: (context, index) {
                            final matchedSentences =
                                sentenceList.where((sentence) {
                              return keywordList.every((keyword) => sentence
                                  .toLowerCase()
                                  .contains(keyword.toLowerCase()));
                            }).toList();
                            return ListTile(
                              title: Text(
                                matchedSentences[index],
                                style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
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
}
