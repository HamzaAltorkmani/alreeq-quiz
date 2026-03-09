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
  // ✅ 100 سؤال بالضبط
  static final List<Question> questions = [
    // ===== 75 سؤال عن عُمان (وطني/اجتماعي/ثقافي) =====
    Question("من هو مؤسس الدولة البوسعيدية؟", ["الإمام أحمد بن سعيد", "السلطان قابوس", "السلطان سعيد بن تيمور", "الإمام عزان بن قيس"], 0),
    Question("في أي عام انضمت سلطنة عمان إلى الأمم المتحدة؟", ["1970", "1971", "1975", "1980"], 1),
    Question("ما هي العاصمة الإدارية لسلطنة عمان؟", ["مسقط", "نزوى", "صلالة", "صحار"], 0),

    // 4 (معدل)
    Question("في أي عام تأسست الدولة البوسعيدية في عمان؟", ["1744", "1700", "1750", "1800"], 0),

    // 5 (معدل)
    Question("ما اسم أول صحيفة رسمية صدرت في سلطنة عمان؟", ["جريدة عمان", "الرؤية", "الشبيبة", "الوطن"], 0),

    Question("متى تولى السلطان هيثم بن طارق مقاليد الحكم؟", ["10 يناير 2020", "11 يناير 2020", "12 يناير 2020", "15 يناير 2020"], 1),
    Question("ما هو أعلى جبل في سلطنة عمان؟", ["جبل شمس", "الجبل الأخضر", "جبل سمحان", "جبل مدر"], 0),
    Question("أي مضيق استراتيجي ترتبط به عمان؟", ["مضيق هرمز", "مضيق جبل طارق", "مضيق البوسفور", "مضيق ملقا"], 0),
    Question("كم عدد محافظات سلطنة عمان؟", ["9", "10", "11", "12"], 2),

    // 10 (معدل)
    Question("كم عدد الولايات في سلطنة عمان تقريبًا؟", ["61", "52", "70", "45"], 0),

    // 11 (معدل)
    Question("كم عدد ولايات محافظة مسقط؟", ["6", "8", "10", "4"], 0),

    // 12 (معدل)
    Question("ما أقدم عاصمة تاريخية لعمان قبل مسقط؟", ["نزوى", "صحار", "بهلاء", "الرستاق"], 1),

    // 13 (معدل)
    Question("في أي قرن ازدهرت مدينة صحار كميناء عالمي؟", ["القرن التاسع الميلادي", "القرن الثالث عشر", "القرن السادس عشر", "القرن السابع عشر"], 0),

    // 14 (معدل)
    Question("أي ولاية كانت مركز الإمامة الإباضية تاريخيًا؟", ["نزوى", "صور", "عبري", "الرستاق"], 0),

    // 15 (معدل)
    Question("ما الاسم التاريخي القديم لعمان في النصوص السومرية؟", ["مجان", "سبأ", "عاد", "حضرموت"], 0),

    Question("أي مدينة عمانية ارتبطت تاريخيًا بصناعة السفن؟", ["صور", "عبري", "نزوى", "بهلاء"], 0),

    // 17 (معدل)
    Question("ما المعدن الذي اشتهرت عمان بتصديره في حضارة مجان؟", ["النحاس", "الذهب", "الفضة", "الحديد"], 0),

    // 18 (معدل)
    Question("ما المادة العطرية التي اشتهرت بها ظفار تاريخيًا؟", ["اللبان", "الفانيلا", "الزعفران", "القرفة"], 0),

    Question("ما اسم دار الأوبرا الشهيرة في مسقط؟", ["دار الأوبرا السلطانية", "دار الأوبرا الوطنية", "أوبرا الخليج", "دار الموسيقى"], 0),

    // 20 (معدل)
    Question("ما الموقع المرتبط بتجارة اللبان ضمن التراث العالمي؟", ["أرض اللبان", "وادي رم", "مدائن صالح", "الأهرامات"], 0),

    // 21 (معدل)
    Question("ما اسم الطريق التجاري التاريخي الذي كان ينقل اللبان من ظفار إلى الشام ومصر؟", ["طريق اللبان", "طريق الحرير", "طريق الذهب", "طريق البخور الهندي"], 0),

    // 22 (معدل)
    Question("ما الدولة التي حكمها سلاطين عمان في شرق أفريقيا لفترة طويلة؟", ["زنجبار", "مدغشقر", "الصومال", "موريشيوس"], 0),

    // 23 (معدل)
    Question("في أي عام نقل السلطان سعيد بن سلطان عاصمة الدولة إلى زنجبار؟", ["1832", "1800", "1750", "1880"], 0),

    // 24 (معدل)
    Question("كم عدد مواقع التراث العالمي التابعة لليونسكو في سلطنة عمان؟", ["5", "3", "7", "9"], 0),

    // 25 (معدل)
    Question("أي موقع عماني من مواقع التراث العالمي يمثل حضارة ما قبل التاريخ؟", ["بات والخطم والعين", "نزوى", "صور", "الرستاق"], 0),

    // 26 (معدل)
    Question("أي نظام ري عماني قديم أدرج ضمن التراث العالمي؟", ["الأفلاج", "السدود", "القنوات", "الآبار"], 0),

    // 27 (معدل)
    Question("أي مدينة عمانية قديمة أدرجت في قائمة التراث العالمي عام 2018؟", ["قلهات", "نزوى", "صحار", "الرستاق"], 0),

    // 28 (معدل)
    Question("أي بحر يربط عمان مباشرة بالمحيط الهندي؟", ["بحر العرب", "البحر الأحمر", "بحر قزوين", "البحر المتوسط"], 0),

    // 29 (معدل)
    Question("أي مدينة عمانية كانت مركزًا رئيسيًا لصهر النحاس في حضارة مجان؟", ["صحار", "نزوى", "صور", "الرستاق"], 0),

    // 30 (معدل)
    Question("أي محافظة عمانية تعد الأكبر مساحة في السلطنة؟", ["الوسطى", "ظفار", "الداخلية", "مسقط"], 0),

    // ===== بقية الأسئلة كما هي =====
    Question("أي فن شعبي عُماني مشهور؟", ["الرزحة", "التانغو", "الفلامنكو", "الباليه"], 0),
    Question("ما القلعة المشهورة في ولاية نزوى؟", ["قلعة نزوى", "قلعة صلاح الدين", "قلعة قايتباي", "قلعة القاهرة"], 0),
    Question("ما القلعتان التاريخيتان المعروفـتان في مسقط؟", ["الجلالي والميراني", "الكرك وعجلون", "حلب ودمشق", "صنعاء وتعز"], 0),
    Question("ما اسم المتحف المعروف في مسقط لعرض تاريخ عمان؟", ["المتحف الوطني", "اللوفر", "المتحف البريطاني", "البرادو"], 0),

    Question("أي فن شعبي عُماني مشهور؟", ["الرزحة", "التانغو", "الفلامنكو", "الباليه"], 0),
    Question("ما القلعة المشهورة في ولاية نزوى؟", ["قلعة نزوى", "قلعة صلاح الدين", "قلعة قايتباي", "قلعة القاهرة"], 0),
    Question("ما القلعتان التاريخيتان المعروفـتان في مسقط؟", ["الجلالي والميراني", "الكرك وعجلون", "حلب ودمشق", "صنعاء وتعز"], 0),
    Question("ما اسم المتحف المعروف في مسقط لعرض تاريخ عمان؟", ["المتحف الوطني", "اللوفر", "المتحف البريطاني", "البرادو"], 0),
    Question("أي ميناء عماني معروف على بحر العرب؟", ["ميناء صلالة", "ميناء جدة", "ميناء العقبة", "ميناء بيروت"], 0),

    Question("أي ميناء عماني معروف في شمال عمان؟", ["ميناء صحار", "ميناء الدمام", "ميناء بورسعيد", "ميناء حيفا"], 0),
    Question("أي مجموعة جزر عُمانية معروفة بالطبيعة والغوص؟", ["جزر الديمانيات", "جزيرة ياس", "جزيرة السعديات", "جزيرة صير بني ياس"], 0),
    Question("أي محافظة تشتهر بالخلجان (الفيوردات)؟", ["مسندم", "الداخلية", "الوسطى", "البريمي"], 0),
    Question("ما الاسم السياحي الشائع لرمال الشرقية؟", ["رمال وهيبة", "صحراء غوبي", "صحراء النقب", "أتاكاما"], 0),
    Question("أي كهف يُعد من الكهوف المعروفة في عمان؟", ["كهف الهوتة", "كهف جعيتا", "كهف الثلج", "كهف المعلقة"], 0),

    Question("أي كهف كبير مشهور في عمان؟", ["كهف مجلس الجن", "كهف جعيتا", "كهف المغاير", "كهف الثلج"], 0),
    Question("أي جبل سياحي بارز في عمان غير جبل شمس؟", ["الجبل الأخضر", "جبل طارق", "جبل أحد", "جبل اللوز"], 0),
    Question("أي بحر يحد عمان من الجنوب الشرقي؟", ["بحر العرب", "البحر الأحمر", "بحر قزوين", "بحر البلطيق"], 0),
    Question("ما ألوان علم سلطنة عمان؟", ["أحمر/أبيض/أخضر", "أزرق/أبيض/أحمر", "أسود/أصفر/أبيض", "أخضر/أصفر/أزرق"], 0),
    Question("أين يظهر شعار الدولة على العلم عادة؟", ["بالقرب من السارية", "بالمنتصف", "بالطرف الآخر", "أسفل العلم"], 0),

    Question("أي رمز يظهر في شعار سلطنة عمان؟", ["الخنجر", "التاج", "الهلال وحده", "نخلة واحدة"], 0),
    Question("أي مدينة تُعرف تاريخيًا كمركز علمي بارز في عمان؟", ["نزوى", "الدقم", "خصب", "مصيرة"], 0),
    Question("ما الموقع المرتبط بتجارة اللبان ضمن التراث العالمي؟", ["أرض اللبان", "وادي رم", "مدائن صالح", "الأهرامات"], 0),
    Question("ما موقع (بات والخطم والعين) في تصنيفه العام؟", ["مواقع تراث عالمي في عمان", "مدينة حديثة", "مطار دولي", "ميناء بحري"], 0),
    Question("ما اسم المطار الدولي الرئيسي في مسقط؟", ["مطار مسقط الدولي", "مطار نزوى الدولي", "مطار عبري الدولي", "مطار بهلاء الدولي"], 0),

    Question("ما اسم مطار محافظة ظفار؟", ["مطار صلالة", "مطار صحار", "مطار خصب", "مطار صور"], 0),
    Question("أي ولاية تشتهر بحصن الرستاق؟", ["الرستاق", "صور", "عبري", "مطرح"], 0),
    Question("أي حصن مشهور يُنسب لمنطقة جبرين؟", ["حصن جبرين", "حصن مطرح", "حصن خصب", "حصن الدقم"], 0),
    Question("أي ولاية تشتهر بقلعة بهلاء؟", ["بهلاء", "السيب", "خصب", "صور"], 0),
    Question("أي محافظة تقع فيها مدينة الدقم؟", ["الوسطى", "مسندم", "ظفار", "البريمي"], 0),

    Question("ما المدينة العُمانية التي تُذكر تاريخيًا كمركز تجاري بحري قديم؟", ["صحار", "حائل", "جرش", "الكوفة"], 0),
    Question("أي وادٍ معروف في الشرقية ويضم سدًا ومناظر؟", ["وادي ضيقة", "وادي الذهب", "وادي النار", "وادي الملوك"], 0),
    Question("ما الموقع الطبيعي الشهير في ظفار وقت الخريف؟", ["وادي دربات", "وادي رم", "وادي حنيفة", "وادي الدواسر"], 0),
    Question("أي مدينة عمانية تُعد من أشهر المدن الساحلية؟", ["صور", "بهلاء", "نزوى", "عبري"], 0),
    Question("أي فن عماني يُؤدى في المناسبات الرسمية والشعبية؟", ["العازي", "الروك", "الجاز", "الراب"], 0),

    Question("أي عنصر يُعد من أساسيات الضيافة التقليدية في عمان؟", ["التمر", "المثلجات", "المشروبات الغازية فقط", "الكعك فقط"], 0),
    Question("ما اسم المحافظة التي تضم ولاية بركاء؟", ["جنوب الباطنة", "شمال الشرقية", "الوسطى", "مسندم"], 0),
    Question("أي محافظة تضم ولاية شناص؟", ["شمال الباطنة", "الداخلية", "ظفار", "البريمي"], 0),
    Question("ما اسم المحافظة التي تضم ولاية إبراء؟", ["شمال الشرقية", "مسقط", "مسندم", "ظفار"], 0),
    Question("ما اسم المحافظة التي تضم ولاية أدم؟", ["الداخلية", "الوسطى", "مسندم", "البريمي"], 0),

    Question("أي من التالي مدينة عمانية؟", ["الرستاق", "المنامة", "جدة", "الزرقاء"], 0),
    Question("أي من التالي ولاية عمانية؟", ["السويق", "العين", "الرياض", "الكويت"], 0),
    Question("أي من التالي معلم عماني؟", ["حصن جبرين", "قلعة الكرك", "قلعة حلب", "قلعة صلاح الدين"], 0),
    Question("أي من التالي معلم في مسقط؟", ["دار الأوبرا السلطانية", "برج إيفل", "ساعة بيغ بن", "تمثال الحرية"], 0),
    Question("أي من التالي محافظة عمانية؟", ["البريمي", "جدة", "العين", "الفجيرة"], 0),

    // ===== 25 سؤال ديني شامل =====
    Question("من هو النبي الملقب بأبي الأنبياء؟", ["موسى", "عيسى", "إبراهيم", "نوح"], 2),
    Question("ما أطول سورة في القرآن الكريم؟", ["آل عمران", "البقرة", "النساء", "المائدة"], 1),
    Question("كم عدد أجزاء القرآن الكريم؟", ["20", "30", "40", "60"], 1),
    Question("ما الصلاة التي لا ركوع فيها ولا سجود؟", ["العيد", "الجنازة", "الاستسقاء", "الكسوف"], 1),
    Question("في أي شهر نزل القرآن الكريم؟", ["رجب", "شعبان", "رمضان", "ذو الحجة"], 2),

    Question("من هو أول مؤذن في الإسلام؟", ["عمار", "بلال", "زيد", "أنس"], 1),
    Question("ما القبلة الأولى للمسلمين؟", ["الكعبة", "المسجد النبوي", "المسجد الأقصى", "مسجد قباء"], 2),
    Question("من هو الصحابي ذو النورين؟", ["عمر", "علي", "عثمان", "أبو بكر"], 2),
    Question("ما الركن الثالث من أركان الإسلام؟", ["الصلاة", "الزكاة", "الصوم", "الحج"], 1),
    Question("من النبي الذي ابتلعه الحوت؟", ["يونس", "أيوب", "داوود", "سليمان"], 0),

    Question("كم عدد أركان الإسلام؟", ["3", "4", "5", "6"], 2),
    Question("كم عدد أركان الإيمان؟", ["4", "5", "6", "7"], 2),
    Question("من هو خاتم الأنبياء؟", ["إبراهيم", "عيسى", "محمد ﷺ", "موسى"], 2),
    Question("ما اسم الليلة التي أنزل فيها القرآن؟", ["النصف من شعبان", "الإسراء", "القدر", "عرفة"], 2),
    Question("كم ركعة لصلاة الفجر؟", ["2", "3", "4", "5"], 0),

    Question("كم ركعة لصلاة المغرب؟", ["2", "3", "4", "5"], 1),
    Question("من النبي الذي بنى السفينة؟", ["نوح", "موسى", "يوسف", "صالح"], 0),
    Question("من الصحابي الملقب بالفاروق؟", ["أبو بكر", "عمر", "عثمان", "علي"], 1),
    Question("أول ما يُحاسب عليه العبد يوم القيامة؟", ["الزكاة", "الصيام", "الصلاة", "الحج"], 2),
    Question("من أول زوجات النبي ﷺ؟", ["عائشة", "خديجة", "حفصة", "سودة"], 1),

    Question("أي سورة تُسمى عروس القرآن؟", ["يس", "الرحمن", "الواقعة", "الملك"], 1),
    Question("أي سورة تبدأ بـ (تبارك الذي بيده الملك)؟", ["الملك", "القلم", "الحاقة", "النبأ"], 0),
    Question("كم عدد الصلوات المفروضة يوميًا؟", ["3", "4", "5", "6"], 2),
    Question("ما اسم أم النبي إسماعيل؟", ["هاجر", "سارة", "آسية", "مريم"], 0),
    Question("كم عدد سجدات التلاوة (المشهور في كثير من المناهج)؟", ["10", "12", "14", "16"], 2),
  ];
}