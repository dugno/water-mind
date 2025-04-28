# Core Services

This directory contains core services used throughout the application, designed following SOLID, DRY, and other best design principles.

## Current Services

### Notifications

A professional implementation of a notification service using the `awesome_notifications` package. See the [notifications README](notifications/README.md) for detailed documentation.

## Design Principles

The services in this directory follow these design principles:

1. **Single Responsibility Principle (SRP)**: Each class has a single responsibility.
2. **Open/Closed Principle (OCP)**: Code is open for extension but closed for modification.
3. **Liskov Substitution Principle (LSP)**: Implementations can be substituted for their interfaces.
4. **Interface Segregation Principle (ISP)**: Clients only depend on methods they use.
5. **Dependency Inversion Principle (DIP)**: High-level modules depend on abstractions.
6. **DRY (Don't Repeat Yourself)**: Code reuse is maximized.

## Directory Structure

```
lib/core/services/
├── README.md
├── notifications/
│   ├── README.md
│   ├── awesome_notification_service.dart
│   ├── notification_channel_model.dart
│   ├── notification_factory.dart
│   ├── notification_handler_widget.dart
│   ├── notification_manager.dart
│   ├── notification_model.dart
│   ├── notification_service_interface.dart
│   ├── notification_service_provider.dart
│   └── notifications.dart (barrel file)
└── ... (other services)
```

## Adding New Services

When adding new services to this directory, follow these guidelines:

1. Create a new subdirectory for the service
2. Define interfaces before implementations
3. Follow SOLID principles
4. Include a README.md with documentation
5. Create a barrel file for easy importing
6. Write unit tests for the service
