import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingSlide {
  final IconData icon;
  final String title;
  final String description;
  const _OnboardingSlide(this.icon, this.title, this.description);
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _slides = const [
    _OnboardingSlide(
      Icons.inventory_2_outlined,
      'Track Your Stock',
      'Add your products, quantities, and prices. Know exactly what you have and what\'s running low — no more guessing.',
    ),
    _OnboardingSlide(
      Icons.phone_android,
      'Log Every Sale & MoMo Payment',
      'Record each sale as Cash or MoMo — with network and reference number — so every cedi is accounted for.',
    ),
    _OnboardingSlide(
      Icons.cloud_off,
      'Works Fully Offline',
      'No internet? No problem. Everything is saved on your device and syncs whenever you\'re back online.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _slides.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: widget.onDone,
                  child: const Text('Skip'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final slide = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(slide.icon, size: 64, color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.4),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _page == i ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (isLast) {
                      widget.onDone();
                    } else {
                      _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
                    }
                  },
                  child: Text(isLast ? 'Get Started' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
