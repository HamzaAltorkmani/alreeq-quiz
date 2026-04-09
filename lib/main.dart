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

    Question("كم شهر في السنة فيه 31 يوم؟", ["5", "6", "7", "8"], 2),
    Question("ما هو المعدن السائل في درجة حرارة الغرفة؟", ["الرصاص", "الزئبق", "الحديد", "النحاس"], 1),
    Question("إذا كان هناك 3 تفاحات وأخذت 2، كم لديك؟", ["1", "2", "3", "0"], 1),
    Question("إذا سقطت طائرة على الحدود بين دولتين، أين يُدفن الناجون؟", ["الدولة الأولى", "الدولة الثانية", "حسب الجنسية", "لا يُدفنون"], 3),
    Question("في أي عام انضمت سلطنة عُمان إلى الأمم المتحدة؟", ["1965", "1970", "1971", "1975"], 2),
    Question("كم عدد السنوات التي نامها أهل الكهف؟", ["100", "291", "300", "309"], 3),
    Question("من هو الصحابي الذي اهتز لموته عرش الرحمن؟", ["أبو بكر", "عمر", "سعد بن معاذ", "علي"], 2),
    Question("كم شهر في السنة فيه 28 يوم؟", ["1", "6", "12", "2"], 2),
    Question("أنت في سباق، وتجاوزت صاحب المركز الثاني… في أي مركز أصبحت؟", ["الأول", "الثاني", "الثالث", "الأخير"], 1),
    Question("إذا كان: 2 = 6، 3 = 12، 4 = 20، 5 = 30، فكم تساوي 6؟", ["36", "40", "42", "48"], 2),
    Question("ما هو العنصر الأكثر وفرة في الكون؟", ["الأكسجين", "الهيدروجين", "الكربون", "الهيليوم"], 1),

    Question("في أي عام تم انتخاب الإمام ناصر بن مرشد اليعربي إماماً على عُمان؟", ["1604م", "1624م", "1650م", "1670م"], 1),
    Question("في أي عام تم طرد البرتغاليين من مسقط؟", ["1624م", "1640م", "1650م", "1660م"], 2),
    Question("ما اسم أبرز المعارك التي خاضها العُمانيون ضد البرتغاليين؟", ["معركة نزوى", "معركة تحرير مسقط", "معركة صحار", "معركة الرستاق"], 1),
    Question("من هو السلطان الذي نقل مركز حكمه إلى زنجبار؟", ["السلطان قابوس بن سعيد", "السلطان تيمور بن فيصل", "السلطان سعيد بن سلطان", "السلطان تركي بن سعيد"], 2),
    Question("ما اسم السفينة العُمانية التي أُرسلت إلى الولايات المتحدة الأمريكية في القرن التاسع عشر؟", ["الظافرة", "صحار", "سلطانة", "فتح الخير"], 2),
    Question("متى تم اكتشاف النفط بكميات تجارية في سلطنة عُمان؟", ["1958م", "1964م", "1970م", "1975م"], 1),
    Question("ما اسم الاتفاقية التي نظمت العلاقة بين مسقط وعُمان في أوائل القرن العشرين؟", ["اتفاقية الجبل الأخضر", "اتفاقية السيب", "اتفاقية مطرح", "اتفاقية صحار"], 1),
    Question("من هو أول حاكم من أسرة البوسعيد بعد نهاية الدولة اليعربية؟", ["الإمام سلطان بن سيف", "الإمام أحمد بن سعيد البوسعيدي", "السيد سعيد بن سلطان", "الإمام عزان بن قيس"], 1),
    Question("ما هو العنصر الذي يُعد أكثر وفرة في الغلاف الجوي للأرض؟", ["الأكسجين", "الهيدروجين", "النيتروجين", "ثاني أكسيد الكربون"], 2),
    Question("أي دولة تُعد الأكبر مساحة في قارة أفريقيا؟", ["السودان", "الجزائر", "ليبيا", "تشاد"], 1),
    Question("من هو العالم الذي وضع أسس علم الجبر؟", ["ابن سينا", "الخوارزمي", "الرازي", "ابن الهيثم"], 1),
    Question("كم عدد عضلات جسم الإنسان تقريبًا؟", ["206", "400", "620", "780"], 2),
    Question("أي بحر يُعرف بأنه البحر الذي لا سواحل له؟", ["البحر الأسود", "البحر الأحمر", "بحر العرب", "بحر سارجاسو"], 3),
  ];
}