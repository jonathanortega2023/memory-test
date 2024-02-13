import 'package:flutter/material.dart';
import 'src/widgets.dart';
import 'src/data/loaders/load_questions.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

const Duration _questionDuration = Duration(seconds: 5);
const Duration _delayBetweenQuestions = Duration(seconds: 15);
const _testInstructions =
    'You will be shown a series of letters for 5 seconds, then asked to enter them on the next page.\nYou will have 15 seconds to enter your answer. There are 6 questions in total.\nYour results will be shown at the end.';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math 090  Memory Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Math 090 Memory Test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  List<String> questionStrings = [];
  PageController _pageController = PageController();
  int _pageIndex = 0;
  List<String> _questionAnswers = List.filled(6, '');

  @override
  void initState() {
    super.initState();
    loadQuestions().then((value) {
      setState(() {
        questionStrings = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          startPage(),
          for (var page in questionPages()) page,
          resultsPage(),
        ],
      ),
    ));
  }

  Widget startPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          _testInstructions,
          style: TextStyle(fontSize: 20),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white, 
            ),
            onPressed: () {
              startTest();
            },
            child: const Text('Start Test'),
          ),
        ),
      ],
    );
  }

  Widget questionPage(int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: Text(
            questionStrings[index],
            style: const TextStyle(fontSize: 48),
          ),
        ),
        const Spacer(),
        Flexible(
          child: CircularCountDownTimer(
            duration: _questionDuration.inSeconds,
            width: 30,
            height: 30,
            fillColor: Colors.white,
            ringColor: Colors.blue,
            isReverse: true,
          ),
        ),
      ],
    );
  }

  Widget answerPage(int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: SingleCharacterTextEntry(
            entryType: EntryType.upperLetter,
            numEntries: (index + 1) * 2,
            onChanged: (String value) {
              setState(() {
                _questionAnswers[index] = value;
              });
            },
          ),
        ),
        const Spacer(),
        Flexible(
          child: CircularCountDownTimer(
            duration: _delayBetweenQuestions.inSeconds,
            width: 30,
            height: 30,
            fillColor: Colors.white,
            ringColor: Colors.blue,
            isReverse: true,
          ),
        ),
      ],
    );
  }

  List<Widget> questionPages() {
    List<Widget> pages = [];
    for (int i = 0; i < questionStrings.length; i++) {
      pages.add(questionPage(i));
      pages.add(answerPage(i));
    }
    return pages;
  }

  void incrementIndex() {
    setState(() {
      _pageIndex += 1;
    });
  }

  Future<void> startTest() async {
    incrementIndex();
    for (int i = 0; i < 6; i++) {
      _pageController.animateToPage(_pageIndex,
          duration: const Duration(milliseconds: 500), curve: Curves.ease);

      await Future.delayed(_questionDuration);

      incrementIndex();

      _pageController.animateToPage(_pageIndex,
          duration: const Duration(milliseconds: 500), curve: Curves.ease);

      await Future.delayed(_delayBetweenQuestions);

      incrementIndex();

    }
    _pageController.animateToPage(_pageIndex,
        duration: const Duration(milliseconds: 500), curve: Curves.ease);
  }

  Widget resultsPage() {
    if (_pageIndex < 13) {
      return const SizedBox.shrink();
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DataTable(
            columns: const <DataColumn>[
              DataColumn(label: Text('Trial #')),
              DataColumn(label: Text('Total Letters')),
              DataColumn(label: Text('Correct Letters')),
              DataColumn(label: Text('Your Answer')),
              DataColumn(label: Text('% Remembered')),
            ],
            rows: <DataRow>[
              for (int i = 0; i < 6; i++)
                DataRow(
                  cells: <DataCell>[
                    DataCell(Text((i + 1).toString())),
                    DataCell(Text(questionStrings[i].replaceAll(" ", "").length.toString())),
                    DataCell(Text(questionStrings[i])),
                    DataCell(Text(_questionAnswers[i].split("").join(" "))),
                    DataCell(Text("${_calculatePercentage(i)}%")),
                  ],
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'You remembered ${_calculateQuestionsCorrect()} questions correctly.',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          Padding(padding: const EdgeInsets.all(20),
          
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white, 
            ),
            onPressed: () {
              _pageController.jumpToPage(0);
              setState(() {
                _pageIndex = 0;
                _questionAnswers = List.filled(6, '');
              });
            },
            child: const Text('Start Over'),
          ),
          ),
        ],
      ),
    );
  }

  int _calculateQuestionsCorrect() {
    int correctCount = 0;
    for (int i = 0; i < 6; i++) {
      if (_calculatePercentage(i) == "100.00") {
        correctCount++;
      }
    }
    return correctCount;
  }

  String _calculatePercentage(int index) {
    String correctLetters = questionStrings[index].replaceAll(" ", "").trim();
    String userAnswer = _questionAnswers[index].replaceAll(" ", "").trim();
    int correctCount = 0;

    // Determine the maximum length to iterate over
    int maxLength = correctLetters.length < userAnswer.length
        ? correctLetters.length
        : userAnswer.length;

    // Iterate up to the length of the shortest string
    for (int i = 0; i < maxLength; i++) {
      if (correctLetters[i] == userAnswer[i]) {
        correctCount++;
      }
    }

    // Calculate and return the percentage remembered
    double percentage = (correctCount / correctLetters.length) * 100;
    return percentage.toStringAsFixed(2);
  }
}
