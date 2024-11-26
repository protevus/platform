# Container Feature Integration Guide

## Overview

This guide demonstrates how the Container's three major features work together to provide powerful dependency management:
1. Contextual Binding - Different implementations based on context
2. Method Injection - Automatic dependency resolution for methods
3. Tagged Bindings - Grouping related services

## Real World Example: Multi-tenant Reporting System

Let's build a complete multi-tenant reporting system that showcases all three features working together.

### System Requirements

1. Multiple tenants (clients) each need their own:
   - Database connection
   - Storage system
   - Report formatting

2. Various types of reports:
   - Performance reports
   - Financial reports
   - User activity reports

3. Each report needs:
   - Data access
   - Formatting
   - Storage
   - Logging

### Base Interfaces

```dart
/// Base interface for all reports
abstract class Report {
  Future<void> generate();
  Future<void> save();
}

/// Database connection interface
abstract class Database {
  Future<List<Map<String, dynamic>>> query(String sql);
}

/// Storage system interface
abstract class Storage {
  Future<void> save(String path, List<int> data);
  Future<List<int>> load(String path);
}

/// Report formatter interface
abstract class ReportFormatter {
  String format(Map<String, dynamic> data);
}
```

### Tenant-Specific Implementations

```dart
/// Tenant A's database implementation
class TenantADatabase implements Database {
  @override
  Future<List<Map<String, dynamic>>> query(String sql) {
    // Tenant A specific database logic
  }
}

/// Tenant B's database implementation
class TenantBDatabase implements Database {
  @override
  Future<List<Map<String, dynamic>>> query(String sql) {
    // Tenant B specific database logic
  }
}

/// Similar implementations for Storage and Formatter...
```

### Report Implementations

```dart
class PerformanceReport implements Report {
  final Database db;
  final Storage storage;
  final ReportFormatter formatter;
  
  PerformanceReport(this.db, this.storage, this.formatter);
  
  @override
  Future<void> generate() async {
    var data = await db.query('SELECT * FROM performance_metrics');
    var formatted = formatter.format(data);
    await storage.save('performance.report', formatted.codeUnits);
  }
}

// Similar implementations for Financial and UserActivity reports...
```

### Using All Three Features Together

1. First, set up contextual bindings for tenant-specific services:

```dart
void configureTenantA(Container container) {
  // Bind tenant-specific implementations
  container.when(TenantAContext)
          .needs<Database>()
          .give(TenantADatabase());
          
  container.when(TenantAContext)
          .needs<Storage>()
          .give(TenantAStorage());
          
  container.when(TenantAContext)
          .needs<ReportFormatter>()
          .give(TenantAFormatter());
}

void configureTenantB(Container container) {
  // Similar bindings for Tenant B...
}
```

2. Set up tagged bindings for reports:

```dart
void configureReports(Container container) {
  // Bind report implementations
  container.bind<PerformanceReport>(PerformanceReport);
  container.bind<FinancialReport>(FinancialReport);
  container.bind<UserActivityReport>(UserActivityReport);
  
  // Tag them for easy retrieval
  container.tag([
    PerformanceReport,
    FinancialReport,
    UserActivityReport
  ], 'reports');
  
  // Additional tags for categorization
  container.tag([PerformanceReport], 'metrics-reports');
  container.tag([FinancialReport], 'financial-reports');
}
```

3. Create a report manager that uses method injection:

```dart
class ReportManager {
  final Container container;
  
  ReportManager(this.container);
  
  /// Generates all reports for a tenant
  /// Uses method injection for the logger parameter
  Future<void> generateAllReports(
    TenantContext tenant,
    {required DateTime date}
  ) async {
    // Get all tagged reports
    var reports = container.taggedAs<Report>('reports');
    
    // Generate each report using tenant context
    for (var report in reports) {
      await container.call(
        report,
        'generate',
        parameters: {'date': date},
        context: tenant  // Uses contextual binding
      );
    }
  }
  
  /// Generates specific report types
  /// Uses method injection for dependencies
  Future<void> generateMetricsReports(
    TenantContext tenant,
    Logger logger,  // Injected automatically
    MetricsService metrics  // Injected automatically
  ) async {
    var reports = container.taggedAs<Report>('metrics-reports');
    
    for (var report in reports) {
      logger.info('Generating metrics report: ${report.runtimeType}');
      await container.call(report, 'generate', context: tenant);
      metrics.recordReportGeneration(report);
    }
  }
}
```

### Using the Integrated System

```dart
void main() async {
  var container = Container();
  
  // Configure container
  configureTenantA(container);
  configureTenantB(container);
  configureReports(container);
  
  // Create report manager
  var manager = ReportManager(container);
  
  // Generate reports for Tenant A
  await manager.generateAllReports(
    TenantAContext(),
    date: DateTime.now()
  );
  
  // Generate only metrics reports for Tenant B
  await manager.generateMetricsReports(
    TenantBContext()
  );
}
```

## How the Features Work Together

1. **Contextual Binding** ensures:
   - Each tenant gets their own implementations
   - Services are properly scoped
   - No cross-tenant data leakage

2. **Method Injection** provides:
   - Automatic dependency resolution
   - Clean method signatures
   - Flexible parameter handling

3. **Tagged Bindings** enable:
   - Easy service grouping
   - Dynamic service discovery
   - Flexible categorization

## Common Integration Patterns

1. **Service Location with Context**
```dart
// Get tenant-specific service
var db = container.make<Database>(context: tenantContext);

// Get all services of a type for a tenant
var reports = container.taggedAs<Report>('reports')
    .map((r) => container.make(r, context: tenantContext))
    .toList();
```

2. **Method Injection with Tags**
```dart
Future<void> processReports(Logger logger) async {
  // Logger is injected, reports are retrieved by tag
  var reports = container.taggedAs<Report>('reports');
  
  for (var report in reports) {
    logger.info('Processing ${report.runtimeType}');
    await container.call(report, 'process');
  }
}
```

3. **Contextual Services with Tags**
```dart
Future<void> generateTenantReports(TenantContext tenant) async {
  // Get all reports
  var reports = container.taggedAs<Report>('reports');
  
  // Process each with tenant context
  for (var report in reports) {
    await container.call(
      report,
      'generate',
      context: tenant
    );
  }
}
```

## Best Practices

1. **Clear Service Organization**
```dart
// Group related tags
container.tag([Service1, Service2], 'data-services');
container.tag([Service1], 'cacheable-services');

// Group related contexts
container.when(TenantContext)
        .needs<Database>()
        .give(TenantDatabase());
```

2. **Consistent Dependency Resolution**
```dart
// Prefer method injection for flexible dependencies
Future<void> processReport(
  Report report,
  Logger logger,  // Injected
  MetricsService metrics  // Injected
) async {
  // Implementation
}

// Use contextual binding for tenant-specific services
container.when(TenantContext)
        .needs<Storage>()
        .give(TenantStorage());
```

3. **Documentation**
```dart
/// Report processor that handles multiple report types
/// 
/// Uses the following container features:
/// - Tagged bindings for report retrieval ('reports' tag)
/// - Contextual binding for tenant-specific services
/// - Method injection for logging and metrics
class ReportProcessor {
  // Implementation
}
```

## Testing Integrated Features

```dart
void main() {
  group('Integrated Container Features', () {
    late Container container;
    
    setUp(() {
      container = Container();
      
      // Set up test bindings
      configureTenantA(container);
      configureReports(container);
    });
    
    test('should handle tenant-specific tagged services', () {
      var tenantA = TenantAContext();
      
      // Get all reports for tenant
      var reports = container.taggedAs<Report>('reports')
          .map((r) => container.make(r, context: tenantA))
          .toList();
          
      expect(reports, hasLength(3));
      expect(reports.every((r) => r.db is TenantADatabase), isTrue);
    });
    
    test('should inject dependencies with context', () async {
      var processor = ReportProcessor();
      var tenantA = TenantAContext();
      
      await container.call(
        processor,
        'processReports',
        context: tenantA
      );
      
      // Verify correct services were injected
      verify(() => processor.logger is Logger).called(1);
      verify(() => processor.db is TenantADatabase).called(1);
    });
  });
}
```

## Next Steps

1. Implement integration tests
2. Add performance monitoring
3. Add dependency validation
4. Create usage documentation
5. Add debugging tools
6. Create migration guides

Would you like me to create detailed specifications for any of these next steps?
