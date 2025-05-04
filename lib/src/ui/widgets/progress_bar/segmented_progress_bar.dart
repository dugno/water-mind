import 'package:flutter/material.dart';
import 'package:water_mind/src/common/responsive/responsive.dart';
import 'progress_bar_theme.dart';

/// A segmented progress bar that displays progress as a series of segments
///
/// This progress bar is designed to show progress based on steps completed
/// rather than a percentage. Each segment represents a step, and completed
/// steps are highlighted with a different color.
class SegmentedProgressBar extends StatefulWidget {
  /// The number of completed steps
  final int completedSteps;

  /// The total number of steps
  final int totalSteps;

  /// Custom theme for the progress bar
  ///
  /// If not provided, the theme will be derived from the current context
  final ProgressBarTheme? theme;

  /// Label to display above the progress bar
  ///
  /// If null, a default label in the format "X/Y steps" will be shown
  final String? label;

  /// Whether to show the label
  final bool showLabel;

  /// Text style for the label
  final TextStyle? labelStyle;

  /// Callback when a segment is tapped
  ///
  /// The index of the tapped segment is provided (0-based)
  final void Function(int)? onSegmentTap;

  /// Creates a segmented progress bar
  ///
  /// [completedSteps] must be less than or equal to [totalSteps]
  /// [totalSteps] must be greater than 0
  const SegmentedProgressBar({
    super.key,
    required this.completedSteps,
    required this.totalSteps,
    this.theme,
    this.label,
    this.showLabel = true,
    this.labelStyle,
    this.onSegmentTap,
  }) : assert(completedSteps <= totalSteps, 'Completed steps cannot exceed total steps'),
       assert(totalSteps > 0, 'Total steps must be greater than 0');

  @override
  State<SegmentedProgressBar> createState() => _SegmentedProgressBarState();
}

class _SegmentedProgressBarState extends State<SegmentedProgressBar> with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Delay initialization until the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAnimations();
    });
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  void _initAnimations() {
    if (!mounted) return;

    final theme = widget.theme ?? ProgressBarTheme.fromContext(context);
    _pulseController = AnimationController(
      vsync: this,
      duration: theme.pulsingDuration,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController!,
        curve: Curves.easeInOut,
      ),
    );

    // Force a rebuild to use the animations
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? ProgressBarTheme.fromContext(context);
    final defaultLabelStyle = TextStyle(
      fontSize: 12,
      color: theme.labelColor,
      fontWeight: FontWeight.w500,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (widget.showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.label ?? '${widget.completedSteps}/${widget.totalSteps} steps',
              style: widget.labelStyle ?? defaultLabelStyle,
            ),
          ),

        // Progress bar
        Center(
          child: ResponsiveContainer(
            xsWidth: 90, // 90% width on extra small screens
            smWidth: 85, // 85% width on small screens
            mdWidth: 80, // 80% width on medium screens
            lgWidth: 70, // 70% width on large screens
            xlWidth: 60, // 60% width on extra large screens
            xxlWidth: 50, // 50% width on extra extra large screens
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.totalSteps,
                (index) => _buildSegment(index, theme),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSegment(int index, ProgressBarTheme theme) {
    final isCompleted = index < widget.completedSteps;
    final isLastCompleted = index == widget.completedSteps - 1;
    final showPulse = isLastCompleted && theme.showPulsingEffect && widget.completedSteps > 0;

    return Expanded(
      child: GestureDetector(
        onTap: widget.onSegmentTap != null ? () => widget.onSegmentTap!(index) : null,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: theme.segmentSpacing / 2),
          child: showPulse
              ? _buildPulsingSegment(isCompleted, theme)
              : _buildStaticSegment(isCompleted, theme),
        ),
      ),
    );
  }

  Widget _buildStaticSegment(bool isCompleted, ProgressBarTheme theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: theme.segmentHeight,
      decoration: BoxDecoration(
        color: isCompleted ? theme.completedSegmentColor : theme.incompleteSegmentColor,
        borderRadius: theme.segmentBorderRadius,
      ),
    );
  }

  Widget _buildPulsingSegment(bool isCompleted, ProgressBarTheme theme) {
    // If animations aren't initialized yet, show static segment instead
    if (_pulseAnimation == null || _pulseController == null) {
      return _buildStaticSegment(isCompleted, theme);
    }

    return AnimatedBuilder(
      animation: _pulseAnimation!,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation!.value,
          child: Container(
            height: theme.segmentHeight,
            decoration: BoxDecoration(
              color: theme.completedSegmentColor,
              borderRadius: theme.segmentBorderRadius,
            ),
          ),
        );
      },
    );
  }
}
