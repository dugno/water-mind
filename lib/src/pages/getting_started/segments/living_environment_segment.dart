import 'package:flutter/material.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';

class LivingEnvironmentSegment extends StatefulWidget {
  final Function(LivingEnvironment)? onEnvironmentSelected;
  final LivingEnvironment? initialEnvironment;

  const LivingEnvironmentSegment({
    super.key,
    this.onEnvironmentSelected,
    this.initialEnvironment,
  });

  @override
  State<LivingEnvironmentSegment> createState() =>
      _LivingEnvironmentSegmentState();
}

class _LivingEnvironmentSegmentState extends State<LivingEnvironmentSegment> {
  LivingEnvironment? _selectedEnvironment;

  @override
  void initState() {
    super.initState();
    _selectedEnvironment = widget.initialEnvironment;
  }

  void _selectEnvironment(LivingEnvironment environment) {
    setState(() {
      _selectedEnvironment = environment;
    });

    if (widget.onEnvironmentSelected != null) {
      widget.onEnvironmentSelected!(environment);
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
          _buildEnvironmentOption(context, LivingEnvironment.airConditioned),
          const SizedBox(height: 12),
          _buildEnvironmentOption(context, LivingEnvironment.hotSunny),
          const SizedBox(height: 12),
          _buildEnvironmentOption(context, LivingEnvironment.rainyHumid),
          const SizedBox(height: 12),
          _buildEnvironmentOption(context, LivingEnvironment.cold),
          const SizedBox(height: 12),
          _buildEnvironmentOption(context, LivingEnvironment.moderate),
        ],
      ),
    );
  }

  Widget _buildEnvironmentOption(
      BuildContext context, LivingEnvironment environment) {
    final isSelected = _selectedEnvironment == environment;

    return GestureDetector(
      onTap: () => _selectEnvironment(environment),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF03045E) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF03045E) : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Text(
          environment.getString(context),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
