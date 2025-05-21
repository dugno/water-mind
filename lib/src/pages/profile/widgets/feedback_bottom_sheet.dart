import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/models/feedback_model.dart';
import 'package:water_mind/src/core/services/feedback/feedback_service_provider.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/ui/widgets/bottom_sheets/base_bottom_sheet.dart';

/// Bottom sheet for sending feedback
class FeedbackBottomSheet extends ConsumerStatefulWidget {
  /// Constructor
  const FeedbackBottomSheet({super.key});

  /// Show the feedback bottom sheet
  static Future<void> show({
    required BuildContext context,
  }) {
    return BaseBottomSheet.show(
      context: context,
      useGradientBackground: true,
      maxHeightFactor: 0.7,
      child: const FeedbackBottomSheet(),
    );
  }

  @override
  ConsumerState<FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends ConsumerState<FeedbackBottomSheet> with HapticFeedbackMixin {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _isSuccess = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) {
      haptic(HapticFeedbackType.error);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final feedbackService = ref.read(feedbackServiceProvider);

      final feedback = FeedbackModel(
        message: _feedbackController.text.trim(),
      );

      final success = await feedbackService.sendFeedback(feedback);

      if (success) {
        haptic(HapticFeedbackType.success);
        setState(() {
          _isSuccess = true;
          _isSubmitting = false;
        });

        // Close the bottom sheet after a delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      } else {
        throw Exception('Failed to send feedback');
      }
    } catch (e) {
      haptic(HapticFeedbackType.error);

      // Hiển thị thông báo lỗi thân thiện hơn
      String errorMessage;
      if (e.toString().contains('permission-denied') ||
          e.toString().contains('permission')) {
        errorMessage = 'Không có quyền gửi phản hồi. Vui lòng kiểm tra cấu hình Firebase.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Lỗi kết nối mạng. Vui lòng thử lại sau.';
      } else {
        errorMessage = 'Không thể gửi phản hồi: ${e.toString()}';
      }

      setState(() {
        _isSubmitting = false;
        _errorMessage = errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              context.l10n.sendFeedback,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          if (_isSuccess)
            _buildSuccessMessage()
          else
            _buildFeedbackForm(),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(51), // 0.2 * 255 = 51
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.feedbackThankYou,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Feedback input field
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(26), // 0.1 * 255 = 25.5 ≈ 26
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: _feedbackController,
            maxLines: 5,
            maxLength: 500,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: context.l10n.enterFeedbackHint,
              hintStyle: TextStyle(color: Colors.white.withAlpha(179)), // 0.7 * 255 = 178.5 ≈ 179
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
              counterStyle: const TextStyle(color: Colors.white70),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return context.l10n.feedbackValidationEmpty;
              }
              if (value.trim().length < 10) {
                return context.l10n.feedbackValidationTooShort;
              }
              return null;
            },
          ),
        ),

        // Error message
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),

        const SizedBox(height: 16),

        // Submit button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitFeedback,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.thirdColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: AppColor.thirdColor.withAlpha(128), // 0.5 * 255 = 127.5 ≈ 128
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(context.l10n.save),
          ),
        ),
      ],
    );
  }
}
