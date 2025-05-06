import 'package:flutter/material.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'time_of_day_picker.dart';

/// Widget for selecting multiple custom times for reminders
class CustomTimePicker extends StatefulWidget {
  /// The list of times
  final List<TimeOfDay> times;
  
  /// Callback when the times change
  final ValueChanged<List<TimeOfDay>> onTimesChanged;
  
  /// Maximum number of times that can be added
  final int maxTimes;

  /// Constructor
  const CustomTimePicker({
    super.key,
    required this.times,
    required this.onTimesChanged,
    this.maxTimes = 10,
  });

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> with HapticFeedbackMixin {
  late List<TimeOfDay> _times;
  
  @override
  void initState() {
    super.initState();
    _times = List.from(widget.times);
    
    // Add a default time if the list is empty
    if (_times.isEmpty) {
      _times.add(const TimeOfDay(hour: 12, minute: 0));
      widget.onTimesChanged(_times);
    }
  }
  
  String _formatTime(TimeOfDay time) {
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
  
  void _addTime() {
    if (_times.length >= widget.maxTimes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.maxTimesReached),
        ),
      );
      return;
    }
    
    // Find a time that's not already in the list
    TimeOfDay newTime = const TimeOfDay(hour: 12, minute: 0);
    int hour = 8;
    while (_times.any((t) => t.hour == hour && t.minute == 0) && hour < 22) {
      hour++;
    }
    newTime = TimeOfDay(hour: hour, minute: 0);
    
    setState(() {
      _times.add(newTime);
      _times.sort((a, b) {
        final aMinutes = a.hour * 60 + a.minute;
        final bMinutes = b.hour * 60 + b.minute;
        return aMinutes.compareTo(bMinutes);
      });
    });
    
    widget.onTimesChanged(_times);
  }
  
  void _removeTime(int index) {
    if (_times.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.needAtLeastOneTime),
        ),
      );
      return;
    }
    
    setState(() {
      _times.removeAt(index);
    });
    
    widget.onTimesChanged(_times);
  }
  
  Future<void> _editTime(int index) async {
    final TimeOfDay? picked = await showTimeOfDayPicker(
      context: context,
      initialTime: _times[index],
    );
    if (!mounted) {
      return;
    }
    
    if (picked != null) {
      // Check if this time already exists
      if (_times.any((t) => t.hour == picked.hour && t.minute == picked.minute)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.timeAlreadyExists),
          ),
        );
        return;
      }
      
      setState(() {
        _times[index] = picked;
        _times.sort((a, b) {
          final aMinutes = a.hour * 60 + a.minute;
          final bMinutes = b.hour * 60 + b.minute;
          return aMinutes.compareTo(bMinutes);
        });
      });
      
      widget.onTimesChanged(_times);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.customTimes,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ElevatedButton.icon(
              onPressed: _addTime,
              icon: const Icon(Icons.add),
              label: Text(context.l10n.addTime),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._times.asMap().entries.map((entry) {
          final index = entry.key;
          final time = entry.value;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                child: Text('${index + 1}'),
              ),
              title: Text(_formatTime(time)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      haptic(HapticFeedbackType.selection);
                      _editTime(index);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      haptic(HapticFeedbackType.selection);
                      _removeTime(index);
                    },
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
