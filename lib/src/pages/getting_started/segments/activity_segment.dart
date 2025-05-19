import 'package:flutter/material.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';

class ActivitySegment extends StatefulWidget {
  final Function(ActivityLevel)? onActivitySelected;
  final ActivityLevel? initialActivity;

  const ActivitySegment({
    super.key,
    this.onActivitySelected,
    this.initialActivity,
  });

  @override
  State<ActivitySegment> createState() => _ActivitySegmentState();
}

class _ActivitySegmentState extends State<ActivitySegment> {
  ActivityLevel? _selectedActivity;

  @override
  void initState() {
    super.initState();
    _selectedActivity = widget.initialActivity;
  }

  void _selectActivity(ActivityLevel activity) {
    setState(() {
      _selectedActivity = activity;
    });

    if (widget.onActivitySelected != null) {
      widget.onActivitySelected!(activity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildActivityOption(context, ActivityLevel.sedentary),
          const SizedBox(height: 12),
          _buildActivityOption(context, ActivityLevel.lightlyActive),
          const SizedBox(height: 12),
          _buildActivityOption(context, ActivityLevel.moderatelyActive),
          const SizedBox(height: 12),
          _buildActivityOption(context, ActivityLevel.veryActive),
          const SizedBox(height: 12),
          _buildActivityOption(context, ActivityLevel.extraActive),
        ],
      ),
    );
  }

  Widget _buildActivityOption(BuildContext context, ActivityLevel activity) {
    final isSelected = _selectedActivity == activity;

    return GestureDetector(
      onTap: () => _selectActivity(activity),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.thirdColor : Colors.white24,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColor.thirdColor : Colors.white30,
            width: 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColor.thirdColor.withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Text(
          activity.getString(context),
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
