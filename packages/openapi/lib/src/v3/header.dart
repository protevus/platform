/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_typeforge/codable.dart';
import 'package:protevus_openapi/v3.dart';

/// [APIHeader] follows the structure of the [APIParameter] with the following changes:
///
/// name MUST NOT be specified, it is given in the corresponding headers map.
/// in MUST NOT be specified, it is implicitly in header.
/// All traits that are affected by the location MUST be applicable to a location of header (for example, style).
class APIHeader extends APIParameter {
  APIHeader({APISchemaObject? schema}) : super.header(null, schema: schema);
  APIHeader.empty() : super.header(null);

  @override
  void encode(KeyedArchive object) {
    name = "temporary";
    super.encode(object);
    object.remove("name");
    object.remove("in");
    name = null;
  }
}
