import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' show pi;

class InstructionCard extends StatelessWidget {
  const InstructionCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If you have logic, keep it here. For now, just pass context to the view.
    return InstructionCardView();
  }
}

class InstructionCardView extends StatefulWidget {
  const InstructionCardView({Key? key}) : super(key: key);

  @override
  State<InstructionCardView> createState() => _InstructionCardViewState();
}

class _InstructionCardViewState extends State<InstructionCardView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _angleAnimation;
  Timer? _timer;

  final GlobalKey _cardKey = GlobalKey();
  double _alignmentY = 1.0; // Default: pivot at the bottom of the card

  final double _maxAngleRad = 6 * (pi / 180); // 10 degrees in radians

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration:
          const Duration(milliseconds: 1500), // Duration of one full wiggle
      vsync: this,
    );

    _angleAnimation = TweenSequence<double>(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: -_maxAngleRad)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 25.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: -_maxAngleRad, end: 0.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 25.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: _maxAngleRad)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 25.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: _maxAngleRad, end: 0.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 25.0,
        ),
      ],
    ).animate(_animationController);

    // Start the first animation shortly after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAlignment();
      if (mounted) {
        _startAnimation();
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 7), (Timer t) {
      if (mounted) {
        _startAnimation();
      }
    });
  }

  void _updateAlignment() {
    final screenHeight = MediaQuery.of(context).size.height;
    final RenderBox? cardRenderBox =
        _cardKey.currentContext?.findRenderObject() as RenderBox?;

    if (cardRenderBox != null && cardRenderBox.hasSize) {
      final cardHeight = cardRenderBox.size.height;
      final cardTopOffset = cardRenderBox.localToGlobal(Offset.zero).dy;

      if (cardHeight > 0) {
        // Formula to calculate the alignment's Y value to set the pivot point
        // at the bottom of the screen.
        final newAlignmentY =
            (2 * (screenHeight - cardTopOffset) / cardHeight) - 1;

        if (mounted && newAlignmentY != _alignmentY) {
          setState(() {
            _alignmentY = newAlignmentY;
          });
        }
      }
    }
  }

  void _startAnimation() {
    if (mounted && !_animationController.isAnimating) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _angleAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _angleAnimation.value,
          alignment: Alignment(0.0, _alignmentY),
          child: child,
        );
      },
      child: Card(
        key: _cardKey,
        margin: const EdgeInsets.all(12),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo or icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.category,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                'Revisão Dinâmica',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Description
              Text(
                'Vamos revisar todas suas transações sincronizadas? Para cada grupo, você pode:',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Instructions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: const [
                    InstructionItem(
                      icon: Icons.swipe_right,
                      color: Colors.green,
                      title: 'Deslizar para Direita',
                      description: 'Escolher uma categoria para classificar',
                    ),
                    SizedBox(height: 16),
                    InstructionItem(
                      icon: Icons.swipe_left,
                      color: Colors.red,
                      title: 'Deslizar para Esquerda',
                      description: 'Descartar este grupo',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Start button
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.swipe,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Deslize para começar',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InstructionItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const InstructionItem({
    Key? key,
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InstructionItemView(
      icon: icon,
      color: color,
      title: title,
      description: description,
    );
  }
}

class InstructionItemView extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const InstructionItemView({
    Key? key,
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withOpacity(0.7),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
