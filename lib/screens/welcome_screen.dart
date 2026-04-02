import 'package:flutter/material.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Данные для наших трех экранов приветствия
  final List<Map<String, String>> onboardingData = [
    {
      "title": "Все тендеры Казахстана\nв одном кармане",
      "subtitle": "Находи выгодные лоты с Госзакупок быстрее конкурентов. Прямо с телефона.",
      "icon": "📱",
    },
    {
      "title": "Умная фильтрация",
      "subtitle": "Настрой карточки под себя. Ищи по БИНу, ключевым словам и сохраняй время.",
      "icon": "🎯",
    },
    {
      "title": "Первые закупки\nуже ждут тебя",
      "subtitle": "Начни пользоваться базовыми функциями бесплатно прямо сейчас.",
      "icon": "🚀",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Кнопка ПРОПУСТИТЬ в правом верхнем углу
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  // Переход на главный экран без возможности вернуться назад
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                },
                child: const Text('Пропустить', style: TextStyle(color: Colors.grey)),
              ),
            ),
            
            // Сам свайпер с контентом
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                itemCount: onboardingData.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        onboardingData[index]["icon"]!, 
                        style: const TextStyle(fontSize: 100), // Временная замена картинок на эмодзи
                      ),
                      const SizedBox(height: 50),
                      Text(
                        onboardingData[index]["title"]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        onboardingData[index]["subtitle"]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Индикаторы (точечки) и кнопка "Далее / Начать"
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  // Точечки
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length,
                      (index) => buildDot(index: index),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Кнопка
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () {
                        if (_currentPage == onboardingData.length - 1) {
                          // Если это последний экран — идем в приложение
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomeScreen()),
                          );
                        } else {
                          // Иначе листаем на следующий экран
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        }
                      },
                      child: Text(
                        _currentPage == onboardingData.length - 1 ? 'Начать поиск' : 'Далее',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Виджет для рисования точек внизу экрана
  AnimatedContainer buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.blue : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}