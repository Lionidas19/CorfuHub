/// CorfuHub — shared enumerations
library;

// ---------------------------------------------------------------------------
// Environment
// ---------------------------------------------------------------------------
enum EnvironmentEnum {
  local,
  staging,
  production;

  static EnvironmentEnum fromValue(dynamic value) {
    if (value is EnvironmentEnum) return value;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'local':
          return EnvironmentEnum.local;
        case 'production':
          return EnvironmentEnum.production;
        default:
          return EnvironmentEnum.staging;
      }
    }
    return EnvironmentEnum.staging;
  }

  bool get isProduction => this == EnvironmentEnum.production;
}

// ---------------------------------------------------------------------------
// User role  (mirrors DB enum in public.users.role)
// ---------------------------------------------------------------------------
enum RoleEnum {
  resident,
  owner,
  admin;

  static RoleEnum fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'owner':
        return RoleEnum.owner;
      case 'admin':
        return RoleEnum.admin;
      default:
        return RoleEnum.resident;
    }
  }
}

// ---------------------------------------------------------------------------
// Connectivity mode (chosen per project in RPD)
// ---------------------------------------------------------------------------
enum ConnectivityMode {
  onlineFirst,
  offlineFirstStage1,
  offlineFirstStage2,
}

// ---------------------------------------------------------------------------
// Issue geometry type (maps to Supabase geometry column)
// ---------------------------------------------------------------------------
enum GeometryType {
  point,
  polygon,
  polyline,
}

// ---------------------------------------------------------------------------
// Claim status
// ---------------------------------------------------------------------------
enum ClaimStatus {
  pending,
  approved,
  rejected;

  static ClaimStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'approved':
        return ClaimStatus.approved;
      case 'rejected':
        return ClaimStatus.rejected;
      default:
        return ClaimStatus.pending;
    }
  }
}

// ---------------------------------------------------------------------------
// Audit action  (mirrors public.audit_action DB enum)
// ---------------------------------------------------------------------------
enum AuditAction {
  insert,
  edit,
  delete;

  String get dbValue => name;
}

// ---------------------------------------------------------------------------
// Severity (mirrors error_logs.severity)
// ---------------------------------------------------------------------------
enum LogSeverity {
  debug,
  info,
  warn,
  error,
  fatal;

  String get dbValue => name;
}
