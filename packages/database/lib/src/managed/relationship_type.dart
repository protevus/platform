/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/// The possible database relationships.
///
/// This enum represents the different types of relationships that can exist between
/// database entities. The available relationship types are:
///
/// - `hasOne`: A one-to-one relationship, where one entity has exactly one related entity.
/// - `hasMany`: A one-to-many relationship, where one entity can have multiple related entities.
/// - `belongsTo`: A many-to-one relationship, where multiple entities can belong to a single parent entity.
enum ManagedRelationshipType { hasOne, hasMany, belongsTo }
