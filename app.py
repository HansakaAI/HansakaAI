import streamlit as st
import requests
import json

# ===== CONFIG =====
GROQ_API_KEY = "gsk_ඔයාගේ-Groq-Key-එක-මෙතනට"  # console.groq.com එකෙන් ගත්ත Key එක
DATA_URL = "https://raw.githubusercontent.com/YOUR_USERNAME/AL-Tech-AI/main/data/questions.json"

st.set_page_config(page_title="Tech Malli 😎", page_icon="🔥")
st.title("Tech Malli 😎🔥")
st.caption("A/L IT 2014-2026 | Funny AI Teacher | 100% Free Python Version")

# ===== MOOD DETECT =====
def detect_mood(msg):
    m = msg.lower()
    funny_words = ["machan","mchn","ado","bng","bn","patta","maru","ela","😂","🤣","😎","🔥","lol","haha","vihilu","joke","funny","moko","niyamai","supiri","ammo","hapo"]
    sad_words = ["bayai","baya","sad","duka","fail","behe","epa","amru","😭","😢","😩","help","stress","tired"]
    serious_words = ["paper","exam","question","prashne","explain","kiyala","denna","padam","theory","marking","syllabus"]
    if any(w in m for w in sad_words):
        return "sad"
    if any(w in m for w in funny_words):
        return "funny"
    if any(w in m for w in serious_words):
        return "serious"
    return "normal"

# ===== LOAD PAPERS =====
@st.cache_data
def load_papers():
    try:
        res = requests.get(DATA_URL, timeout=20)
        if res.status_code == 200:
            return res.json()
    except:
        pass
    return []

papers = load_papers()

# ===== SIDEBAR =====
with st.sidebar:
    st.header("⚙️ Settings")
    mode = st.radio("Mode:", ["📚 Paper Mode", "🤖 General AI"])
    year = st.selectbox("Year:", [2014,2015,2016,2017,2018,2020,2021,2022,2023,2024,2025,2026], index=9)
    st.write("---")
    if st.button("📝 Quiz හදන්න"):
        st.session_state['quiz_mode'] = True
    if st.button("🗑️ Chat Clear කරන්න"):
        st.session_state.messages = []
        st.rerun()

# ===== GROQ CALL =====
def call_groq(prompt):
    res = requests.post(
        "https://api.groq.com/openai/v1/chat/completions",
        headers={"Authorization": f"Bearer {GROQ_API_KEY}", "Content-Type": "application/json"},
        json={"model": "llama-3.3-70b-versatile", "messages": [{"role": "user", "content": prompt}], "temperature": 0.8},
        timeout=60
    )
    if res.status_code == 200:
        return res.json()['choices'][0]['message']['content']
    else:
        return f"අඩෝ මචං Error එකක් ආවා 😅 Key එක හරියට දැම්මද බලපන් - {res.status_code}"

def ask_question(question):
    mood = detect_mood(question)
    if mood == "funny":
        mood_ins = "USER IS IN FUNNY MOOD! YOU MUST BE 10X FUNNIER! Use slang 'අඩෝ මචං, පට්ටයි බං, මරු'. Start with joke, end with joke. LOTS of emojis 😂🤣🔥😎. Roast friendly. Talk like best friend in canteen."
    elif mood == "sad":
        mood_ins = "USER IS SAD / SCARED. Be funny BUT caring. First say 'අඩෝ බය වෙන්න එපා බං, මම ඉන්නවානේ 💪'. Motivate."
    elif mood == "serious":
        mood_ins = "USER IS SERIOUS / STUDY MODE. Be 70% Teacher + 30% Funny. Give correct answer first, then ONE funny example. End with 'මේක Exam එකට එනවා, ලියාගනින් 📝'"
    else:
        mood_ins = "USER IS NORMAL. Be friendly + a little funny. Like a cool teacher. 2-3 emojis only."

    if "General" in mode:
        prompt = f"You are Tech Malli - Sri Lanka's funniest AI friend.\nMOOD: {mood}\n{mood_ins}\nNEVER say As an AI. Reply in same language user used. Mirror user's energy. Keep SHORT.\nUser: {question}"
        return call_groq(prompt)

    context = ""
    if papers:
        relevant = [p for p in papers if p['year'] == year]
        for p in relevant:
            context += f"\n--- {p['year']} IT Paper ---\n{p['content'][:8000]}\n"

    prompt = f"""You are Tech Malli - Funniest A/L IT Teacher.
MOOD: {mood}
{mood_ins}
Past Paper Data:
{context}
Student: {question}
RULES: ALWAYS mention year like "2023 IT - Q5". Mirror user's tone. Explain with funny real life examples. End with motivation.
"""
    return call_groq(prompt)

# ===== CHAT =====
if "messages" not in st.session_state:
    st.session_state.messages = [{"role": "assistant", "content": "ආයුබෝවන් මචං! 😎🔥\nමම Tech Malli!\n\n2014-2026 IT Paper ටිකම මම කටපාඩම් කරලා තියෙන්නේ.\n\n📚 Paper Mode - Paper වලින් උත්තර\n🤖 General Mode - ඕනම දෙයක්, විහිළුත් එක්ක\n\nමොකක්ද අහන්නේ බං? 😂"}]

# Quick Buttons
col1, col2, col3, col4 = st.columns(4)
if col1.button("😂 විහිළුවක්"):
    st.session_state.messages.append({"role": "user", "content": "😂 විහිළුවක් කියන්න"})
    st.session_state.messages.append({"role": "assistant", "content": ask_question("😂 විහිළුවක් කියන්න")})
    st.rerun()
if col2.button("💻 Python"):
    st.session_state.messages.append({"role": "user", "content": "💻 Python ඉගන්නන්න"})
    st.session_state.messages.append({"role": "assistant", "content": ask_question("Python ඉගන්නන්න")})
    st.rerun()
if col3.button("📚 2024 අමාරුම"):
    st.session_state.messages.append({"role": "user", "content": "2024 Paper එකේ අමාරුම ප්‍රශ්නේ මොකක්ද?"})
    st.session_state.messages.append({"role": "assistant", "content": ask_question("2024 Paper එකේ අමාරුම ප්‍රශ්නේ මොකක්ද?")})
    st.rerun()
if col4.button("😩 Exam බයයි"):
    st.session_state.messages.append({"role": "user", "content": "😩 Exam එකට බයයි"})
    st.session_state.messages.append({"role": "assistant", "content": ask_question("😩 Exam එකට බයයි")})
    st.rerun()

# Show Messages
for m in st.session_state.messages:
    with st.chat_message(m["role"]):
        st.markdown(m["content"])

# Input
if prompt := st.chat_input("මචං මොකක්ද අහන්නේ... 😎"):
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)
    with st.chat_message("assistant"):
        with st.spinner("Tech Malli හිතනවා... 😎"):
            ans = ask_question(prompt)
            st.markdown(ans)
            st.session_state.messages.append({"role": "assistant", "content": ans})

# ===== QUIZ =====
if st.session_state.get('quiz_mode'):
    st.write("---")
    st.header("📝 Quiz Time! 😎")
    if st.button("❌ Quiz Close කරන්න"):
        st.session_state['quiz_mode'] = False
        st.rerun()
    quiz_prompt = f"Make 5 funny MCQ for A/L IT {year}. Return ONLY JSON array like [{{\"question\":\"...\",\"options\":[\"A\",\"B\",\"C\",\"D\"],\"correct\":0,\"explain\":\"Funny Sinhala explain\"}}]"
    quiz_res = call_groq(quiz_prompt)
    try:
        quiz_res = quiz_res.replace("```json","").replace("```","").strip()
        # JSON එකේ මුලයි අගයි හොයලා ගන්න
        start = quiz_res.find("[")
        end = quiz_res.rfind("]")+1
        quiz = json.loads(quiz_res[start:end])
        for i, q in enumerate(quiz):
            st.subheader(f"Q{i+1}: {q['question']}")
            ans = st.radio("උත්තරේ තෝරපන්:", q['options'], key=f"q{i}")
            if st.button(f"Check කරන්න {i+1}", key=f"btn{i}"):
                if q['options'].index(ans) == q['correct']:
                    st.success("පට්ටයි මචං! හරි! 🔥💪")
                else:
                    st.error(f"අඩෝ වැරදියි බං 😅 හරි උත්තරේ: {q['options'][q['correct']]}")
                st.info(f"Tech Malli කියනවා: {q['explain']} 😂")
    except Exception as e:
        st.error(f"Quiz එක හැදුනේ නෑ 😅 ආයෙත් Try කරන්න - {e}")
