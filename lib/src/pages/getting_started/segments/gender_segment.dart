import 'package:flutter/material.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/utils/enum/gender.dart';

class GenderSegment extends StatefulWidget {
  final Function(Gender)? onGenderSelected;
  final Gender? initialGender;

  const GenderSegment({
    super.key,
    this.onGenderSelected,
    this.initialGender,
  });

  @override
  State<GenderSegment> createState() => _GenderSegmentState();
}

class _GenderSegmentState extends State<GenderSegment> {
  Gender? _selectedGender;

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.initialGender;
  }

  void _selectGender(Gender gender) {
    setState(() {
      _selectedGender = gender;
    });

    if (widget.onGenderSelected != null) {
      widget.onGenderSelected!(gender);
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
          _buildGenderOption(context, Gender.male),
          const SizedBox(height: 12),
          _buildGenderOption(context, Gender.female),
          const SizedBox(height: 12),
          _buildGenderOption(context, Gender.pregnant),
          const SizedBox(height: 12),
          _buildGenderOption(context, Gender.breastfeeding),
          const SizedBox(height: 12),
          _buildGenderOption(context, Gender.other),
        ],
      ),
    );
  }

  Widget _buildGenderOption(BuildContext context, Gender gender) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => _selectGender(gender),
      child: Container(
        width: double.infinity,
        height: 50,
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
        child: Center(
          child: Text(
            gender.getString(context),
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
