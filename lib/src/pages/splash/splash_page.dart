import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/gen/assets.gen.dart';
import 'package:water_mind/src/core/routing/app_router.dart';

/// Trang splash hiển thị khi ứng dụng khởi động
@RoutePage()
class SplashPage extends ConsumerStatefulWidget {
  /// Constructor
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (context.mounted) {
        context.router.replace(const MainNavigationRoute());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFF7), 
              Color(0xFF77C6ED),
            ],
          ),
        ),
        child:  Center(
          child: Assets.images.app.iconSplash.svg(height: 200),
        ),
      ),
    );
  }
}
