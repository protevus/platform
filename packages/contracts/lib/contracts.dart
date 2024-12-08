/// Support contracts library
///
/// This library provides a set of interfaces that define the core contracts
/// used throughout the framework. These contracts establish a standard way
/// of implementing common functionality like array conversion, JSON serialization,
/// HTML rendering, and HTTP response handling.
library contracts;

// Auth contracts
export 'src/auth/auth_factory.dart';
export 'src/auth/authenticatable.dart';
export 'src/auth/can_reset_password.dart';
export 'src/auth/guard.dart';
export 'src/auth/must_verify_email.dart';
export 'src/auth/password_broker.dart';
export 'src/auth/password_broker_factory.dart';
export 'src/auth/stateful_guard.dart';
export 'src/auth/supports_basic_auth.dart';
export 'src/auth/user_provider.dart';

// Auth Access contracts
export 'src/auth/access/authorizable.dart';
export 'src/auth/access/authorization_exception.dart';
export 'src/auth/access/gate.dart';

// Auth Middleware contracts
export 'src/auth/middleware/authenticates_requests.dart';

// Broadcasting contracts
export 'src/broadcasting/broadcast_exception.dart';
export 'src/broadcasting/broadcast_factory.dart';
export 'src/broadcasting/broadcaster.dart';
export 'src/broadcasting/has_broadcast_channel.dart';
export 'src/broadcasting/should_be_unique.dart' show BroadcastShouldBeUnique;
export 'src/broadcasting/should_broadcast.dart';
export 'src/broadcasting/should_broadcast_now.dart';

// Bus contracts
export 'src/bus/dispatcher.dart' show BusDispatcher;
export 'src/bus/queueing_dispatcher.dart';

// Cache contracts
export 'src/cache/cache_factory.dart';
export 'src/cache/lock.dart';
export 'src/cache/lock_provider.dart';
export 'src/cache/lock_timeout_exception.dart' show CacheLockTimeoutException;
export 'src/cache/repository.dart';
export 'src/cache/store.dart';

// Config contracts
export 'src/config/repository.dart';

// Console contracts
export 'src/console/application.dart';
export 'src/console/isolatable.dart';
export 'src/console/kernel.dart';
export 'src/console/prompts_for_missing_input.dart';

// Container contracts
export 'src/container/binding_resolution_exception.dart';
export 'src/container/circular_dependency_exception.dart';
export 'src/container/container.dart';
export 'src/container/contextual_attribute.dart';
export "src/container/contextual_binding_builder.dart";

// Cookie contracts
export 'src/cookie/cookie_factory.dart' show CookieFactory;
export 'src/cookie/queueing_factory.dart';

// Database contracts
export 'src/database/model_identifier.dart';
export 'src/database/query/builder.dart';
export 'src/database/query/expression.dart';
export 'src/database/query/condition_expression.dart';

// Database Eloquent contracts
export 'src/database/eloquent/builder.dart';
export 'src/database/eloquent/castable.dart';
export 'src/database/eloquent/casts_attributes.dart';
export 'src/database/eloquent/casts_inbound_attributes.dart';
export 'src/database/eloquent/deviates_castable_attributes.dart';
export 'src/database/eloquent/serializes_castable_attributes.dart';
export 'src/database/eloquent/supports_partial_relations.dart';

// Database Events contracts
export 'src/database/events/migration_event.dart';

// Debug contracts
export 'src/debug/exception_handler.dart';

// Encryption contracts
export 'src/encryption/decrypt_exception.dart';
export 'src/encryption/encrypt_exception.dart';
export 'src/encryption/encrypter.dart';
export 'src/encryption/string_encrypter.dart';

// Events contracts
export 'src/events/dispatcher.dart' show EventDispatcher;
export 'src/events/should_dispatch_after_commit.dart';
export 'src/events/should_handle_events_after_commit.dart';

// Filesystem contracts
export 'src/filesystem/cloud.dart';
export 'src/filesystem/file_not_found_exception.dart';
export 'src/filesystem/filesystem_factory.dart' show FilesystemFactory;
export 'src/filesystem/filesystem.dart';
export 'src/filesystem/lock_timeout_exception.dart'
    show FilesystemLockTimeoutException;

// Foundation contracts
export 'src/foundation/application.dart';
export 'src/foundation/caches_configuration.dart';
export 'src/foundation/caches_routes.dart';
export 'src/foundation/exception_renderer.dart';
export 'src/foundation/maintenance_mode.dart';

// Hashing contracts
export 'src/hashing/hasher.dart';

// HTTP contracts
export 'src/http/kernel.dart';
export 'src/http/request.dart';
export 'src/http/response.dart';

// Mail contracts
export 'src/mail/attachable.dart';
export 'src/mail/mail_factory.dart' show MailFactory;
export 'src/mail/mailable.dart';
export 'src/mail/mail_queue.dart';
export 'src/mail/mailer.dart';

// Notifications contracts
export 'src/notifications/dispatcher.dart' show NotificationDispatcher;
export 'src/notifications/factory.dart';

// Pagination contracts
export 'src/pagination/cursor_paginator.dart';
export 'src/pagination/length_aware_paginator.dart';
export 'src/pagination/paginator.dart';

// Pipeline contracts
export 'src/pipeline/hub.dart';
export 'src/pipeline/pipeline.dart';

// Process contracts
export 'src/process/invoked_process.dart';
export 'src/process/process_result.dart';

// Queue contracts
export 'src/queue/clearable_queue.dart';
export 'src/queue/entity_not_found_exception.dart';
export 'src/queue/entity_resolver.dart';
export 'src/queue/queue_factory.dart' show QueueFactory;
export 'src/queue/job.dart';
export 'src/queue/monitor.dart';
export 'src/queue/queue.dart';
export 'src/queue/queueable_collection.dart';
export 'src/queue/queueable_entity.dart';
export 'src/queue/should_be_encrypted.dart';
export 'src/queue/should_be_unique.dart' show QueueShouldBeUnique;
export 'src/queue/should_be_unique_until_processing.dart';
export 'src/queue/should_queue.dart';
export 'src/queue/should_queue_after_commit.dart';

// Redis contracts
export 'src/redis/connection.dart';
export 'src/redis/connector.dart';
export 'src/redis/redis_factory.dart' show RedisFactory;
export 'src/redis/limiter_timeout_exception.dart';

// Reflection contracts
export 'src/reflection/reflector_contract.dart';

// Routing contracts
export 'src/routing/binding_registrar.dart';
export 'src/routing/registrar.dart';
export 'src/routing/response_factory.dart';
export 'src/routing/url_generator.dart';
export 'src/routing/url_routable.dart';

// Session contracts
export 'src/session/session.dart';
export 'src/session/middleware/authenticates_sessions.dart';

// Support contracts
export 'src/support/arrayable.dart';
export 'src/support/can_be_escaped_when_cast_to_string.dart';
export 'src/support/deferrable_provider.dart';
export 'src/support/deferring_displayable_value.dart';
export 'src/support/htmlable.dart';
export 'src/support/jsonable.dart';
export 'src/support/message_bag.dart';
export 'src/support/message_provider.dart';
export 'src/support/renderable.dart';
export 'src/support/responsable.dart';
export 'src/support/validated_data.dart';

// Translation contracts
export 'src/translation/has_locale_preference.dart';
export 'src/translation/loader.dart';
export 'src/translation/translator.dart';

// Validation contracts
export 'src/validation/data_aware_rule.dart';
export 'src/validation/validation_factory.dart' show ValidationFactory;
export 'src/validation/implicit_rule.dart';
export 'src/validation/invokable_rule.dart';
export 'src/validation/rule.dart';
export 'src/validation/uncompromised_verifier.dart';
export 'src/validation/validates_when_resolved.dart';
export 'src/validation/validation_rule.dart';
export 'src/validation/validator.dart';
export 'src/validation/validator_aware_rule.dart';

// View contracts
export 'src/view/engine.dart';
export 'src/view/view_factory.dart' show ViewFactory;
export 'src/view/view.dart';
export 'src/view/view_compilation_exception.dart';
