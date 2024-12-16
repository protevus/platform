/// Interface for a web link.
///
/// A link is a representation of a hyperlink from one resource to another.
/// This interface represents a single hyperlink, including its target,
/// relationship, and any attributes associated with it.
abstract class LinkInterface {
  /// Returns the target of the link.
  ///
  /// The target must be an absolute URI or a relative reference.
  String getHref();

  /// Returns whether this is a templated link.
  ///
  /// Returns true if this link object is a template that still needs to be
  /// processed. Returns false if it is already a usable link.
  bool isTemplated();

  /// Returns the relationship type(s) of the link.
  ///
  /// This method returns 0 or more relationship types for a link, expressed
  /// as strings.
  Set<String> getRels();

  /// Returns the attributes of the link.
  ///
  /// Returns a map of attributes, where the key is the attribute name and the
  /// value is the attribute value.
  Map<String, dynamic> getAttributes();
}

/// Interface for an evolvable link value object.
///
/// An evolvable link is one that may be modified without forcing a new object
/// to be created. This interface extends [LinkInterface] to provide methods
/// for modifying the link properties.
abstract class EvolvableLinkInterface implements LinkInterface {
  /// Returns an instance with the specified href.
  ///
  /// [href] The href value to include.
  ///
  /// Returns a new instance with the specified href.
  /// Implementations MUST NOT modify the underlying object but return
  /// an updated copy.
  EvolvableLinkInterface withHref(String href);

  /// Returns an instance with the specified relationship included.
  ///
  /// If the specified rel is already present, this method MUST return
  /// normally without errors but without adding the rel a second time.
  ///
  /// [rel] The relationship value to add.
  ///
  /// Returns a new instance with the specified relationship included.
  /// Implementations MUST NOT modify the underlying object but return
  /// an updated copy.
  EvolvableLinkInterface withRel(String rel);

  /// Returns an instance with the specified relationship excluded.
  ///
  /// If the specified rel is already not present, this method MUST return
  /// normally without errors.
  ///
  /// [rel] The relationship value to exclude.
  ///
  /// Returns a new instance with the specified relationship excluded.
  /// Implementations MUST NOT modify the underlying object but return
  /// an updated copy.
  EvolvableLinkInterface withoutRel(String rel);

  /// Returns an instance with the specified attribute added.
  ///
  /// If the specified attribute is already present, it will be overwritten
  /// with the new value.
  ///
  /// [attribute] The attribute to include.
  /// [value] The value of the attribute to set.
  ///
  /// Returns a new instance with the specified attribute included.
  /// Implementations MUST NOT modify the underlying object but return
  /// an updated copy.
  EvolvableLinkInterface withAttribute(String attribute, dynamic value);

  /// Returns an instance with the specified attribute excluded.
  ///
  /// If the specified attribute is not present, this method MUST return
  /// normally without errors.
  ///
  /// [attribute] The attribute to remove.
  ///
  /// Returns a new instance with the specified attribute excluded.
  /// Implementations MUST NOT modify the underlying object but return
  /// an updated copy.
  EvolvableLinkInterface withoutAttribute(String attribute);
}
