/// Calendar module for UI Kit
///
/// This module provides a customizable calendar widget with support for
/// multiple languages and configurable first day of the week.
///
/// Features:
/// - Month and week views with horizontal scrolling
/// - Customizable appearance
/// - Internationalization
/// - Configurable first day of week (Monday or Sunday)
library calendar;

// Controllers
export 'controllers/calendar_controller.dart';

// Models
export 'models/calendar_day.dart';

export 'models/calendar_config.dart';

// Utils
export 'utils/date_utils.dart';

// Widgets
export 'widgets/calendar_view.dart';
export 'widgets/day_view.dart';
export 'widgets/month_view.dart';
export 'widgets/week_view.dart';
export 'widgets/year_view.dart';
