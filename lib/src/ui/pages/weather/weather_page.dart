import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/network/providers/weather_providers.dart';
import 'package:water_mind/src/ui/widgets/weather/weather_widget_v2.dart';

/// A page that displays weather information
class WeatherPage extends ConsumerStatefulWidget {
  /// Constructor for WeatherPage
  const WeatherPage({super.key});

  @override
  ConsumerState<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends ConsumerState<WeatherPage> {
  final TextEditingController _locationController = TextEditingController();
  String? _currentLocation;
  bool _isLoading = false;
  bool _isUsingIpLookup = true;

  @override
  void initState() {
    super.initState();
    // Start with IP lookup by default
    _useIpLookup();
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

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
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      hintText: 'Enter location (city, zip, coordinates)',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _searchLocation,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _searchLocation(_locationController.text),
                  child: const Text('Search'),
                ),
              ],
            ),
          ),

          // Current location indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(
                  _isUsingIpLookup ? Icons.public : Icons.location_on,
                  size: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  _isUsingIpLookup
                      ? 'Using IP-based location'
                      : 'Location: ${_currentLocation ?? "Unknown"}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Loading indicator
          if (_isLoading)
            const LinearProgressIndicator(),

          // Weather display
          Expanded(
            child: const WeatherWidgetV2() //  parameters means it will use IP lookup
      
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _useIpLookup,
        tooltip: 'Use IP-based location',
        child: const Icon(Icons.public),
      ),
    );
  }

  void _searchLocation(String location) {
    if (location.isEmpty) return;

    setState(() {
      _isLoading = true;
      _currentLocation = location;
      _isUsingIpLookup = false;
    });


    setState(() {
      _isLoading = false;
    });
  }

  void _useIpLookup() {
    setState(() {
      _isLoading = true;
      _isUsingIpLookup = true;
      _locationController.text = '';
    });

    // Invalidate the cache to force a refresh with IP-based location
    ref.invalidate(weatherAndForecastProvider());

    setState(() {
      _isLoading = false;
    });
  }

  void _refreshWeather() {
    setState(() {
      _isLoading = true;
    });

    // Force a refresh of the weather data
    if (_isUsingIpLookup) {
      ref.invalidate(weatherAndForecastProvider(forceRefresh: true));
    } else {
      ref.invalidate(weatherAndForecastProvider(
        forceRefresh: true,
      ));
    }

    setState(() {
      _isLoading = false;
    });
  }
}
