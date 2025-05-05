import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:water_mind/src/core/models/water_intake_entry.dart';
import 'package:water_mind/src/core/models/water_intake_history.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';

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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s History',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${history.formattedTotalAmount} / ${history.formattedDailyGoal}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: history.goalMet
                            ? Colors.green
                            : Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: history.progressPercentage.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                history.goalMet ? Colors.green : Theme.of(context).colorScheme.primary,
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),
            _buildHistoryList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    if (history.entries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No entries for today. Start drinking!'),
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
      separatorBuilder: (context, index) => const Divider(),
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
      leading: Icon(
        entry.drinkType.icon,
        color: entry.drinkType.color,
        size: 32,
      ),
      title: Text(
        '${entry.amount.toStringAsFixed(0)} $unit of ${entry.drinkType.name}',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      subtitle: Text(
        'at ${timeFormat.format(entry.timestamp)}${entry.note != null ? ' • ${entry.note}' : ''}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: onEntryDeleted != null
          ? IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => onEntryDeleted!(entry),
            )
          : null,
    );
  }
}
