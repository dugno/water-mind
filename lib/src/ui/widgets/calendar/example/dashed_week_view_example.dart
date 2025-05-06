import 'package:flutter/material.dart';
import '../controllers/calendar_controller.dart';
import '../models/calendar_config.dart';
import '../widgets/week_view.dart';

class DashedWeekViewExample extends StatefulWidget {
  /// Constructor
  const DashedWeekViewExample({super.key});

  @override
  State<DashedWeekViewExample> createState() => _DashedWeekViewExampleState();
}

class _DashedWeekViewExampleState extends State<DashedWeekViewExample> {
  late CalendarController _controller;

  @override
  void initState() {
    super.initState();
    
    // Khởi tạo controller với cấu hình đường viền đứt nét
    _controller = CalendarController(
      config: CalendarConfig.withDashedBorders(
        locale: const Locale('vi'),
        showDateBelowCircle: true,
        dashedBorderColor: Colors.grey.withOpacity(0.7),
        progressColor: Colors.blue,
      ),
      initialDate: DateTime.now(),
    );
    
    // Thiết lập tiến trình cho một số ngày
    _setupProgressForDays();
  }
  
  /// Thiết lập tiến trình cho một số ngày
  void _setupProgressForDays() {
    // Lấy ngày hiện tại
    final today = DateTime.now();
    
    // Thiết lập tiến trình cho ngày hôm nay (100%)
    _controller.updateProgressForDay(today, 1.0);
    
    // Thiết lập tiến trình cho ngày hôm qua (75%)
    final yesterday = today.subtract(const Duration(days: 1));
    _controller.updateProgressForDay(yesterday, 0.75);
    
    // Thiết lập tiến trình cho ngày hôm kia (50%)
    final twoDaysAgo = today.subtract(const Duration(days: 2));
    _controller.updateProgressForDay(twoDaysAgo, 0.5);
    
    // Thiết lập tiến trình cho 3 ngày trước (25%)
    final threeDaysAgo = today.subtract(const Duration(days: 3));
    _controller.updateProgressForDay(threeDaysAgo, 0.25);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashed Week View Example'),
      ),
      body: Column(
        children: [
          // Hiển thị WeekView
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: WeekView(controller: _controller),
            ),
          ),
          
          // Các nút điều khiển
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => _controller.previousWeek()),
                  child: const Text('Tuần trước'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _controller.goToToday()),
                  child: const Text('Hôm nay'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _controller.nextWeek()),
                  child: const Text('Tuần sau'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
