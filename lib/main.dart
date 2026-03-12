import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(OmanQuizApp());
}

class OmanQuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مسابقة جامع العريق',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Arial',
      ),
      home: StartPage(),
    );
  }
}

class Question {
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;

  Question(this.questionText, this.options, this.correctAnswerIndex);
}

/// ✅ تخزين الأسئلة التي تم عرضها خلال الجلسة (بدون تكرار)
class QuizSession {
  static final Set<int> usedIndexes = <int>{};

  static void reset() {
    usedIndexes.clear();
  }
}

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  int? _parseNumberOrNull() {
    final t = _controller.text.trim();
    if (t.isEmpty) return null; // عشوائي
    return int.tryParse(t);
  }

  void _start({required bool random}) {
    final total = QuizData.questions.length; // 100
    final remaining = total - QuizSession.usedIndexes.length;

    // إذا خلصت الأسئلة كلها: نعيد الجلسة تلقائيًا
    if (remaining == 0) {
      QuizSession.reset();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تمت إعادة الأسئلة لأنك أنهيت جميع الأسئلة.")),
      );
    }

    int? chosenNumber = _parseNumberOrNull(); // 1..100 أو null

    if (random) {
      chosenNumber = null;
      setState(() => _error = null);
    } else {
      // المستخدم كتب شيء
      if (_controller.text.trim().isNotEmpty && chosenNumber == null) {
        setState(() => _error = "اكتب رقمًا صحيحًا فقط (مثال: 7)");
        return;
      }

      if (chosenNumber != null && (chosenNumber < 1 || chosenNumber > total)) {
        setState(() => _error = "الرقم يجب أن يكون بين 1 و $total");
        return;
      }

      if (chosenNumber != null) {
        final idx = chosenNumber - 1;
        if (QuizSession.usedIndexes.contains(idx)) {
          setState(() => _error = "هذا السؤال تم عرضه من قبل. اختر رقمًا آخر أو اتركه فارغًا للعشوائي.");
          return;
        }
      }

      setState(() => _error = null);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizPage(startNumber: chosenNumber), // null = عشوائي
      ),
    ).then((_) {
      if (!mounted) return;
      setState(() {}); // تحديث عدد المتبقي
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = QuizData.questions.length; // 100
    final remaining = total - QuizSession.usedIndexes.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "مسابقة جامع العريق",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.quiz, size: 90, color: Color(0xFFD32F2F)),
                const SizedBox(height: 12),
                Text(
                  "اكتب رقم السؤال (1 إلى $total)\nأو اتركه فارغًا ليظهر لك سؤال عشوائي",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "الأسئلة المتبقية: $remaining / $total",
                  style: const TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "مثال: 15",
                    filled: true,
                    fillColor: Colors.white,
                    errorText: _error,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD32F2F),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () => _start(random: false),
                          child: const Text(
                            "ابدأ",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () => _start(random: true),
                          child: const Text(
                            "سؤال عشوائي",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "ملاحظة: السؤال الذي يظهر لن يتكرر خلال الجلسة.",
                  style: TextStyle(color:Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 150),
                const Text(
                  "تم عمل الموقع بواسطة شركة الركيني _ قسم البرمجيات",
                  style: TextStyle(
                    color: Color(0xFFD32F2F),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  final int? startNumber; // null = عشوائي
  const QuizPage({super.key, required this.startNumber});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final Random _rng = Random();

  late int _questionIndex; // فهرس السؤال في القائمة (0..99)
  late Question _current;

  Timer? _timer;
  int _timeLeft = 40;

  bool _isAnswered = false;
  bool _showCorrectAnswer = false;
  int? _selectedAnswerIndex;

  String? _answerMessage;
  Color? _answerMessageColor;

  bool? _lastAnswerWasCorrect;

  @override
  void initState() {
    super.initState();
    _pickQuestion();
    _startTimer();
  }

  void _pickQuestion() {
    final total = QuizData.questions.length; // 100

    if (widget.startNumber != null) {
      _questionIndex = (widget.startNumber! - 1).clamp(0, total - 1);
    } else {
      final available = <int>[];
      for (int i = 0; i < total; i++) {
        if (!QuizSession.usedIndexes.contains(i)) available.add(i);
      }
      // لو كلهم مستخدمين (احتياط)
      if (available.isEmpty) {
        QuizSession.reset();
        for (int i = 0; i < total; i++) {
          available.add(i);
        }
      }
      _questionIndex = available[_rng.nextInt(available.length)];
    }

    // ✅ تسجيل السؤال كمستخدم فور عرضه
    QuizSession.usedIndexes.add(_questionIndex);
    _current = QuizData.questions[_questionIndex];
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 40;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer?.cancel();
          _isAnswered = true;
          _showCorrectAnswer = false;
          _selectedAnswerIndex = null;
          _lastAnswerWasCorrect = false;
          _answerMessage = "⏱ انتهى الوقت";
          _answerMessageColor = Colors.orange[800];
        }
      });
    });
  }

  void _checkAnswer(int selectedIndex) {
    if (_isAnswered) return;
    _timer?.cancel();

    final correctIndex = _current.correctAnswerIndex;
    final isCorrect = selectedIndex == correctIndex;

    setState(() {
      _isAnswered = true;
      _selectedAnswerIndex = selectedIndex;
      _lastAnswerWasCorrect = isCorrect;

      if (isCorrect) {
        _answerMessage = "✅ صحيح";
        _answerMessageColor = Colors.green[800];
        _showCorrectAnswer = true; // صح: يظهر الصحيح مباشرة
      } else {
        _answerMessage = "❌ خطأ";
        _answerMessageColor = Colors.red[800];
        _showCorrectAnswer = false; // خطأ: لا يظهر الصحيح مباشرة
      }
    });
  }

  void _revealCorrectAnswer() {
    setState(() => _showCorrectAnswer = true);
  }

  void _goBackToChooseAnother() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _current;
    final correctIndex = q.correctAnswerIndex;
    final shownNumber = _questionIndex + 1; // ✅ رقم السؤال الحقيقي

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "مسابقة عُمان",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "رقم السؤال: $shownNumber / 100",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: _timeLeft / 40,
                            color: _timeLeft > 10 ? Colors.green : Colors.red,
                            backgroundColor: Colors.grey[200],
                          ),
                          Text("$_timeLeft", style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      child: Text(
                        q.questionText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[900],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  if (_answerMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                      decoration: BoxDecoration(
                        color: (_answerMessageColor ?? Colors.black).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: (_answerMessageColor ?? Colors.black).withOpacity(0.35)),
                      ),
                      child: Text(
                        _answerMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _answerMessageColor ?? Colors.black,
                        ),
                      ),
                    ),

                  const SizedBox(height: 14),

                  ...List.generate(4, (index) {
                    Color? btnColor = Colors.white;

                    if (_showCorrectAnswer) {
                      if (index == correctIndex) {
                        btnColor = Colors.green[100];
                      } else if (_selectedAnswerIndex != null && index == _selectedAnswerIndex) {
                        btnColor = Colors.red[100];
                      }
                    } else {
                      if (_isAnswered &&
                          _lastAnswerWasCorrect == false &&
                          _selectedAnswerIndex != null &&
                          index == _selectedAnswerIndex) {
                        btnColor = Colors.red[100];
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: btnColor,
                            foregroundColor: Colors.black,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          onPressed: _isAnswered ? null : () => _checkAnswer(index),
                          child: Text(
                            q.options[index],
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  if (_isAnswered)
                    Column(
                      children: [
                        // عند الخطأ: زر إظهار الإجابة (اختياري)
                        if (_lastAnswerWasCorrect == false && !_showCorrectAnswer)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.lightbulb),
                              label: const Text("إظهار الإجابة"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.all(15),
                              ),
                              onPressed: _revealCorrectAnswer,
                            ),
                          ),

                        if (_lastAnswerWasCorrect == false && !_showCorrectAnswer) const SizedBox(height: 10),

                        // ✅ بدل "التالي" -> زر العودة للاختيار
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_back),
                            label: const Text("العودة لاختيار سؤال آخر"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.all(15),
                            ),
                            onPressed: _goBackToChooseAnother,
                          ),
                        ),

                        if (_showCorrectAnswer)
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "الإجابة الصحيحة: ${q.options[correctIndex]}",
                                style: TextStyle(
                                  color: Colors.green[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QuizData {
  static final List<Question> questions = [

    Question("كم عدد أضلاع الشكل السداسي؟", ["5", "6", "7", "8"], 1),
    Question("إذا كان اليوم هو الأحد، فماذا سيكون اليوم بعد 10 أيام؟", ["الثلاثاء", "الأربعاء", "الخميس", "الجمعة"], 1),
    Question("أي عدد من الأعداد التالية هو عدد أولي؟", ["9", "15", "17", "21"], 2),
    Question("ما هو العدد التالي في السلسلة: 2 – 4 – 8 – 16 – ؟", ["24", "30", "32", "34"], 2),
    Question("شيء كلما أخذت منه كبر، فما هو؟", ["البحر", "الحفرة", "الطريق", "الجبل"], 1),
    Question("ما هو العدد الذي إذا ضربته في نفسه ثم أضفت إليه نفس العدد يصبح الناتج 12؟", ["2", "3", "4", "5"], 1),
    Question("ما هو الشيء الذي يمشي بلا قدمين ويبكي بلا عينين؟", ["السحاب", "النهر", "الريح", "المطر"], 1),
    Question("إذا كان 5 عمال ينجزون عملاً خلال 5 أيام، فكم يوماً يحتاج 10 عمال لإنجاز نفس العمل؟", ["يومان", "3 أيام", "4 أيام", "5 أيام"], 0),
    Question("كم عدد الزوايا في المثلث؟", ["2", "3", "4", "6"], 1),
    Question("ما العدد المفقود في السلسلة: 3 – 6 – 9 – 12 – ؟", ["14", "15", "16", "18"], 1),

    Question("ما هي أكبر قارة في العالم؟", ["أفريقيا", "آسيا", "أوروبا", "أستراليا"], 1),
    Question("كم عدد كواكب المجموعة الشمسية؟", ["7", "8", "9", "10"], 1),
    Question("ما هي عاصمة سلطنة عُمان؟", ["صلالة", "مسقط", "صحار", "نزوى"], 1),
    Question("من هو مخترع المصباح الكهربائي؟", ["إسحاق نيوتن", "توماس إديسون", "أينشتاين", "جراهام بيل"], 1),
    Question("ما هو أطول نهر في العالم؟", ["نهر الأمازون", "نهر النيل", "نهر المسيسيبي", "نهر اليانغتسي"], 1),
    Question("كم عدد سور القرآن الكريم؟", ["110", "112", "114", "116"], 2),
    Question("أي حيوان يُعرف بسفينة الصحراء؟", ["الحصان", "الجمل", "الفيل", "الغزال"], 1),
    Question("ما هو أسرع حيوان بري؟", ["الأسد", "الفهد", "النمر", "الذئب"], 1),
    Question("كم عدد أيام السنة في السنة الكبيسة؟", ["365", "366", "364", "360"], 1),
    Question("في أي قارة تقع مصر؟", ["آسيا", "أوروبا", "أفريقيا", "أمريكا الجنوبية"], 2),

    Question("ما هو أكبر محيط في العالم؟", ["المحيط الأطلسي", "المحيط الهندي", "المحيط الهادئ", "المحيط المتجمد الشمالي"], 2),
    Question("كم عدد قارات العالم؟", ["5", "6", "7", "8"], 2),
    Question("أي حيوان يُلقب بملك الغابة؟", ["النمر", "الأسد", "الفهد", "الدب"], 1),
    Question("ما هي اللغة الأكثر انتشارًا في العالم؟", ["الإنجليزية", "العربية", "الإسبانية", "الصينية"], 3),
    Question("من هو أول إنسان صعد إلى القمر؟", ["يوري جاجارين", "نيل أرمسترونغ", "جون غلين", "آلان شيبرد"], 1),
    Question("ما هو الكوكب المعروف بالكوكب الأحمر؟", ["المريخ", "عطارد", "الزهرة", "زحل"], 0),
    Question("كم عدد ألوان قوس قزح؟", ["5", "6", "7", "8"], 2),
    Question("ما هو أسرع طائر في العالم؟", ["النسر", "الصقر", "الحمام", "البومة"], 1),
    Question("ما هي الدولة الأكبر مساحة في العالم؟", ["الصين", "الولايات المتحدة", "كندا", "روسيا"], 3),
    Question("كم عدد الأسنان لدى الإنسان البالغ؟", ["28", "30", "32", "36"], 2),

    Question("ما هو الحيوان الذي ينام وإحدى عينيه مفتوحة؟", ["الدلفين", "التمساح", "الأرنب", "القط"], 0),
    Question("ما هو أكبر حيوان في العالم؟", ["الفيل", "الحوت الأزرق", "الزرافة", "القرش"], 1),
    Question("كم عدد أضلاع جسم الإنسان؟", ["22", "24", "26", "28"], 1),
    Question("ما هو الكوكب الأقرب إلى الشمس؟", ["عطارد", "الزهرة", "الأرض", "المريخ"], 0),
    Question("أي دولة تُعرف بأرض الكنانة؟", ["الأردن", "مصر", "العراق", "المغرب"], 1),
    Question("ما هو أطول حيوان في العالم؟", ["الفيل", "الزرافة", "الحصان", "الجمل"], 1),
    Question("ما هي أكبر دولة عربية من حيث المساحة؟", ["السعودية", "الجزائر", "السودان", "مصر"], 1),
    Question("كم عدد أيام الأسبوع؟", ["5", "6", "7", "8"], 2),
    Question("ما هي العملة الرسمية في اليابان؟", ["اليوان", "الوون", "الين", "الروبية"], 2),
    Question("ما هو الغاز الذي يتنفسه الإنسان؟", ["الهيدروجين", "الأكسجين", "النيتروجين", "ثاني أكسيد الكربون"], 1),

    Question("ما هو الكوكب الأكبر في المجموعة الشمسية؟", ["زحل", "المشتري", "الأرض", "أورانوس"], 1),
    Question("كم عدد لاعبي فريق كرة القدم داخل الملعب؟", ["9", "10", "11", "12"], 2),
    Question("ما هي عاصمة فرنسا؟", ["روما", "مدريد", "باريس", "برلين"], 2),
    Question("ما هو الحيوان الذي يطلق عليه لقب سفاح البحر؟", ["القرش", "الحوت", "الدلفين", "الأخطبوط"], 0),
    Question("كم عدد أرجل العنكبوت؟", ["6", "8", "10", "12"], 1),
    Question("ما هو المعدن الذي يرمز له بالرمز (Fe)؟", ["الذهب", "الحديد", "الفضة", "النحاس"], 1),
    Question("ما هي أكبر دولة في أفريقيا من حيث المساحة؟", ["السودان", "مصر", "الجزائر", "ليبيا"], 2),
    Question("كم عدد أصابع يد الإنسان؟", ["4", "5", "6", "7"], 1),
    Question("ما هي عاصمة اليابان؟", ["سيول", "طوكيو", "بكين", "بانكوك"], 1),
    Question("ما هو العضو الذي يضخ الدم في جسم الإنسان؟", ["الكبد", "القلب", "الرئة", "المعدة"], 1),

    Question("ما هو الكوكب الذي يُعرف بكوكب الحلقات؟", ["المشتري", "زحل", "أورانوس", "نبتون"], 1),
    Question("كم عدد عضلات جسم الإنسان تقريبًا؟", ["206", "450", "600", "800"], 2),
    Question("ما هو البحر الذي لا يحتوي على أسماك؟", ["البحر الأحمر", "البحر الأسود", "البحر الميت", "بحر العرب"], 2),
    Question("أي طائر يستطيع الطيران إلى الخلف؟", ["النسر", "الطنان", "الصقر", "اللقلق"], 1),
    Question("كم عدد قلوب الأخطبوط؟", ["قلب واحد", "قلبان", "ثلاثة قلوب", "أربعة قلوب"], 2),
    Question("ما هي أكبر صحراء في العالم؟", ["الصحراء العربية", "الصحراء الكبرى", "صحراء جوبي", "صحراء كالاهاري"], 1),
    Question("ما هي الدولة التي تقع فيها أهرامات الجيزة؟", ["السودان", "الأردن", "مصر", "المغرب"], 2),
    Question("كم عدد العظام في جسم الإنسان البالغ؟", ["198", "206", "212", "220"], 1),
    Question("ما هو أسرع حيوان في البحر؟", ["القرش", "التونة", "سمكة أبو سيف", "الدلفين"], 2),
    Question("ما هو العنصر الذي يُستخدم في صناعة أقلام الرصاص؟", ["الفحم", "الجرافيت", "الرصاص", "الكربون"], 1),

    Question("كم عدد أجنحة النحلة؟", ["2", "4", "6", "8"], 1),
    Question("ما هو أطول جبل في العالم فوق سطح البحر؟", ["كليمنجارو", "إيفرست", "الألب", "الهيمالايا"], 1),
    Question("ما هو الحيوان الذي يُعرف بأنه أبطأ حيوان في العالم؟", ["السلحفاة", "الكسلان", "الحلزون", "الدب"], 1),
    Question("ما هي عاصمة إيطاليا؟", ["ميلانو", "روما", "نابولي", "فلورنسا"], 1),
    Question("كم عدد الكواكب الغازية في المجموعة الشمسية؟", ["2", "3", "4", "5"], 2),
    Question("ما هو أطول نهر في آسيا؟", ["نهر الغانج", "نهر الميكونغ", "نهر اليانغتسي", "نهر السند"], 2),
    Question("أي معدن يُعد الأغلى في العالم؟", ["الذهب", "الفضة", "البلاتين", "الروديوم"], 3),
    Question("ما هي عاصمة تركيا؟", ["إسطنبول", "أنقرة", "أنطاليا", "إزمير"], 1),
    Question("كم عدد بطولات كأس العالم التي فاز بها منتخب البرازيل؟", ["3", "4", "5", "6"], 2),
    Question("ما هو أكبر عضو في جسم الإنسان؟", ["القلب", "الجلد", "الكبد", "الرئة"], 1),
    Question("ما هي العملة الرسمية في بريطانيا؟", ["اليورو", "الدولار", "الجنيه الإسترليني", "الفرنك"], 2),
    Question("كم عدد الكروموسومات في جسم الإنسان؟", ["44", "46", "48", "50"], 1),

    Question("ما هو الكوكب الذي يُسمى توأم الأرض؟", ["المريخ", "الزهرة", "عطارد", "نبتون"], 1),
    Question("كم عدد أرجل النملة؟", ["4", "6", "8", "10"], 1),
    Question("ما هو أطول حيوان بحري؟", ["الحوت الأزرق", "الحبار العملاق", "القرش", "الدلفين"], 0),
    Question("ما هي عاصمة كندا؟", ["تورونتو", "مونتريال", "أوتاوا", "فانكوفر"], 2),
    Question("كم عدد الكلى في جسم الإنسان؟", ["واحدة", "اثنتان", "ثلاث", "أربع"], 1),
    Question("ما هو الغاز الذي يجعل المشروبات الغازية فوّارة؟", ["الأكسجين", "الهيدروجين", "ثاني أكسيد الكربون", "النيتروجين"], 2),
    Question("ما هو الحيوان الذي يُعرف بأنه أذكى الحيوانات؟", ["الدلفين", "القرد", "الفيل", "الكلب"], 0),
    Question("كم عدد الأسنان اللبنية لدى الأطفال؟", ["18", "20", "24", "28"], 1),
    Question("ما هو أطول سور في العالم؟", ["سور الصين العظيم", "سور برلين", "سور القدس", "سور روما"], 0),
    Question("ما هي الدولة التي تشتهر ببرج بيزا المائل؟", ["فرنسا", "إيطاليا", "إسبانيا", "اليونان"], 1),

    Question("ما هي عاصمة أستراليا؟", ["سيدني", "ملبورن", "كانبيرا", "بيرث"], 2),
    Question("كم عدد حجرات قلب الإنسان؟", ["2", "3", "4", "5"], 2),
    Question("ما هو الحيوان الذي يستطيع تغيير لون جلده؟", ["الحرباء", "الأرنب", "النمر", "الذئب"], 0),
    Question("ما هي أكبر جزيرة في العالم؟", ["مدغشقر", "جرينلاند", "أيسلندا", "اليابان"], 1),
    Question("ما هو الكوكب الأكثر حرارة في المجموعة الشمسية؟", ["عطارد", "الزهرة", "المريخ", "المشتري"], 1),
    Question("كم عدد لاعبي فريق كرة السلة داخل الملعب؟", ["4", "5", "6", "7"], 1),
    Question("ما هو الحيوان الذي يلقب بسفينة الصحراء؟", ["الجمل", "الحصان", "الغزال", "النعامة"], 0),
    Question("ما هي عاصمة ألمانيا؟", ["هامبورغ", "ميونخ", "برلين", "فرانكفورت"], 2),
    Question("كم عدد أجنحة الذبابة؟", ["1", "2", "3", "4"], 1),
    Question("ما هو أكبر كوكب بعد المشتري؟", ["زحل", "نبتون", "أورانوس", "الأرض"], 0),

    Question("ما هو أكبر كوكب صخري في المجموعة الشمسية؟", ["الأرض", "المريخ", "الزهرة", "عطارد"], 0),
    Question("أي دولة تُعرف ببلاد الشمس المشرقة؟", ["الصين", "اليابان", "كوريا", "تايلاند"], 1),
    Question("ما هو الحيوان الذي يمكنه العيش بدون ماء لفترة طويلة؟", ["الجمل", "الحصان", "الفيل", "الغزال"], 0),
    Question("ما هو العنصر الذي يرمز له بالرمز (O)؟", ["الذهب", "الأكسجين", "الفضة", "الهيدروجين"], 1),
    Question("ما هي عاصمة إسبانيا؟", ["برشلونة", "مدريد", "فالنسيا", "إشبيلية"], 1),
    Question("كم عدد عيون النحلة؟", ["2", "3", "4", "5"], 3),
    Question("ما هو الطائر الذي لا يستطيع الطيران؟", ["البطريق", "النسر", "الصقر", "الحمام"], 0),
    Question("ما هي أكبر بحيرة في العالم من حيث المساحة؟", ["بحيرة فيكتوريا", "بحر قزوين", "بحيرة سوبيريور", "بحيرة بايكال"], 1),
    Question("كم عدد الكواكب التي تدور حول الشمس؟", ["7", "8", "9", "10"], 1),
    Question("ما هو الجهاز المسؤول عن التنفس في جسم الإنسان؟", ["الجهاز الهضمي", "الجهاز التنفسي", "الجهاز العصبي", "الجهاز الدوري"], 1),

  ];
}