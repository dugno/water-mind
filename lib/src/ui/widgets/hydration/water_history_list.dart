import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/models/water_intake_entry.dart';
import 'package:water_mind/src/core/models/water_intake_history.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/ui/widgets/water_cup/simple_water_cup.dart';

/// Widget to display water intake history for a day
class WaterHistoryList extends StatelessWidget {
  /// Water intake history for the day
  final WaterIntakeHistory history;

  /// Callback when an entry is deleted
  final Function(WaterIntakeEntry)? onEntryDeleted;

  /// Constructor
  const WaterHistoryList({
    super.key,
    required this.history,
    this.onEntryDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today\'s History',
                style: TextStyle(
                  color: AppColor.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '${history.formattedTotalAmount} / ${history.formattedDailyGoal}',
                style: TextStyle(
                  color: history.goalMet ? AppColor.successColor : AppColor.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: history.progressPercentage.clamp(0.0, 1.0),
          backgroundColor: AppColor.backgroundColor,
          valueColor: AlwaysStoppedAnimation<Color>(
            history.goalMet ? AppColor.successColor : AppColor.secondaryColor,
          ),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 16),
        _buildHistoryList(context),
      ],
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    if (history.entries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No entries for today. Start drinking!',
            style: TextStyle(color: AppColor.primaryColor),
          ),
        ),
      );
    }

    // Sort entries by timestamp (newest first)
    final sortedEntries = List<WaterIntakeEntry>.from(history.entries)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedEntries.length,
      separatorBuilder: (context, index) => Divider(color: AppColor.primaryColor.withOpacity(0.2)),
      itemBuilder: (context, index) {
        final entry = sortedEntries[index];
        return _buildHistoryItem(context, entry);
      },
    );
  }

  Widget _buildHistoryItem(BuildContext context, WaterIntakeEntry entry) {
    final timeFormat = DateFormat.Hm();
    final String unit = history.measureUnit == MeasureUnit.metric ? 'ml' : 'fl oz';

    return ListTile(
      leading: SizedBox(
        width: 40,
        height: 40,
        child: SimpleWaterCup(
          currentWaterAmount: entry.amount,
          maxWaterAmount: 1000,
          width: 40,
          height: 40,
        ),
      ),
      title: Text(
        '${entry.amount.toStringAsFixed(0)} $unit of ${entry.drinkType.name}',
        style: const TextStyle(
          color: AppColor.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        'at ${timeFormat.format(entry.timestamp)}${entry.note != null ? ' • ${entry.note}' : ''}',
        style: const TextStyle(
          color: AppColor.secondaryColor,
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: onEntryDeleted != null
          ? IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColor.secondaryColor),
              onPressed: () => onEntryDeleted!(entry),
            )
          : null,
    );
  }
}
