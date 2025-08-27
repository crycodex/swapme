import 'package:flutter/material.dart';

class InteractiveRating extends StatefulWidget {
  final int initialRating;
  final int maxRating;
  final double size;
  final Color color;
  final Function(int) onRatingChanged;
  final bool enabled;

  const InteractiveRating({
    super.key,
    this.initialRating = 5,
    this.maxRating = 5,
    this.size = 32,
    this.color = Colors.amber,
    required this.onRatingChanged,
    this.enabled = true,
  });

  @override
  State<InteractiveRating> createState() => _InteractiveRatingState();
}

class _InteractiveRatingState extends State<InteractiveRating> {
  late int _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.maxRating, (index) {
        return IconButton(
          onPressed: widget.enabled
              ? () {
                  setState(() {
                    _currentRating = index + 1;
                  });
                  widget.onRatingChanged(_currentRating);
                }
              : null,
          icon: Icon(
            index < _currentRating ? Icons.star : Icons.star_border,
            color: widget.enabled
                ? widget.color
                : widget.color.withValues(alpha: 0.3),
            size: widget.size,
          ),
        );
      }),
    );
  }
}
