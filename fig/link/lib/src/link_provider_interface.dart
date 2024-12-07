import 'link_interface.dart';

/// Interface for a link provider.
///
/// A link provider represents an object that contains web links, typically
/// an HTTP response. This interface provides methods for accessing those links.
abstract class LinkProviderInterface {
  /// Returns a list of LinkInterface objects.
  ///
  /// [rel] The relationship type to retrieve links for.
  ///
  /// Returns a list of LinkInterface objects that have the specified relation.
  List<LinkInterface> getLinks([String? rel]);

  /// Returns a list of relationship types.
  ///
  /// Returns a list of strings, representing the rels available on this object.
  List<String> getLinksByRel(String rel);
}

/// Interface for an evolvable link provider value object.
///
/// An evolvable link provider is one that may be modified without forcing
/// a new object to be created. This interface extends [LinkProviderInterface]
/// to provide methods for modifying the provider's links.
abstract class EvolvableLinkProviderInterface implements LinkProviderInterface {
  /// Returns an instance with the specified link included.
  ///
  /// If the specified link is already present, this method will add the rel
  /// from the link to the link already present.
  ///
  /// [link] A link object that should be included in this provider.
  ///
  /// Returns a new instance with the specified link included.
  /// Implementations MUST NOT modify the underlying object but return
  /// an updated copy.
  EvolvableLinkProviderInterface withLink(LinkInterface link);

  /// Returns an instance with the specified link excluded.
  ///
  /// If the specified link is not present, this method MUST return normally
  /// without errors.
  ///
  /// [link] The link to remove.
  ///
  /// Returns a new instance with the specified link excluded.
  /// Implementations MUST NOT modify the underlying object but return
  /// an updated copy.
  EvolvableLinkProviderInterface withoutLink(LinkInterface link);
}
