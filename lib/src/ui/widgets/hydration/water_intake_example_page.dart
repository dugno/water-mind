import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/core/utils/weather/weather_icon_mapper.dart';
import 'package:water_mind/src/pages/getting_started/models/user_onboarding_model.dart';
import 'water_intake_display.dart';

/// Example page to demonstrate water intake calculation
@RoutePage()
class WaterIntakeExamplePage extends ConsumerStatefulWidget {
  /// Constructor
  const WaterIntakeExamplePage({super.key});

  @override
  ConsumerState<WaterIntakeExamplePage> createState() =>
      _WaterIntakeExamplePageState();
}

class _WaterIntakeExamplePageState
    extends ConsumerState<WaterIntakeExamplePage> {
  // Default user model
  UserOnboardingModel _userModel = const UserOnboardingModel(
    gender: Gender.male,
    weight: 70.0,
    height: 175.0,
    measureUnit: MeasureUnit.metric,
    dateOfBirth: null,
    activityLevel: ActivityLevel.moderatelyActive,
    livingEnvironment: LivingEnvironment.moderate,
    wakeUpTime: null,
    bedTime: null,
  );

  // UI state
  Gender _selectedGender = Gender.male;
  double _weight = 70.0;
  ActivityLevel _activityLevel = ActivityLevel.moderatelyActive;
  LivingEnvironment _livingEnvironment = LivingEnvironment.moderate;
  WeatherCondition _weatherCondition = WeatherCondition.cloudy;
  MeasureUnit _measureUnit = MeasureUnit.metric;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.dailyWaterIntake),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Water intake display
            WaterIntakeDisplay(userModel: _userModel),

            const SizedBox(height: 24),

            // Current weather widget (commented out because it requires an API key)
            // CurrentWeatherWidget(
            //   location: 'London',
            //   userModel: _userModel,
            // ),

            const SizedBox(height: 24),

            // Parameters adjustment
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Adjust Parameters',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    // Gender selection
                    _buildGenderSelection(),
                    const SizedBox(height: 16),

                    // Weight slider
                    _buildWeightSlider(),
                    const SizedBox(height: 16),

                    // Activity level selection
                    _buildActivityLevelSelection(),
                    const SizedBox(height: 16),

                    // Living environment selection
                    _buildLivingEnvironmentSelection(),
                    const SizedBox(height: 16),

                    // Weather condition selection
                    _buildWeatherConditionSelection(),
                    const SizedBox(height: 16),

                    // Measurement unit selection
                    _buildMeasurementUnitSelection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.gender,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: Gender.values.map((gender) {
            return ChoiceChip(
              label: Text(gender.getString(context)),
              selected: _selectedGender == gender,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedGender = gender;
                    _updateUserModel();
                  });
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWeightSlider() {
    final String weightUnit = _measureUnit == MeasureUnit.metric ? 'kg' : 'lbs';
    final double minWeight = _measureUnit == MeasureUnit.metric ? 40.0 : 88.0;
    final double maxWeight = _measureUnit == MeasureUnit.metric ? 150.0 : 330.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${context.l10n.weight} (${_weight.toStringAsFixed(1)} $weightUnit)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Slider(
          value: _weight,
          min: minWeight,
          max: maxWeight,
          divisions: 220,
          label: '${_weight.toStringAsFixed(1)} $weightUnit',
          onChanged: (value) {
            setState(() {
              _weight = value;
              _updateUserModel();
            });
          },
        ),
      ],
    );
  }

  Widget _buildActivityLevelSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.activityLevel,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<ActivityLevel>(
          value: _activityLevel,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          items: ActivityLevel.values.map((level) {
            return DropdownMenuItem(
              value: level,
              child: Text(level.getString(context)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _activityLevel = value;
                _updateUserModel();
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildLivingEnvironmentSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.livingEnvironment,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<LivingEnvironment>(
          value: _livingEnvironment,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          items: LivingEnvironment.values.map((env) {
            return DropdownMenuItem(
              value: env,
              child: Text(env.getString(context)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _livingEnvironment = value;
                _updateUserModel();
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildWeatherConditionSelection() {
    // Define common weather conditions for the UI
    final List<WeatherCondition> commonWeatherConditions = [
      WeatherCondition.sunny,
      WeatherCondition.partlyCloudy,
      WeatherCondition.cloudy,
      WeatherCondition.overcast,
      WeatherCondition.lightRain,
      WeatherCondition.moderateRain,
      WeatherCondition.heavyRain,
      WeatherCondition.lightSnow,
      WeatherCondition.moderateSnow,
      WeatherCondition.heavySnow,
      WeatherCondition.hot,
      WeatherCondition.humid,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weather Condition',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: commonWeatherConditions.map((weather) {
            return ChoiceChip(
              avatar: SizedBox(
                width: 18,
                height: 18,
                child: WeatherIconMapper.getWeatherIconFromCondition(
                  weather,
                  isDay: true,
                ).svg(
                  fit: BoxFit.contain,
                ),
              ),
              label: Text(weather.getString(context)),
              selected: _weatherCondition == weather,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _weatherCondition = weather;
                    _updateUserModel();
                  });
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        ExpansionTile(
          title: const Text('More Weather Conditions'),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: WeatherCondition.values
                  .where((w) => !commonWeatherConditions.contains(w))
                  .map((weather) {
                return ChoiceChip(
                  avatar: SizedBox(
                    width: 18,
                    height: 18,
                    child: WeatherIconMapper.getWeatherIconFromCondition(
                      weather,
                      isDay: true,
                    ).svg(
                      fit: BoxFit.contain,
                    ),
                  ),
                  label: Text(weather.getString(context)),
                  selected: _weatherCondition == weather,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _weatherCondition = weather;
                        _updateUserModel();
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMeasurementUnitSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Measurement Unit',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<MeasureUnit>(
                title: Text(context.l10n.metric),
                value: MeasureUnit.metric,
                groupValue: _measureUnit,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      // Convert weight if changing units
                      if (_measureUnit == MeasureUnit.imperial) {
                        _weight = _weight / 2.20462; // lbs to kg
                      }
                      _measureUnit = value;
                      _updateUserModel();
                    });
                  }
                },
              ),
            ),
            Expanded(
              child: RadioListTile<MeasureUnit>(
                title: Text(context.l10n.imperial),
                value: MeasureUnit.imperial,
                groupValue: _measureUnit,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      // Convert weight if changing units
                      if (_measureUnit == MeasureUnit.metric) {
                        _weight = _weight * 2.20462; // kg to lbs
                      }
                      _measureUnit = value;
                      _updateUserModel();
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _updateUserModel() {
    setState(() {
      _userModel = UserOnboardingModel(
        gender: _selectedGender,
        weight: _weight,
        height: 175.0, // Fixed height for simplicity
        measureUnit: _measureUnit,
        dateOfBirth: DateTime(1990, 1, 1), // Fixed date for simplicity
        activityLevel: _activityLevel,
        livingEnvironment: _livingEnvironment,
        weatherCondition: _weatherCondition,
        wakeUpTime: const TimeOfDay(hour: 7, minute: 0), // Fixed wake up time
        bedTime: const TimeOfDay(hour: 23, minute: 0), // Fixed bed time
      );
    });
  }
}
