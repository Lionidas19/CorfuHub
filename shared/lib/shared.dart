library corfu_shared;

// Enumerations
export 'enums.dart';

// Core
export 'core/services/error_logging_service.dart';
export 'core/utils/connectivity_utils.dart';

// Data sources
export 'data/datasources/supabase_data_source.dart';
export 'data/datasources/cache_data_source.dart';
export 'data/datasources/mock_data_source.dart';

// Data models (DTOs)
export 'data/models/user_model.dart';
export 'data/models/place_model.dart';
export 'data/models/event_model.dart';
export 'data/models/issue_model.dart';
export 'data/models/claim_model.dart';
export 'data/models/job_model.dart';
export 'data/models/check_in_model.dart';
export 'data/models/user_settings_model.dart';

// Repository
export 'data/repositories/app_repository_impl.dart';
export 'domain/repositories/app_repository.dart';

// Domain entities
export 'domain/entities/user_entity.dart';
export 'domain/entities/place_entity.dart';
export 'domain/entities/event_entity.dart';
export 'domain/entities/issue_entity.dart';
export 'domain/entities/claim_entity.dart';
export 'domain/entities/job_entity.dart';
export 'domain/entities/check_in_entity.dart';
export 'domain/entities/user_settings_entity.dart';

// UI helpers
export 'env_banner.dart';
