import 'dart:math';
import '../models/card.dart';

enum GamePhase { attacking, defending, finished }

class GameEngine {
  List<Card> deck = [];
  List<Card> playerHand = [];
  List<Card> opponentHand = [];
  List<MapEntry<Card, Card?>> table = []; // Attacking card, defending card
  Card? trumpCard;
  Suit? trumpSuit;
  bool isPlayerTurn = true; // True if player is attacking
  GamePhase phase = GamePhase.attacking;
  String? winner;

  void startNewGame() {
    _initializeDeck();
    _shuffleDeck();
    trumpCard = deck.removeLast();
    trumpSuit = trumpCard!.suit;
    deck.insert(0, trumpCard!); // Put trump back at the bottom

    playerHand = _drawCards(6);
    opponentHand = _drawCards(6);

    isPlayerTurn = true; // For simplicity, host/player starts
    phase = GamePhase.attacking;
    table = [];
    winner = null;
  }

  void _initializeDeck() {
    deck = [];
    for (var suit in Suit.values) {
      for (var rank in Rank.values) {
        deck.add(Card(suit: suit, rank: rank));
      }
    }
  }

  void _shuffleDeck() {
    deck.shuffle();
  }

  List<Card> _drawCards(int count) {
    List<Card> drawn = [];
    for (int i = 0; i < count && deck.isNotEmpty; i++) {
      drawn.add(deck.removeLast());
    }
    return drawn;
  }

  void replenishHands() {
    // Attacker draws first, then defender
    if (isPlayerTurn) {
        _replenishPlayer();
        _replenishOpponent();
    } else {
        _replenishOpponent();
        _replenishPlayer();
    }
    _checkWinner();
  }

  void _replenishPlayer() {
    int playerNeeds = 6 - playerHand.length;
    if (playerNeeds > 0) {
      playerHand.addAll(_drawCards(playerNeeds));
    }
  }

  void _replenishOpponent() {
    int opponentNeeds = 6 - opponentHand.length;
    if (opponentNeeds > 0) {
      opponentHand.addAll(_drawCards(opponentNeeds));
    }
  }

  bool canPlayCard(Card card) {
    if (phase == GamePhase.attacking) {
      // In attacking phase, the attacker (isPlayerTurn == true) plays.
      // But if defender is playing, it's actually defending phase.
      // Wait, let's keep it simple:
      // If table is empty, attacker can play anything.
      if (table.isEmpty) return true;
      // If table not empty, must match rank on table.
      return table.any((entry) =>
          entry.key.rank == card.rank ||
          (entry.value != null && entry.value!.rank == card.rank));
    } else if (phase == GamePhase.defending) {
      // Find the first undefended card
      Card? attackCard;
      for (var entry in table) {
        if (entry.value == null) {
           attackCard = entry.key;
           break;
        }
      }
      if (attackCard == null) return false;
      return _canDefend(attackCard, card);
    }
    return false;
  }

  bool _canDefend(Card attack, Card defense) {
    if (defense.suit == attack.suit) {
      return defense.value > attack.value;
    }
    return defense.suit == trumpSuit && attack.suit != trumpSuit;
  }

  void playCard(Card card, bool isLocalPlayerAction) {
    if (isLocalPlayerAction) {
      playerHand.remove(card);
    } else {
      opponentHand.remove(card);
    }

    if (phase == GamePhase.attacking) {
      table.add(MapEntry(card, null));
      phase = GamePhase.defending;
      // We don't flip isPlayerTurn here because it's still the attacker's turn
      // but they are waiting for defense.
    } else {
      // Defending
      for (int i = 0; i < table.length; i++) {
        if (table[i].value == null) {
          table[i] = MapEntry(table[i].key, card);
          break;
        }
      }
      phase = GamePhase.attacking;
      // After defense, it's back to attacking phase for the SAME attacker
      // until they decide to end the turn.
    }
  }

  void endTurn() {
    // This is called when attacker is done and defender successfully defended.
    table = [];
    replenishHands();
    // Defender becomes new attacker
    isPlayerTurn = !isPlayerTurn;
    phase = GamePhase.attacking;
  }

  void takeCards(bool isLocalPlayerTaking) {
    for (var entry in table) {
      if (isLocalPlayerTaking) {
        playerHand.add(entry.key);
        if (entry.value != null) playerHand.add(entry.value!);
      } else {
        opponentHand.add(entry.key);
        if (entry.value != null) opponentHand.add(entry.value!);
      }
    }
    table = [];
    replenishHands();
    // Attacker remains attacker. phase stays attacking.
    // isPlayerTurn remains the same.
    phase = GamePhase.attacking;
  }

  void _checkWinner() {
    if (deck.isEmpty) {
      if (playerHand.isEmpty && opponentHand.isEmpty) {
          winner = "Draw";
      } else if (playerHand.isEmpty) {
          winner = "Player";
      } else if (opponentHand.isEmpty) {
          winner = "Opponent";
      }
    }
  }
}
