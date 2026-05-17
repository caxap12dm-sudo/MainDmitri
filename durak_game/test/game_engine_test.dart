import 'package:flutter_test/flutter_test.dart';
import 'package:durak_game/logic/game_engine.dart';
import 'package:durak_game/models/card.dart';

void main() {
  group('GameEngine Tests', () {
    late GameEngine engine;

    setUp(() {
      engine = GameEngine();
      engine.startNewGame();
    });

    test('Initial hands should have 6 cards', () {
      expect(engine.playerHand.length, 6);
      expect(engine.opponentHand.length, 6);
    });

    test('Deck should decrease after drawing', () {
      // Initial deck 36.
      // trump = deck.removeLast() -> 35
      // deck.insert(0, trump) -> 36
      // draw 6 (player) -> 30
      // draw 6 (opponent) -> 24
      expect(engine.deck.length, 24);
    });

    test('Defense rules', () {
      engine.trumpSuit = Suit.hearts;
      Card attack = Card(suit: Suit.spades, rank: Rank.seven);

      // Higher card same suit
      Card defense1 = Card(suit: Suit.spades, rank: Rank.eight);
      expect(engine.canPlayCard(attack), true);
      engine.playCard(attack, true); // Phase becomes defending
      expect(engine.canPlayCard(defense1), true);

      // Lower card same suit
      Card defense2 = Card(suit: Suit.spades, rank: Rank.six);
      expect(engine.canPlayCard(defense2), false);

      // Trump card against non-trump
      Card defense3 = Card(suit: Suit.hearts, rank: Rank.six);
      expect(engine.canPlayCard(defense3), true);
    });
  });
}
