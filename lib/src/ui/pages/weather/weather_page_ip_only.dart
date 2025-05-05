import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/network/providers/weather_providers.dart';
import 'package:water_mind/src/ui/widgets/weather/weather_widget_v2.dart';

/// A page that displays weather information using IP-based location
class WeatherPage extends ConsumerStatefulWidget {
  /// Constructor for WeatherPage
  const WeatherPage({super.key});

  @override
  ConsumerState<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends ConsumerState<WeatherPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshWeather,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // IP-based location indicator
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(
                  Icons.public,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Using IP-based location',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          
          // Loading indicator
          if (_isLoading)
            const LinearProgressIndicator(),
          
          // Weather display
          const Expanded(
            child: WeatherWidgetV2(),
          ),
        ],
      ),
    );
  }

  void _refreshWeather() {
    setState(() {
      _isLoading = true;
    });
    
    // Force a refresh of the weather data
    ref.invalidate(weatherAndForecastProvider(forceRefresh: true));
    
    setState(() {
      _isLoading = false;
    });
  }
}
