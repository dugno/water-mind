import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';

/// Privacy Policy page for the app
@RoutePage()
class PrivacyPolicyPage extends ConsumerWidget with HapticFeedbackMixin {
   PrivacyPolicyPage({super.key});



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColor.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColor.secondaryColor,
        elevation: 0,
        title: Text(
          context.l10n.privacyPolicy,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            haptic(HapticFeedbackType.selection);
            context.router.pop();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPrivacyPolicyContent(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicyContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.primaryColor.withAlpha(204), // 0.8 opacity
            AppColor.secondaryColor.withAlpha(179), // 0.7 opacity
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withAlpha(77), // 0.3 opacity
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.privacyPolicyTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.privacyPolicyLastUpdated,
            style: const TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          _buildPolicySection(
            context.l10n.privacyPolicyIntroTitle,
            context.l10n.privacyPolicyIntroContent,
          ),
          _buildPolicySection(
            context.l10n.privacyPolicyCollectTitle,
            context.l10n.privacyPolicyCollectContent,
          ),
          _buildPolicySection(
            context.l10n.privacyPolicyUseTitle,
            context.l10n.privacyPolicyUseContent,
          ),
          _buildPolicySection(
            context.l10n.privacyPolicyStorageTitle,
            context.l10n.privacyPolicyStorageContent,
          ),
          _buildPolicySection(
            context.l10n.privacyPolicyWeatherTitle,
            context.l10n.privacyPolicyWeatherContent,
          ),
          _buildPolicySection(
            context.l10n.privacyPolicyFeedbackTitle,
            context.l10n.privacyPolicyFeedbackContent,
          ),
          _buildPolicySection(
            context.l10n.privacyPolicyRightsTitle,
            context.l10n.privacyPolicyRightsContent,
          ),
          _buildPolicySection(
            context.l10n.privacyPolicyChangesTitle,
            context.l10n.privacyPolicyChangesContent,
          ),
          _buildPolicySection(
            context.l10n.privacyPolicyContactTitle,
            context.l10n.privacyPolicyContactContent,
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
