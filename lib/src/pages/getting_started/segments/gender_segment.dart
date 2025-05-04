import 'package:flutter/material.dart';
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
          color: isSelected ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF1A1A1A) : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            gender.getString(context),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
