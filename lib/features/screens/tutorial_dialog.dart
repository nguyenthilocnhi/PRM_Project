import 'package:flutter/material.dart';

class TutorialDialog extends StatefulWidget {
  const TutorialDialog({super.key});

  @override
  State<TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<TutorialDialog> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 560,
        decoration: BoxDecoration(
          color: const Color(0xfffff8df),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.brown.shade200, width: 2),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'HOW TO PLAY',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xff6b4226),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildTutorialPage(
                    title: 'Decode the Numbers',
                    description: 'Each number represents a secret letter. When you guess a letter correctly, all matching numbers will be filled.',
                    imageWidget: _buildIllustration1(),
                  ),
                  _buildTutorialPage(
                    title: 'Complete the Quotes',
                    description: 'Use the solved words to deduce the rest of the message. Your goal is to decode the entire quote.',
                    imageWidget: _buildIllustration2(),
                  ),
                  _buildTutorialPage(
                    title: 'Need a Hint?',
                    description: 'If you get stuck, use the Hint button. You have a maximum of 3 hints, which regenerate every 60 minutes.',
                    imageWidget: _buildIllustration3(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? const Color(0xff45b7f5) : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff45b7f5),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  _currentPage == 2 ? 'GOT IT!' : 'NEXT',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialPage({
    required String title,
    required String description,
    required Widget imageWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Center(child: imageWidget),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Illustration 1: Number corresponds to letter
  Widget _buildIllustration1() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _mockCell('12', 'A', isSelected: true),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward_rounded, color: Colors.grey),
        const SizedBox(width: 8),
        _mockCell('12', 'A'),
        const SizedBox(width: 12),
        _mockCell('15', ''),
        const SizedBox(width: 12),
        _mockCell('12', 'A'),
      ],
    );
  }

  // Illustration 2: Fill the word
  Widget _buildIllustration2() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _mockCell('12', 'A'),
            const SizedBox(width: 12),
            _mockCell('15', 'N'),
            const SizedBox(width: 12),
            _mockCell('3', 'D'),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Excellent!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  // Illustration 3: Hint button
  Widget _buildIllustration3() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xff1597f5),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 3))],
              ),
              child: const Icon(Icons.lightbulb, color: Colors.white, size: 36),
            ),
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200, width: 2),
                ),
                child: const Text('2', style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('59:59', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white, letterSpacing: 1)),
        ),
      ],
    );
  }

  Widget _mockCell(String number, String letter, {bool isSelected = false}) {
    return SizedBox(
      width: 32,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? Colors.yellow.withValues(alpha: 0.3) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              letter,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ),
          Container(
            width: 30,
            height: 3,
            margin: const EdgeInsets.only(top: 2),
            color: isSelected ? Colors.blue : Colors.black,
          ),
          const SizedBox(height: 2),
          Text(
            number,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.blueGrey,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
