/// GenieHub shared foundation package.
///
/// Provides theme, auth models, subscription gating, Drift database,
/// cross-module bridge interfaces, and common widgets used by all
/// feature packages.

// ---- Auth ----
export 'src/auth/auth_models.dart';
export 'src/auth/auth_provider.dart';
export 'src/auth/auth_repository.dart';

// ---- Subscription ----
export 'src/subscription/ad_config.dart';
export 'src/subscription/ad_provider.dart';
export 'src/subscription/ad_wrapper.dart';
export 'src/subscription/subscription_models.dart';
export 'src/subscription/subscription_provider.dart';
export 'src/subscription/tier_gate.dart';

// ---- Theme ----
export 'src/theme/app_colors.dart';
export 'src/theme/app_theme.dart';

// ---- Database ----
export 'src/database/app_database.dart';
export 'src/database/database_provider.dart';

// ---- Bridge ----
export 'src/bridge/shopping_bridge.dart';
export 'src/bridge/shopping_bridge_provider.dart';

// ---- Logging ----
export 'src/logging/log_providers.dart';

// ---- Widgets ----
export 'src/widgets/error_widget.dart';
export 'src/widgets/loading_widget.dart';
