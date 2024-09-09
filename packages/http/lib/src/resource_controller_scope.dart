/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_auth/auth.dart';
import 'package:protevus_http/http.dart';

/// Allows [ResourceController]s to have different scope for each operation method.
///
/// This type is used as an annotation to an operation method declared in a [ResourceController].
///
/// If an operation method has this annotation, an incoming [Request.authorization] must have sufficient
/// scope for the method to be executed. If not, a 403 Forbidden response is sent. Sufficient scope
/// requires that *every* listed scope is met by the request.
///
/// The typical use case is to require more scope for an editing action than a viewing action. Example:
///
///         class NoteController extends ResourceController {
///           @Scope(['notes.readonly']);
///           @Operation.get('id')
///           Future<Response> getNote(@Bind.path('id') int id) async {
///             ...
///           }
///
///           @Scope(['notes']);
///           @Operation.post()
///           Future<Response> createNote() async {
///             ...
///           }
///         }
///
/// An [Authorizer] *must* have been previously linked in the channel. Otherwise, an error is thrown
/// at runtime. Example:
///
///         router
///           .route("/notes/[:id]")
///           .link(() => Authorizer.bearer(authServer))
///           .link(() => NoteController());
class Scope {
  /// Constructor for the Scope class.
  ///
  /// Creates a new Scope instance with the provided list of scopes.
  ///
  /// [scopes] is the list of authorization scopes required.
  const Scope(this.scopes);

  /// The list of authorization scopes required.
  ///
  /// This list contains the string representations of the scopes that are
  /// required for the annotated operation method.
  final List<String> scopes;
}
