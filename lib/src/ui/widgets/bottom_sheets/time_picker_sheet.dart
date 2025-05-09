import 'package:flutter/material.dart';
import 'package:water_mind/src/ui/widgets/bottom_sheets/base_bottom_sheet.dart';

/// A bottom sheet for picking time
class TimePickerSheet extends StatefulWidget {
  /// The initial time
  final TimeOfDay initialTime;

  /// The minimum hour (24-hour format)
  final int minHour;

  /// The maximum hour (24-hour format)
  final int maxHour;

  /// Constructor
  const TimePickerSheet({
    super.key,
    required this.initialTime,
    this.minHour = 6,
    this.maxHour = 23,
  });

  /// Show the time picker bottom sheet
  static Future<TimeOfDay?> show({
    required BuildContext context,
    required TimeOfDay initialTime,
    int minHour = 6,
    int maxHour = 23,
  }) {
    return BaseBottomSheet.show<TimeOfDay>(
      context: context,
      maxHeightFactor: 0.6,
      child: TimePickerSheet(
        initialTime: initialTime,
        minHour: minHour,
        maxHour: maxHour,
      ),
    );
  }

  @override
  State<TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<TimePickerSheet> {
  late TimeOfDay _time;
  late int _selectedHourIndex;
  late int _selectedMinuteIndex;

  // For the time picker
  late final PageController _hourController;
  late final PageController _minuteController;
  late final List<String> _hours;
  static const List<String> _minutes = ['00', '01', '02', '03', '04', '05', '06', '07', '08', '09', 
                                       '10', '11', '12', '13', '14', '15', '16', '17', '18', '19',
                                       '20', '21', '22', '23', '24', '25', '26', '27', '28', '29',
                                       '30', '31', '32', '33', '34', '35', '36', '37', '38', '39',
                                       '40', '41', '42', '43', '44', '45', '46', '47', '48', '49',
                                       '50', '51', '52', '53', '54', '55', '56', '57', '58', '59'];

  @override
  void initState() {
    super.initState();
    _time = widget.initialTime;
    
    // Generate hours list based on min and max hour
    _hours = List.generate(
      widget.maxHour - widget.minHour + 1, 
      (index) => '${index + widget.minHour} Th${(index + widget.minHour) ~/ 12 + 2}'
    );
    
    // Initialize time controllers
    _selectedHourIndex = _time.hour.clamp(widget.minHour, widget.maxHour) - widget.minHour;
    _selectedMinuteIndex = _time.minute;
    
    _hourController = PageController(
      viewportFraction: 0.3,
      initialPage: _selectedHourIndex,
    );
    
    _minuteController = PageController(
      viewportFraction: 0.3,
      initialPage: _selectedMinuteIndex,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Time display
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Time picker
        SizedBox(
          height: 180,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hours
              SizedBox(
                width: 100,
                child: PageView.builder(
                  controller: _hourController,
                  scrollDirection: Axis.vertical,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedHourIndex = index;
                      _time = TimeOfDay(hour: index + widget.minHour, minute: _time.minute);
                    });
                  },
                  itemCount: _hours.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedHourIndex;
                    
                    return Center(
                      child: Text(
                        _hours[index],
                        style: TextStyle(
                          fontSize: isSelected ? 20 : 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.black : Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Separator
              Text(
                ':',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              
              // Minutes
              SizedBox(
                width: 60,
                child: PageView.builder(
                  controller: _minuteController,
                  scrollDirection: Axis.vertical,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedMinuteIndex = index;
                      _time = TimeOfDay(hour: _time.hour, minute: index);
                    });
                  },
                  itemCount: _minutes.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedMinuteIndex;
                    
                    return Center(
                      child: Text(
                        _minutes[index],
                        style: TextStyle(
                          fontSize: isSelected ? 20 : 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.black : Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
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
                  Navigator.of(context).pop(_time);
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
