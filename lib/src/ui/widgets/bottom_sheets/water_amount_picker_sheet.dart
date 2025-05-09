import 'package:flutter/material.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/ui/widgets/bottom_sheets/base_bottom_sheet.dart';

/// A bottom sheet for selecting water amount
class WaterAmountPickerSheet extends StatefulWidget {
  /// The initial amount of water
  final double initialAmount;

  /// The measurement unit (metric or imperial)
  final MeasureUnit measureUnit;

  /// The minimum amount that can be selected
  final double minAmount;

  /// The maximum amount that can be selected
  final double maxAmount;

  /// The step between amounts
  final double step;

  /// Constructor
  const WaterAmountPickerSheet({
    super.key,
    required this.initialAmount,
    required this.measureUnit,
    this.minAmount = 50,
    this.maxAmount = 1000,
    this.step = 50,
  });

  /// Show the water amount picker bottom sheet
  static Future<double?> show({
    required BuildContext context,
    required double initialAmount,
    required MeasureUnit measureUnit,
    double minAmount = 50,
    double maxAmount = 1000,
    double step = 50,
  }) {
    return BaseBottomSheet.show<double>(
      context: context,
      maxHeightFactor: 0.5,
      child: WaterAmountPickerSheet(
        initialAmount: initialAmount,
        measureUnit: measureUnit,
        minAmount: minAmount,
        maxAmount: maxAmount,
        step: step,
      ),
    );
  }

  @override
  State<WaterAmountPickerSheet> createState() => _WaterAmountPickerSheetState();
}

class _WaterAmountPickerSheetState extends State<WaterAmountPickerSheet> {
  late double _amount;
  
  // For the number picker
  late final PageController _amountController;
  late final int _itemCount;
  static const double _itemExtent = 60.0;
  
  @override
  void initState() {
    super.initState();
    _amount = widget.initialAmount;
    
    // Calculate the number of items based on min, max, and step
    _itemCount = ((widget.maxAmount - widget.minAmount) / widget.step).round() + 1;
    
    // Initialize amount controller
    final initialAmountPage = ((_amount - widget.minAmount) / widget.step).round().clamp(0, _itemCount - 1);
    _amountController = PageController(
      viewportFraction: 0.4,
      initialPage: initialAmountPage,
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.measureUnit == MeasureUnit.metric ? 'ml' : 'fl oz';
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Amount display
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _amount.toStringAsFixed(0),
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
        
        // Amount picker
        SizedBox(
          height: _itemExtent,
          child: PageView.builder(
            controller: _amountController,
            onPageChanged: (index) {
              setState(() {
                _amount = widget.minAmount + (index * widget.step);
              });
            },
            itemCount: _itemCount,
            itemBuilder: (context, index) {
              final value = widget.minAmount + (index * widget.step);
              final isSelected = value == _amount;
              
              return Center(
                child: Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: isSelected ? 24 : 18,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.black : Colors.grey,
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(_amount);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
