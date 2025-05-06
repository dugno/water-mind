import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';

/// Dialog for setting daily water intake goal
class DailyGoalDialog extends StatefulWidget {
  /// Initial value for the daily goal
  final int initialValue;
  
  /// Measurement unit
  final MeasureUnit measureUnit;
  
  /// Callback when the value is saved
  final Function(int) onSaved;

  /// Constructor
  const DailyGoalDialog({
    super.key,
    required this.initialValue,
    required this.measureUnit,
    required this.onSaved,
  });

  @override
  State<DailyGoalDialog> createState() => _DailyGoalDialogState();
}

class _DailyGoalDialogState extends State<DailyGoalDialog> {
  late TextEditingController _controller;
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _controller = TextEditingController(text: _value.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.measureUnit == MeasureUnit.metric ? 'ml' : 'oz';
    
    return AlertDialog(
      title: Text(context.l10n.setDailyGoal),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.dailyGoalDescription),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    labelText: context.l10n.dailyGoal,
                    suffixText: unit,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        _value = int.parse(value);
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Slider for quick adjustment
          Slider(
            value: _value.toDouble(),
            min: widget.measureUnit == MeasureUnit.metric ? 1000 : 30,
            max: widget.measureUnit == MeasureUnit.metric ? 5000 : 170,
            divisions: widget.measureUnit == MeasureUnit.metric ? 40 : 14,
            label: '${_value.toString()} $unit',
            onChanged: (value) {
              setState(() {
                _value = value.toInt();
                _controller.text = _value.toString();
              });
            },
          ),
          // Recommended range text
          Text(
            widget.measureUnit == MeasureUnit.metric
                ? context.l10n.recommendedRangeMetric
                : context.l10n.recommendedRangeImperial,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            widget.onSaved(_value);
            Navigator.of(context).pop();
          },
          child: Text(context.l10n.save),
        ),
      ],
    );
  }
}
