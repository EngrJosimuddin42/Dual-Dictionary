import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'db_helper.dart';
import 'package:intl/intl.dart';

enum DictionaryMode { englishToBangla, banglaToEnglish }

class DictionaryHome extends StatefulWidget {
  const DictionaryHome({super.key});

  @override
  State<DictionaryHome> createState() => _DictionaryHomeState();
}

class _DictionaryHomeState extends State<DictionaryHome> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String? _wordDetails;
  DictionaryMode _mode = DictionaryMode.englishToBangla;
  List<String> _suggestions = [];
  List<Map<String, String>> _recentSearches = [];
  late SharedPreferences _prefs;

  static const String recentEnKey = "recent_searches_english";
  static const String recentBnKey = "recent_searches_bangla";

  @override
  void initState() {
    super.initState();
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadRecentSearches();
  }

  void _loadRecentSearches() {
    final list = _mode == DictionaryMode.englishToBangla
        ? (_prefs.getStringList(recentEnKey) ?? [])
        : (_prefs.getStringList(recentBnKey) ?? []);

    setState(() {
      _recentSearches = list
          .map((e) {
        final parts = e.split('|');
        return {'word': parts[0], 'date': parts[1]};
      })
          .toList();
    });
  }

  Future<void> _saveRecentSearches() async {
    final list =
    _recentSearches.map((e) => '${e['word']}|${e['date']}').toList();
    if (_mode == DictionaryMode.englishToBangla) {
      await _prefs.setStringList(recentEnKey, list);
    } else {
      await _prefs.setStringList(recentBnKey, list);
    }
  }

  Future<void> _updateSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() => _suggestions.clear());
      return;
    }

    final results = _mode == DictionaryMode.englishToBangla
        ? await DBHelper.getMatchingEnglishWords(query)
        : await DBHelper.getMatchingBanglaWords(query);

    setState(() => _suggestions = results);
  }

  Future<void> _searchWord([String? word]) async {
    final searchWord = (word ?? _searchController.text).trim();
    if (searchWord.isEmpty) return;

    final result = _mode == DictionaryMode.englishToBangla
        ? await DBHelper.getEnglishWordDetails(searchWord)
        : await DBHelper.getBanglaWordDetails(searchWord);

    setState(() {
      _wordDetails = result ??
          (_mode == DictionaryMode.englishToBangla
              ? "Meaning:  Sorry! No result found.\nPart of Speech: -\nExample: -"
              : "অর্থ: দুঃখিত! এই শব্দটি পাওয়া যায়নি।\nশব্দের প্রকার: -\nউদাহরণ: -");
      _searchController.text = searchWord;
      _suggestions.clear();
    });

    // Save recent search
    _recentSearches.removeWhere((e) => e['word'] == searchWord);
    _recentSearches.insert(0, {
      'word': searchWord,
      'date': DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()),
    });
    if (_recentSearches.length > 20) _recentSearches.removeLast();
    _saveRecentSearches();

    _searchFocusNode.unfocus();
  }

  void _switchMode() {
    setState(() {
      _mode = _mode == DictionaryMode.englishToBangla
          ? DictionaryMode.banglaToEnglish
          : DictionaryMode.englishToBangla;
      _searchController.clear();
      _wordDetails = null;
      _suggestions.clear();
    });
    _loadRecentSearches();
    FocusScope.of(context).requestFocus(_searchFocusNode);
  }

  void _showRecentSearches() {
    if (_recentSearches.isEmpty) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Recent Searches",
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton(
                  onPressed: () {
                    _clearRecentSearches();
                    Navigator.pop(context);
                  },
                  child: const Text("Clear All",
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _recentSearches.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, index) {
                  final item = _recentSearches[index];
                  return ListTile(
                    title: Text(item['word']!),
                    subtitle: Text(item['date']!),
                    onTap: () {
                      _searchController.text = item['word']!;
                      _searchWord(item['word']);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearRecentSearches() {
    setState(() => _recentSearches.clear());
    _saveRecentSearches();
  }

  void _copyMeaning() {
    if (_wordDetails != null) {
      Clipboard.setData(ClipboardData(text: _wordDetails!));
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Copied to clipboard")));
    }
  }

  void _shareMeaning() {
    if (_wordDetails != null) Share.share(_wordDetails!);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        elevation: 3,
        centerTitle: true,
        title: const Text(
          "Dual Dictionary",
          style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: GestureDetector(
                onTap: _switchMode,
                child: Text(
                  _mode == DictionaryMode.englishToBangla
                      ? "English → বাংলা"
                      : "বাংলা → English",
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            autofocus: true,
            onChanged: _updateSuggestions,
            decoration: InputDecoration(
              labelText: _mode == DictionaryMode.englishToBangla
                  ? "Search English Word"
                  : "বাংলা শব্দ খুঁজুন",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: const Icon(Icons.history, color: Colors.indigo),
                      onPressed: _showRecentSearches),
                  IconButton(
                      icon: const Icon(Icons.search, color: Colors.indigo),
                      onPressed: () => _searchWord()),
                ],
              ),
            ),
            onSubmitted: (_) => _searchWord(),
          ),
          if (_suggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.indigo.shade100),
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final word = _suggestions[index];
                  return ListTile(
                    title: Text(word),
                    onTap: () => _searchWord(word),
                  );
                },
              ),
            ),
          const SizedBox(height: 20),
          if (_wordDetails != null)
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.indigo.shade100),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _wordDetails!,
                        style: const TextStyle(
                            fontFamily: 'Poppins', fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              icon: const Icon(Icons.copy, color: Colors.indigo),
                              onPressed: _copyMeaning),
                          IconButton(
                              icon:
                              const Icon(Icons.share, color: Colors.indigo),
                              onPressed: _shareMeaning),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}
