import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/services/premium/premium_service_provider.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/ui/widgets/bottom_sheets/base_bottom_sheet.dart';
import 'package:water_mind/src/ui/widgets/premium/premium_feature_lock.dart';

/// Bottom sheet for setting daily water intake goal with premium check
class PremiumDailyGoalBottomSheet extends ConsumerStatefulWidget {
  /// Initial value for the daily goal
  final int initialValue;

  /// Measurement unit
  final MeasureUnit measureUnit;

  /// Callback when the value is saved
  final Function(int) onSaved;

  /// Constructor
  const PremiumDailyGoalBottomSheet({
    super.key,
    required this.initialValue,
    required this.measureUnit,
    required this.onSaved,
  });

  /// Show the daily goal bottom sheet
  static Future<void> show({
    required BuildContext context,
    required int initialValue,
    required MeasureUnit measureUnit,
    required Function(int) onSaved,
  }) {
    return BaseBottomSheet.show(
      context: context,
      useGradientBackground: true,
      maxHeightFactor: 0.7,
      child: PremiumDailyGoalBottomSheet(
        initialValue: initialValue,
        measureUnit: measureUnit,
        onSaved: onSaved,
      ),
    );
  }

  @override
  ConsumerState<PremiumDailyGoalBottomSheet> createState() => _PremiumDailyGoalBottomSheetState();
}

class _PremiumDailyGoalBottomSheetState extends ConsumerState<PremiumDailyGoalBottomSheet> with HapticFeedbackMixin {
  late int _value;
  late TextEditingController _controller;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _controller = TextEditingController(text: _value.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.measureUnit == MeasureUnit.metric ? 'ml' : 'fl oz';
    final isPremiumActiveAsync = ref.watch(isPremiumActiveProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
          child: Text(
            context.l10n.setDailyGoal,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),

        // Description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            context.l10n.dailyGoalDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 24),

        // Current value display
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _value.toString(),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Slider with premium check
        isPremiumActiveAsync.when(
          data: (isPremiumActive) {
            if (isPremiumActive) {
              return _buildSlider();
            } else {
              return PremiumFeatureLock(
                message: context.l10n.customDailyGoalDesc,
                child: _buildSlider(),
              );
            }
          },
          loading: () => _buildSlider(),
          error: (_, __) => _buildSlider(),
        ),

        const SizedBox(height: 16),

        // Recommended range text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            widget.measureUnit == MeasureUnit.metric
                ? context.l10n.recommendedRangeMetric
                : context.l10n.recommendedRangeImperial,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 24),

        // Buttons
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  haptic(HapticFeedbackType.light);
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
                child: Text(context.l10n.cancel),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  haptic(HapticFeedbackType.medium);
                  
                  // Check if premium is active
                  final isPremiumActive = ref.read(isPremiumActiveProvider).value ?? false;
                  if (isPremiumActive) {
                    widget.onSaved(_value);
                    Navigator.of(context).pop();
                  } else {
                    // If not premium, use the default calculated value
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColor.primaryColor,
                ),
                child: Text(context.l10n.save),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSlider() {
    return Column(
      children: [
        // Text field for manual input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: context.l10n.dailyGoal,
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
              suffixText: widget.measureUnit == MeasureUnit.metric ? 'ml' : 'fl oz',
              suffixStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && !_isDisposed) {
                setState(() {
                  _value = int.parse(value);
                });
              }
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Slider for quick adjustment
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Slider(
            value: _value.toDouble(),
            min: widget.measureUnit == MeasureUnit.metric ? 1000 : 30,
            max: widget.measureUnit == MeasureUnit.metric ? 5000 : 170,
            divisions: widget.measureUnit == MeasureUnit.metric ? 40 : 14,
            label: '${_value.toString()} ${widget.measureUnit == MeasureUnit.metric ? 'ml' : 'fl oz'}',
            activeColor: Colors.white,
            inactiveColor: Colors.white.withOpacity(0.3),
            onChanged: (value) {
              if (!_isDisposed) {
                haptic(HapticFeedbackType.selection);
                setState(() {
                  _value = value.toInt();
                  _controller.text = _value.toString();
                });
              }
            },
          ),
        ),
      ],
    );
  }
}
