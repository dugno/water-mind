import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/models/drink_type.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/services/premium/premium_service_provider.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/ui/widgets/bottom_sheets/base_bottom_sheet.dart';
import 'package:water_mind/src/ui/widgets/premium/premium_feature_lock.dart';
import 'package:water_mind/src/ui/widgets/wheel_picker/wheel_picker.dart';

/// A bottom sheet for selecting drink type using wheel picker with premium check
class PremiumDrinkTypeWheelSheet extends ConsumerStatefulWidget {
  /// The initially selected drink type
  final DrinkType initialDrinkType;

  /// Constructor
  const PremiumDrinkTypeWheelSheet({
    super.key,
    required this.initialDrinkType,
  });

  /// Show the drink type picker bottom sheet
  static Future<DrinkType?> show({
    required BuildContext context,
    required DrinkType initialDrinkType,
  }) {
    return BaseBottomSheet.show<DrinkType>(
      context: context,
      maxHeightFactor: 0.5,
      child: PremiumDrinkTypeWheelSheet(
        initialDrinkType: initialDrinkType,
      ),
    );
  }

  @override
  ConsumerState<PremiumDrinkTypeWheelSheet> createState() => _PremiumDrinkTypeWheelSheetState();
}

class _PremiumDrinkTypeWheelSheetState extends ConsumerState<PremiumDrinkTypeWheelSheet> with HapticFeedbackMixin {
  late DrinkType _selectedDrinkType;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _selectedDrinkType = widget.initialDrinkType;
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremiumActiveAsync = ref.watch(isPremiumActiveProvider);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            context.l10n.selectDrinkType,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),

        // Selected drink type display
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _selectedDrinkType.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _selectedDrinkType.icon,
                size: 48,
                color: _selectedDrinkType.color,
              ),
              const SizedBox(width: 16),
              Text(
                _selectedDrinkType.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _selectedDrinkType.color,
                ),
              ),
            ],
          ),
        ),

        // Drink type wheel picker with premium check
        SizedBox(
          height: 150,
          child: isPremiumActiveAsync.when(
            data: (isPremiumActive) {
              if (isPremiumActive || _selectedDrinkType.id == 'water') {
                return _buildDrinkTypePicker();
              } else {
                return PremiumFeatureLock(
                  message: context.l10n.premiumDrinkTypeMessage,
                  child: _buildDrinkTypePicker(),
                );
              }
            },
            loading: () => _buildDrinkTypePicker(),
            error: (_, __) => _buildDrinkTypePicker(),
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
                  
                  // Check if premium is active or if water is selected
                  final isPremiumActive = ref.read(isPremiumActiveProvider).value ?? false;
                  if (isPremiumActive || _selectedDrinkType.id == 'water') {
                    Navigator.of(context).pop(_selectedDrinkType);
                  } else {
                    // If not premium and not water, show premium subscription page
                    Navigator.of(context).pop(DrinkTypes.water);
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

  // Create a WheelPickerItem for DrinkType
  WheelPickerItem<DrinkType> _buildDrinkTypeItem(DrinkType drinkType) {
    return WheelPickerItem<DrinkType>(
      value: drinkType,
      text: drinkType.name, // Keep text for backward compatibility
      widget: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            drinkType.icon,
            color: drinkType.color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            drinkType.name,
            style: TextStyle(
              color: drinkType.color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrinkTypePicker() {
    // Create items for the wheel picker with custom Row widgets
    final List<WheelPickerItem<DrinkType>> drinkTypeItems = DrinkTypes.all.map((drinkType) {
      return _buildDrinkTypeItem(drinkType);
    }).toList();

    // Find initial index
    int initialIndex = DrinkTypes.all.indexWhere((d) => d.id == _selectedDrinkType.id);
    if (initialIndex < 0) initialIndex = 0;

    return WheelPicker(
      columns: [drinkTypeItems],
      initialIndices: [initialIndex],
      onSelectedItemChanged: (columnIndex, itemIndex, value) {
        haptic(HapticFeedbackType.selection);
        if (!_isDisposed && mounted) {
          setState(() {
            _selectedDrinkType = value as DrinkType;
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
