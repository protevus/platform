import 'dart:math' as math;

/// A class for running lottery-style random number operations.
///
/// This class provides functionality for running lottery-style operations
/// with configurable odds, similar to Laravel's Lottery class.
class Lottery {
  /// The number of lottery tickets.
  final int tickets;

  /// The number of winning tickets.
  final int winners;

  /// The random number generator.
  final math.Random _random;

  /// Create a new lottery instance.
  ///
  /// The [tickets] parameter specifies the total number of tickets in the lottery.
  /// The [winners] parameter specifies how many of those tickets are winners.
  /// An optional [random] parameter can be provided for testing purposes.
  Lottery(this.tickets, this.winners, [math.Random? random])
      : assert(tickets > 0, 'Total tickets must be greater than 0'),
        assert(winners >= 0, 'Winning tickets must be 0 or greater'),
        assert(winners <= tickets,
            'Winning tickets cannot be greater than total tickets'),
        _random = random ?? math.Random();

  /// Create a new lottery instance with odds represented as a fraction.
  ///
  /// Example:
  /// ```dart
  /// // 1 in 2 chance (50%)
  /// final lottery = Lottery.odds(1, 2);
  /// ```
  factory Lottery.odds(int winners, int outOf, [math.Random? random]) {
    return Lottery(outOf, winners, random);
  }

  /// Create a new lottery instance with a percentage chance of winning.
  ///
  /// Example:
  /// ```dart
  /// // 50% chance of winning
  /// final lottery = Lottery.percentage(50);
  /// ```
  factory Lottery.percentage(int percentage, [math.Random? random]) {
    assert(percentage >= 0 && percentage <= 100,
        'Percentage must be between 0 and 100');
    return Lottery(100, percentage, random);
  }

  /// Determine if the lottery was a winner.
  bool choose() {
    if (winners <= 0) return false;
    if (winners >= tickets) return true;
    return _random.nextInt(tickets) < winners;
  }

  /// Run the given callback if the lottery was a winner.
  Future<T?> run<T>(Future<T> Function() callback) async {
    if (choose()) {
      return await callback();
    }
    return null;
  }

  /// Run the given callback if the lottery was a winner.
  T? sync<T>(T Function() callback) {
    if (choose()) {
      return callback();
    }
    return null;
  }

  /// Get the probability of winning as a percentage.
  double get probability => (winners / tickets) * 100;

  /// Get the odds of winning as a ratio string.
  String get odds => '$winners:$tickets';
}
