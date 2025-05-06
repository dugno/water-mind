import 'package:flutter/material.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';

/// Widget for selecting a time interval in minutes
class IntervalSelector extends StatefulWidget {
  /// The initial value in minutes
  final int initialValue;
  
  /// Callback when the value changes
  final ValueChanged<int> onChanged;
  
  /// Minimum interval in minutes
  final int minInterval;
  
  /// Maximum interval in minutes
  final int maxInterval;
  
  /// Step size for the slider
  final int step;

  /// Constructor
  const IntervalSelector({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.minInterval = 30,
    this.maxInterval = 240,
    this.step = 15,
  });

  @override
  State<IntervalSelector> createState() => _IntervalSelectorState();
}

class _IntervalSelectorState extends State<IntervalSelector> {
  late double _value;
  
  @override
  void initState() {
    super.initState();
    _value = widget.initialValue.toDouble();
  }
  
  String _formatInterval(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    
    if (hours > 0) {
      return mins > 0 
          ? '$hours ${context.l10n.hourShort} $mins ${context.l10n.minuteShort}'
          : '$hours ${hours == 1 ? context.l10n.hour : context.l10n.hours}';
    } else {
      return '$mins ${mins == 1 ? context.l10n.minute : context.l10n.minutes}';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.reminderInterval,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(_formatInterval(widget.minInterval)),
            Expanded(
              child: Slider(
                value: _value,
                min: widget.minInterval.toDouble(),
                max: widget.maxInterval.toDouble(),
                divisions: (widget.maxInterval - widget.minInterval) ~/ widget.step,
                label: _formatInterval(_value.round()),
                onChanged: (value) {
                  // Round to the nearest step
                  final roundedValue = (value / widget.step).round() * widget.step;
                  setState(() {
                    _value = roundedValue.toDouble();
                  });
                },
                onChangeEnd: (value) {
                  // Round to the nearest step
                  final roundedValue = (value / widget.step).round() * widget.step;
                  widget.onChanged(roundedValue.toInt());
                },
              ),
            ),
            Text(_formatInterval(widget.maxInterval)),
          ],
        ),
        Center(
          child: Text(
            _formatInterval(_value.round()),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
