import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/services/premium/premium_service_provider.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/ui/widgets/bottom_sheets/base_bottom_sheet.dart';
import 'package:water_mind/src/ui/widgets/premium/premium_feature_lock.dart';
import 'package:water_mind/src/ui/widgets/water_cup/simple_water_cup.dart';
import 'package:water_mind/src/ui/widgets/wheel_picker/wheel_picker.dart';

/// A bottom sheet for selecting water amount using wheel picker with premium check
class PremiumAmountWheelSheet extends ConsumerStatefulWidget {
  /// The initial amount of water
  final double initialAmount;

  /// The measurement unit (metric or imperial)
  final MeasureUnit measureUnit;

  /// Constructor
  const PremiumAmountWheelSheet({
    super.key,
    required this.initialAmount,
    required this.measureUnit,
  });

  /// Show the amount picker bottom sheet
  static Future<double?> show({
    required BuildContext context,
    required double initialAmount,
    required MeasureUnit measureUnit,
  }) {
    return BaseBottomSheet.show<double>(
      context: context,
      maxHeightFactor: 0.5,
      child: PremiumAmountWheelSheet(
        initialAmount: initialAmount,
        measureUnit: measureUnit,
      ),
    );
  }

  @override
  ConsumerState<PremiumAmountWheelSheet> createState() => _PremiumAmountWheelSheetState();
}

class _PremiumAmountWheelSheetState extends ConsumerState<PremiumAmountWheelSheet> with HapticFeedbackMixin {
  late double _selectedAmount;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _selectedAmount = widget.initialAmount;
  }

  @override
  void dispose() {
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
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            context.l10n.selectAmount,
            style: Theme.of(context).textTheme.titleLarge,
          )
        ),

        // Selected amount display
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _selectedAmount.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),

        // Amount wheel picker with premium check
        SizedBox(
          height: 150,
          child: isPremiumActiveAsync.when(
            data: (isPremiumActive) {
              if (isPremiumActive || _selectedAmount == 200.0) {
                return _buildAmountPicker();
              } else {
                return PremiumFeatureLock(
                  message: context.l10n.premiumAmountMessage,
                  child: _buildAmountPicker(),
                );
              }
            },
            loading: () => _buildAmountPicker(),
            error: (_, __) => _buildAmountPicker(),
          ),
        ),

        // Buttons
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  haptic(HapticFeedbackType.light);
                  Navigator.of(context).pop();
                },
                child: Text(context.l10n.cancel),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  haptic(HapticFeedbackType.medium);
                  
                  // Check if premium is active or if default amount is selected
                  final isPremiumActive = ref.read(isPremiumActiveProvider).value ?? false;
                  if (isPremiumActive || _selectedAmount == 200.0) {
                    Navigator.of(context).pop(_selectedAmount);
                  } else {
                    // If not premium and not default amount, return default amount
                    Navigator.of(context).pop(200.0);
                  }
                },
                child: Text(context.l10n.select),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountPicker() {
    final List<WheelPickerItem<double>> amountItems;
    final String unit = widget.measureUnit == MeasureUnit.metric ? 'ml' : 'fl oz';

    if (widget.measureUnit == MeasureUnit.metric) {
      // Metric: 50ml to 1000ml in 50ml increments
      amountItems = List.generate(20, (index) {
        final amount = 50.0 * (index + 1);
        return WheelPickerItem<double>(
          value: amount,
          text: '${amount.toInt()} $unit', // Keep text for backward compatibility
          widget: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Add SimpleWaterCup with corresponding currentWaterAmount
              SimpleWaterCup(
                currentWaterAmount: amount,
                maxWaterAmount: 1000,
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 10),
              Text(
                '${amount.toInt()} $unit',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      });
    } else {
      // Imperial: 2oz to 32oz in 2oz increments
      amountItems = List.generate(16, (index) {
        final amount = 2.0 * (index + 1);
        // Convert from oz to ml for display in SimpleWaterCup
        final amountInMl = amount * 29.5735; // 1 fl oz ≈ 29.5735 ml
        return WheelPickerItem<double>(
          value: amount,
          text: '${amount.toInt()} $unit', // Keep text for backward compatibility
          widget: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Add SimpleWaterCup with corresponding currentWaterAmount
              SimpleWaterCup(
                currentWaterAmount: amountInMl,
                maxWaterAmount: 1000,
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 10),
              Text(
                '${amount.toInt()} $unit',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      });
    }

    // Find initial index
    int initialIndex = 0;
    if (widget.measureUnit == MeasureUnit.metric) {
      initialIndex = ((_selectedAmount / 50.0) - 1).round().clamp(0, 19);
    } else {
      initialIndex = ((_selectedAmount / 2.0) - 1).round().clamp(0, 15);
    }

    return WheelPicker(
      columns: [amountItems],
      initialIndices: [initialIndex],
      onSelectedItemChanged: (columnIndex, itemIndex, value) {
        haptic(HapticFeedbackType.selection);
        if (!_isDisposed && mounted) {
          setState(() {
            _selectedAmount = value as double;
          });
        }
      },
      config: const WheelPickerConfig(
        height: 150,
        useHapticFeedback: true,
        itemHeight: 50,
      ),
    );
  }
}
