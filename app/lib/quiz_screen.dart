import 'package:flutter/material.dart';
import 'ai_service.dart';

class QuizScreen extends StatefulWidget {
  final AIService ai;
  QuizScreen({required this.ai});
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, dynamic>> questions = [];
  int current = 0;
  int score = 0;
  bool loading = true;
  int? selected;

  @override
  void initState() { super.initState(); loadQuiz(); }

  void loadQuiz() async {
    var q = await widget.ai.generateQuiz(year: 2024);
    setState(() { questions = q; loading = false; });
  }

  void answer(int idx) {
    if (selected != null) return;
    setState(() => selected = idx);
    if (idx == questions[current]['correct']) score++;
    Future.delayed(Duration(seconds: 2), () {
      if (current < questions.length - 1) {
        setState(() { current++; selected = null; });
      } else {
        String msg = score >= 8 ? "අඩෝ පට්ටයි මචං! 🔥💪 A එකක් ෂුවර්!" : score >= 5 ? "ශා හොඳයි බං! තව පොඩ්ඩක් වැඩ කරන්න 😎" : "අඩෝ මචං පොඩ්ඩක් පාඩම් කරන්න ඕනි 😅 Tech Malli ගෙන් අහපන්!";
        showDialog(context: context, builder: (_) => AlertDialog(title: Text("Quiz ඉවරයි! 🎉"), content: Text("ලකුණු: $score / ${questions.length}\n\n$msg"), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))]));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Scaffold(appBar: AppBar(title: Text("Quiz...")), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 10), Text("Tech Malli Quiz හදනවා... 😎")])));
    if (questions.isEmpty) return Scaffold(appBar: AppBar(title: Text("Quiz")), body: Center(child: Text("අඩෝ Quiz එක හැදුනේ නෑ 😅 ආයෙත් Try කරන්න")));
    var q = questions[current];
    return Scaffold(
      appBar: AppBar(title: Text("Quiz ${current + 1}/${questions.length} - Score: $score 😎"), backgroundColor: Colors.purple, foregroundColor: Colors.white),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(q['question'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ...List.generate((q['options'] as List).length, (i) {
              Color? color;
              if (selected != null) {
                if (i == q['correct']) color = Colors.green[200];
                else if (i == selected) color = Colors.red[200];
              }
              return Card(color: color, child: ListTile(title: Text(q['options'][i]), onTap: () => answer(i)));
            }),
            if (selected != null) Padding(padding: EdgeInsets.only(top: 16), child: Text("Tech Malli කියනවා: ${q['explain']} 😂", style: TextStyle(color: Colors.grey[800]))),
          ],
        ),
      ),
    );
  }
}
