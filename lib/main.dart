import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({Key? key}) : super(key : key); // вызываем конструктор родительского класса StatelessWidget

  @override
  Widget build(BuildContext context) {
    // корневой виджет приложения, определяющий структуру
    // BuildContext содержит информацию о текущем местоположении виджета в дереве виджетов
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        // colorScheme: const ColorScheme.light(
        //   primary: Colors.blue,
        //   secondary: Colors.teal,
        // ),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key : key); // вызывает конструктор родительского класса StatefulWidget

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState(); // класс состояние занимается отрисовкой и реагирует на изменения
}
// виджеты (классы, унаследованные от StatefulWidget) могут быть перестроены (rebuild)
// в ответ на изменения состояния или других факторов, в то время как состояние
// (классы, унаследованные от State) может сохранять свое состояние между перестроениями виджета.

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _displayText = '';
  String _currentOperator = '';
  bool _hasDot = false;

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'C') {
        _clearDisplay();
      } else if (buttonText == '⌫') {
        _deleteLastCharacter();
      } else if (buttonText == '=') {
        _calculateResult();
      } else if (buttonText == '( )') {
        _displayText += '(';
        _currentOperator = '';
      } else if (_displayText == 'Error' && buttonText != '') {
        _displayText = '';
        _currentOperator = '';
        _displayText += buttonText;
      } else if (_displayText.isEmpty &&
          ['+', '*', '/', '^'].contains(buttonText)) {
        // Если строка пустая и вводится знак +, *, / или ^, ничего не делаем
        return;
      } else if (_hasDot == true && buttonText == '.') {
        return;
      } else if (buttonText == '.' && _hasDot == false) {
        _displayText += buttonText;
        _hasDot = true;
      } else if (['+', '*', '/', '-'].contains(buttonText)) {
        _hasDot = false;
        if (_currentOperator.isNotEmpty &&
            _isOperator(_displayText[_displayText.length - 1])) {
          _displayText = _displayText.substring(0, _displayText.length - 1);
        }
        _displayText += buttonText;
        _currentOperator = buttonText;
      } else {
        _displayText += buttonText;
      }
    });
  }

  bool _isOperator(String buttonText) {
    return buttonText == '+' ||
        buttonText == '-' ||
        buttonText == '.' ||
        buttonText == '*' ||
        buttonText == '^' ||
        buttonText == '/' ||
        buttonText == '(' ||
        buttonText == ')';
  }

  void _calculateResult() {
    try {
      final parser = Parser(); // используется для разбора математического выражения
      final expression = parser.parse(_displayText); // передаем выражение _displayText в parser.parse()
      final contextModel = ContextModel(); // создаем экземпляр ContextModel, который предоставляет контекст для вычисления выражения
      final result = expression.evaluate(EvaluationType.REAL, contextModel); // с помощью метода expression.evaluate() выражение вычисляется с использованием типа вычисления EvaluationType.REAL и контекста contextModel

      if (result % 1 == 0) { // tсли результат является целым числом, то он преобразуется в целое число
        _displayText = result.toInt().toString();
      } else {
        _displayText = result.toString();
      }

      _currentOperator = '';
    } catch (e) {
      _displayText = 'Error';
    }
  }

  void _clearDisplay() {
    setState(() {
      _displayText = '';
      _currentOperator = '';
      _hasDot = false;
    });
  }

  void _deleteLastCharacter() {
    setState(() {
      if (_displayText == 'Error') {
        _displayText = '';
        _currentOperator = '';
      }
      if (_displayText.isNotEmpty) {
        final lastCharacter = _displayText.substring(_displayText.length - 1);
        if (lastCharacter == '.') {
          _hasDot = false;
        }
        _displayText = _displayText.substring(0, _displayText.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      body: Column(
        children: [
          Expanded( // Растягивает контейнер на все пространство столбцов
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(25),
                  bottomLeft: Radius.circular(25),
                ),
                color: Color.fromARGB(149, 87, 87, 87),
              ),
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.bottomRight,
              child: SingleChildScrollView( // добавление скрола текста
                child: Text(
                  _displayText,
                  style: const TextStyle(fontSize: 70.0, color: Colors.white),
                ),
              ),
            ),
          ),
          const Divider(), // Добавление разделителя
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Расстояние между кнопками
            children: [
              _buildButton('C'),
              _buildButton('( )'),
              _buildButton('^'),
              _buildButton('/'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton('7'),
              _buildButton('8'),
              _buildButton('9'),
              _buildButton('*'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton('4'),
              _buildButton('5'),
              _buildButton('6'),
              _buildButton('-'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton('1'),
              _buildButton('2'),
              _buildButton('3'),
              _buildButton('+'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton('0'),
              _buildButton('.'),
              _buildButton('⌫'),
              _buildButton('='),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String buttonText) {
    // Виджет для кнопок
    Color buttonColor;
    if (buttonText == '( )' ||
        buttonText == '^' ||
        buttonText == '/' ||
        buttonText == '*' ||
        buttonText == '-' ||
        buttonText == '+' ||
        buttonText == '=') {
      buttonColor = const Color.fromARGB(255, 121, 121, 121);
    } else if (buttonText == 'C') {
      buttonColor = const Color.fromARGB(92, 135, 101, 49);
    } else {
      buttonColor = const Color.fromARGB(255, 32, 32, 32);
    }
    return Expanded( // Занимает все доступное пространство
      child: Padding(
      padding: const EdgeInsets.all(7.0),
      child: ElevatedButton(
        onPressed: () {
          if (buttonText == '( )' &&
              _displayText.isNotEmpty &&
              !_isOperator(_displayText[_displayText.length - 1])) {
            _onButtonPressed(')');
          } else {
            _onButtonPressed(buttonText);
          }
        },
        style: ElevatedButton.styleFrom(
          primary: buttonColor,
          onPrimary: Colors.white,
          padding: const EdgeInsets.all(24.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.0),
          ),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 34.0, fontWeight: FontWeight.bold),
        ),
      ),
    ));
  }
}
