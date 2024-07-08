/*
 * This file is part of the Protevus Platform.
 * This file is a port of the symfony SesssionBagInterface.php class to Dart
 *
 * (C) Protevus <developers@protevus.com>
 * (C) Fabien Potencier <fabien@symfony.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/// An abstract class defining the interface for session bags.
///
/// A session bag is a storage mechanism used to group session attributes together.
/// It provides methods to manage and interact with session data.
abstract class SessionBagInterface {
  /// Returns the name of this bag.
  ///
  /// This method should be implemented to provide a unique identifier for the bag.
  /// The name is typically used to distinguish between different types of session bags.
  ///
  /// @return A string representing the name of the bag.
  String getName();

  /// Initializes the bag with the provided data.
  ///
  /// This method should be implemented to set up the initial state of the bag
  /// using the given array of data. It's typically used when restoring a session
  /// from storage or creating a new session with default values.
  ///
  /// @param array A list of dynamic values to initialize the bag with.
  void initialize(List<dynamic> array);

  /// Gets the storage key for this bag.
  ///
  /// This method should be implemented to return a unique identifier used
  /// for storing and retrieving the bag's data in the session storage.
  /// The storage key is typically used to organize and access different
  /// bags within the session storage mechanism.
  ///
  /// @return A string representing the storage key for this bag.
  String getStorageKey();

  /// Clears out all data from the bag and returns the cleared data.
  ///
  /// This method should be implemented to remove all stored attributes from the bag.
  /// It's typically used when you want to reset the bag to an empty state.
  ///
  /// @return A dynamic value representing the data that was contained in the bag before clearing.
  dynamic clear();
}
