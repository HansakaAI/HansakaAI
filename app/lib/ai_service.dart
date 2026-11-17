import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String apiKey = "gsk_ඔයාගේ-Groq-Key-එක-මෙතනට";
  static const String dataUrl = "https://raw.githubusercontent.com/YOUR_USERNAME/AL-Tech-AI/main/data/questions.json";
  List<dynamic> _papers = [];

  Future<void> loadPapers() async {
    try {
      final res = await http.get(Uri.parse(dataUrl));
      if (res.statusCode == 200) _papers = jsonDecode(res.body);
    } catch (e) { print("Load failed: $e"); }
  }

  String detectMood(String msg) {
    String m = msg.toLowerCase();
    List<String> funnyWords = ["machan","mchn","ado","bng","bn","patta","maru","ela","😂","🤣","😎","🔥","lol","haha","vihilu","joke","funny","moko","niyamai","supiri","ammo","hapo"];
    List<String> sadWords = ["bayai","baya","sad","duka","fail","behe","epa","amru","😭","😢","😩","help","stress","tired"];
    List<String> seriousWords = ["paper","exam","question","prashne","explain","kiyala","denna","padam","theory","marking","syllabus"];
    int funnyScore = 0, sadScore = 0, seriousScore = 0;
    for (var w in funnyWords) if (m.contains(w)) funnyScore++;
    for (var w in sadWords) if (m.contains(w)) sadScore++;
    for (var w in seriousWords) if (m.contains(w)) seriousScore++;
    if (sadScore > 0) return "sad";
    if (funnyScore >= 1) return "funny";
    if (seriousScore > 0) return "serious";
    return "normal";
  }

  Future<String> _callGroq(String prompt) async {
    final res = await http.post(
      Uri.parse("https://api.groq.com/openai/v1/chat/completions"),
      headers: {"Authorization": "Bearer $apiKey", "Content-Type": "application/json"},
      body: jsonEncode({
        "model": "llama-3.3-70b-versatile",
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.8,
      }),
    );
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      return data['choices'][0]['message']['content'];
    } else {
      return "අඩෝ මචං Groq එකෙන් Error එකක් ආවා 😅 Key එක හරියට දැම්මද බලපන් - ${res.statusCode}";
    }
  }

  Future<String> askQuestion(String question, {int? year, String mode = "paper"}) async {
    String mood = detectMood(question);
    String moodInstruction = "";
    if (mood == "funny") {
      moodInstruction = "USER IS IN FUNNY MOOD! YOU MUST BE 10X FUNNIER! Use slang 'අඩෝ මචං, පට්ටයි බං, මරු'. Start with joke, end with joke. LOTS of emojis 😂🤣🔥😎. Roast friendly. Talk like best friend in canteen.";
    } else if (mood == "sad") {
      moodInstruction = "USER IS SAD / SCARED. Be funny BUT caring. First say 'අඩෝ බය වෙන්න එපා බං, මම ඉන්නවානේ 💪'. Motivate.";
    } else if (mood == "serious") {
      moodInstruction = "USER IS SERIOUS / STUDY MODE. Be 70% Teacher + 30% Funny. Give correct answer first, then ONE funny example. End with 'මේක Exam එකට එනවා, ලියාගනින් 📝'";
    } else {
      moodInstruction = "USER IS NORMAL. Be friendly + a little funny. Like a cool teacher. 2-3 emojis only.";
    }

    if (mode == "general") {
      return await _callGroq('''
You are "Tech Malli" - Sri Lanka's funniest AI friend.
USER MOOD: $mood
$moodInstruction
RULES: NEVER say "As an AI". You are Tech Malli. Reply in same language user used. Mirror user's energy. Keep SHORT for mobile. If user roasts you, roast back friendly!
User: $question
''');
    }

    String context = "";
    if (_papers.isNotEmpty) {
      var relevant = _papers;
      if (year != null) relevant = _papers.where((p) => p['year'] == year).toList();
      if (relevant.length > 3) relevant = relevant.sublist(relevant.length - 3);
      for (var p in relevant) {
        context += "\n--- ${p['year']} IT Paper ---\n${p['content'].toString().substring(0, 8000)}\n";
      }
    }
    return await _callGroq('''
You are "Tech Malli" - Funniest A/L IT Teacher.
USER MOOD: $mood
$moodInstruction
Past Paper Data:
$context
Student: $question
RULES: ALWAYS mention year like "2023 IT - Q5". Mirror user's tone. Explain with funny real life examples. End with motivation.
''');
  }

  Future<List<Map<String, dynamic>>> generateQuiz({int year = 2024, String topic = "All"}) async {
    String q = "Make 10 funny MCQ for A/L IT $year, topic $topic, from past papers. Return ONLY JSON [{\"question\":\"...\",\"options\":[\"A\",\"B\",\"C\",\"D\"],\"correct\":0,\"explain\":\"Funny Sinhala explain\"}]";
    String res = await askQuestion(q, year: year, mode: "paper");
    try {
      res = res.replaceAll("```json", "").replaceAll("```", "").trim();
      List list = jsonDecode(res);
      return list.cast<Map<String, dynamic>>();
    } catch (e) { return []; }
  }
}
