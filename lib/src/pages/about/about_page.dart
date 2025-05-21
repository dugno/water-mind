import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/gen/assets.gen.dart';

/// About App page for the app
@RoutePage()
class AboutPage extends ConsumerStatefulWidget {
  /// Constructor
  const AboutPage({super.key});

  @override
  ConsumerState<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends ConsumerState<AboutPage> with HapticFeedbackMixin {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = packageInfo;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColor.secondaryColor,
        elevation: 0,
        title: Text(
          context.l10n.aboutApp,
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
              _buildAboutAppContent(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutAppContent(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // App Logo
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Assets.images.app.iconSplash.svg(height: 120),
          ),

          // App Name and Version
          Text(
            'Water Mind',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _packageInfo != null
                ? context.l10n.aboutAppVersion(
                    _packageInfo!.version,
                    _packageInfo!.buildNumber
                  )
                : context.l10n.aboutAppLoadingVersion,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 32),

          // App Description
          _buildInfoSection(
            context.l10n.aboutAppDescriptionTitle,
            context.l10n.aboutAppDescriptionContent,
          ),

          _buildInfoSection(
            context.l10n.aboutAppFeaturesTitle,
            context.l10n.aboutAppFeaturesContent,
          ),

          _buildInfoSection(
            context.l10n.aboutAppDeveloperTitle,
            context.l10n.aboutAppDeveloperContent,
          ),

          _buildInfoSection(
            context.l10n.aboutAppContactTitle,
            context.l10n.aboutAppContactContent,
          ),

          _buildInfoSection(
            context.l10n.aboutAppAcknowledgmentsTitle,
            context.l10n.aboutAppAcknowledgmentsContent,
          ),

          const SizedBox(height: 16),
          Text(
            context.l10n.aboutAppCopyright(DateTime.now().year),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
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
