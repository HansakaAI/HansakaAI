import 'package:flutter/material.dart';
import 'ai_service.dart';
import 'quiz_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tech Malli AI',
      theme: ThemeData(primarySwatch: Colors.purple, useMaterial3: true),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AIService ai = AIService();
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [
    {"role": "ai", "text": "ආයුබෝවන් මචං! 😎🔥\nමම Tech Malli!\n\n2014-2026 IT Paper ටිකම මම කටපාඩම් කරලා තියෙන්නේ.\n\n📚 Paper Mode - Paper වලින් උත්තර\n🤖 General Mode - ඕනම දෙයක්, විහිළුත් එක්ක\n\nමොකක්ද අහන්නේ බං? 😂"}
  ];
  bool loading = false;
  int selectedYear = 2024;
  String selectedMode = "paper";

  @override
  void initState() { super.initState(); ai.loadPapers(); }

  void send() async {
    if (_controller.text.isEmpty) return;
    String q = _controller.text;
    _controller.clear();
    setState(() { messages.add({"role": "user", "text": q}); loading = true; });
    String ans = await ai.askQuestion(q, year: selectedYear, mode: selectedMode);
    setState(() { messages.add({"role": "ai", "text": ans}); loading = false; });
  }

  void quickAsk(String q) { _controller.text = q; send(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tech Malli 😎🔥"), backgroundColor: Colors.purple, foregroundColor: Colors.white),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(label: Text("📚 Paper Mode"), selected: selectedMode == "paper", selectedColor: Colors.purple[200], onSelected: (_) => setState(() => selectedMode = "paper")),
                SizedBox(width: 10),
                ChoiceChip(label: Text("🤖 General AI"), selected: selectedMode == "general", selectedColor: Colors.orange[200], onSelected: (_) => setState(() => selectedMode = "general")),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text("Year: "),
                DropdownButton<int>(
                  value: selectedYear,
                  items: [2014,2015,2016,2017,2018,2020,2021,2022,2023,2024,2025,2026].map((y) => DropdownMenuItem(value: y, child: Text("$y"))).toList(),
                  onChanged: (v) => setState(() => selectedYear = v!),
                ),
                Spacer(),
                ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(ai: ai))), child: Text("Quiz 📝")),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _quickBtn("😂 විහිළුවක් කියන්න"),
                _quickBtn("💻 Python ඉගන්නන්න"),
                _quickBtn("📚 2024 Paper එකේ අමාරුම ප්‍රශ්නේ මොකක්ද?"),
                _quickBtn("😩 Exam එකට බයයි"),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (c, i) {
                bool isUser = messages[i]['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(color: isUser ? Colors.purple[100] : Colors.grey[200], borderRadius: BorderRadius.circular(15)),
                    child: Text(messages[i]['text']!, style: TextStyle(fontSize: 15)),
                  ),
                );
              },
            ),
          ),
          if (loading) LinearProgressIndicator(color: Colors.purple),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller, decoration: InputDecoration(hintText: "මචං මොකක්ද අහන්නේ... 😎", border: OutlineInputBorder(borderRadius: BorderRadius.circular(25))))),
                SizedBox(width: 8),
                CircleAvatar(backgroundColor: Colors.purple, child: IconButton(icon: Icon(Icons.send, color: Colors.white), onPressed: send)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickBtn(String text) {
    return Padding(padding: EdgeInsets.all(4), child: ActionChip(label: Text(text), onPressed: () => quickAsk(text)));
  }
}
