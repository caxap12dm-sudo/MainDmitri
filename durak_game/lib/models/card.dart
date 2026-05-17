enum Suit { spades, hearts, diamonds, clubs }

enum Rank {
  six,
  seven,
  eight,
  nine,
  ten,
  jack,
  queen,
  king,
  ace,
}

class Card {
  final Suit suit;
  final Rank rank;

  Card({required this.suit, required this.rank});

  int get value {
    switch (rank) {
      case Rank.six:
        return 6;
      case Rank.seven:
        return 7;
      case Rank.eight:
        return 8;
      case Rank.nine:
        return 9;
      case Rank.ten:
        return 10;
      case Rank.jack:
        return 11;
      case Rank.queen:
        return 12;
      case Rank.king:
        return 13;
      case Rank.ace:
        return 14;
    }
  }

  @override
  String toString() => '${rank.name} of ${suit.name}';

  Map<String, dynamic> toJson() => {
        'suit': suit.index,
        'rank': rank.index,
      };

  factory Card.fromJson(Map<String, dynamic> json) => Card(
        suit: Suit.values[json['suit']],
        rank: Rank.values[json['rank']],
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Card &&
          runtimeType == other.runtimeType &&
          suit == other.suit &&
          rank == other.rank;

  @override
  int get hashCode => suit.hashCode ^ rank.hashCode;
}
