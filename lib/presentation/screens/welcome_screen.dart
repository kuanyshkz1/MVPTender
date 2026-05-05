import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth_storage.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingSlide> onboardingData = const [
    _OnboardingSlide(
      title: 'Все тендеры Казахстана\nв одном кармане',
      subtitle:
          'Находи выгодные лоты с Госзакупок быстрее конкурентов. Прямо с телефона.',
      icon: Icons.phone_iphone_rounded,
    ),
    _OnboardingSlide(
      title: 'Умная фильтрация',
      subtitle:
          'Настрой карточки под себя. Ищи по БИНу, ключевым словам и сохраняй время.',
      icon: Icons.tune_rounded,
    ),
    _OnboardingSlide(
      title: 'Первые закупки\nуже ждут тебя',
      subtitle: 'Начни пользоваться базовыми функциями бесплатно прямо сейчас.',
      icon: Icons.rocket_launch_rounded,
    ),
  ];

  Future<void> _finishOnboarding(BuildContext context) async {
    await AuthStorage.completeOnboarding();

    if (context.mounted) {
      final user = Firebase.apps.isEmpty
          ? null
          : FirebaseAuth.instance.currentUser;
      context.go(user == null ? '/login' : '/home');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLastPage = _currentPage == onboardingData.length - 1;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'QazTender',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _finishOnboarding(context),
                    child: Text(
                      'Пропустить',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                itemCount: onboardingData.length,
                itemBuilder: (context, index) {
                  return _SlideView(slide: onboardingData[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length,
                      (index) => buildDot(index: index),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                      onPressed: () {
                        if (isLastPage) {
                          _finishOnboarding(context);
                          return;
                        }

                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                        );
                      },
                      icon: Icon(
                        isLastPage
                            ? Icons.search_rounded
                            : Icons.arrow_forward_rounded,
                      ),
                      label: Text(
                        isLastPage ? 'Начать поиск' : 'Далее',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
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

  AnimatedContainer buildDot({required int index}) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = _currentPage == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 28 : 8,
      decoration: BoxDecoration(
        color: isActive
            ? colorScheme.primary
            : colorScheme.outlineVariant.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  final _OnboardingSlide slide;

  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 44),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Icon(slide.icon, color: colorScheme.primary, size: 56),
                ),
                const SizedBox(height: 42),
                Text(
                  slide.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    height: 1.18,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  slide.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OnboardingSlide {
  final String title;
  final String subtitle;
  final IconData icon;

  const _OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
