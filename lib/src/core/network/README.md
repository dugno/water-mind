# API Handling with Dio

This module provides a professional approach to handling API requests using the Dio HTTP client library. It follows SOLID principles, DRY (Don't Repeat Yourself), and other best practices.

## Structure

The API handling structure is organized as follows:

```
lib/src/core/network/
├── config/
│   └── api_config.dart           # API configuration (base URL, timeouts, etc.)
├── interceptors/
│   ├── auth_interceptor.dart     # Authentication interceptor
│   └── error_interceptor.dart    # Error handling interceptor
├── models/
│   ├── api_error.dart            # Error model
│   ├── api_response.dart         # Generic API response model
│   ├── network_result.dart       # Result wrapper (success/error/loading)
│   └── paginated_response.dart   # Paginated response model
├── providers/
│   ├── network_providers.dart    # Providers for network components
│   └── repository_providers.dart # Providers for repositories
├── repositories/
│   ├── base_repository.dart      # Base repository interface and implementation
│   ├── weather_repository.dart   # Weather-specific repository
│   └── hydration_repository.dart # Hydration-specific repository
├── services/
│   └── connectivity_service.dart # Internet connectivity service
└── dio_client.dart               # Main Dio client implementation
```

## Key Components

### DioClient

The `DioClient` class is the core component that wraps the Dio HTTP client. It provides methods for making HTTP requests (GET, POST, PUT, PATCH, DELETE) and handles error responses.

### Repositories

Repositories are responsible for making API calls for specific domains. They use the `DioClient` to make requests and transform the responses into domain models.

- `BaseRepository`: Defines the common interface for all repositories
- `WeatherRepository`: Handles weather-related API calls
- `HydrationRepository`: Handles hydration-related API calls

### Models

- `NetworkResult<T>`: A sealed class that represents the result of a network operation (success, error, or loading)
- `ApiError`: Represents an error from the API
- `ApiResponse<T>`: A generic model for API responses
- `PaginatedResponse<T>`: A model for paginated API responses

### Services

- `ConnectivityService`: Checks for internet connectivity

### Interceptors

- `ErrorInterceptor`: Handles error responses and transforms them into `ApiError` objects
- `AuthInterceptor`: Adds authentication headers to requests (if needed)

## Usage Example

```dart
// Get an instance of the repository
final weatherRepository = ref.watch(weatherRepositoryProvider);

// Make an API call
final result = await weatherRepository.getCurrentWeather(
  latitude: 37.7749,
  longitude: -122.4194,
);

// Handle the result
result.when(
  success: (data) {
    // Handle successful response
    print('Temperature: ${data.temperature}°C');
  },
  error: (error) {
    // Handle error
    print('Error: ${error.message}');
  },
  loading: () {
    // Show loading indicator
    print('Loading...');
  },
);
```

## Code Generation

This module uses code generation for:
- Freezed models
- JSON serialization
- Riverpod providers

To generate the required files, run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## SOLID Principles

- **Single Responsibility**: Each class has a single responsibility
- **Open/Closed**: Classes are open for extension but closed for modification
- **Liskov Substitution**: Implementations can be substituted for their interfaces
- **Interface Segregation**: Clients only depend on the methods they use
- **Dependency Inversion**: High-level modules depend on abstractions, not concrete implementations
