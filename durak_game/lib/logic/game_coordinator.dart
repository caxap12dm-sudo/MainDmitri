import 'dart:convert';
import '../logic/game_engine.dart';
import '../services/bluetooth_service.dart';
import '../models/game_action.dart';
import '../models/card.dart';
import 'package:flutter/foundation.dart';

class GameCoordinator extends ChangeNotifier {
  final GameEngine engine;
  final BluetoothService bluetooth;
  bool isHost = false;

  GameCoordinator({
    required this.engine,
    required this.bluetooth,
  }) {
    bluetooth.messages.listen(_handleIncomingAction);
  }

  void setHost(bool value) {
    isHost = value;
    notifyListeners();
  }

  void _handleIncomingAction(Map<String, dynamic> data) {
    final action = GameAction.fromJson(data);

    switch (action.type) {
      case ActionType.startGame:
        if (!isHost) {
          _syncFromPayload(action.payload!);
        }
        break;
      case ActionType.playCard:
        engine.playCard(action.card!, false);
        break;
      case ActionType.endTurn:
        engine.endTurn();
        break;
      case ActionType.takeCards:
        engine.takeCards(false);
        break;
      case ActionType.syncState:
        _syncFromPayload(action.payload!);
        break;
    }
    notifyListeners();
  }

  void _syncFromPayload(Map<String, dynamic> payload) {
    if (payload.containsKey('trumpCard')) {
      engine.trumpCard = Card.fromJson(payload['trumpCard']);
      engine.trumpSuit = engine.trumpCard!.suit;
    }
    if (payload.containsKey('deck')) {
      engine.deck = (payload['deck'] as List)
          .map((item) => Card.fromJson(item))
          .toList();
    }
    // Swap hands: what is host's playerHand is client's opponentHand
    if (payload.containsKey('playerHand')) {
      engine.opponentHand = (payload['playerHand'] as List)
          .map((item) => Card.fromJson(item))
          .toList();
    }
    if (payload.containsKey('opponentHand')) {
      engine.playerHand = (payload['opponentHand'] as List)
          .map((item) => Card.fromJson(item))
          .toList();
    }
    if (payload.containsKey('isPlayerTurn')) {
      // If it was host's turn, it's not client's turn
      engine.isPlayerTurn = !payload['isPlayerTurn'];
    }
    notifyListeners();
  }

  Map<String, dynamic> _getStatePayload() {
    return {
      'trumpCard': engine.trumpCard?.toJson(),
      'deck': engine.deck.map((c) => c.toJson()).toList(),
      'playerHand': engine.playerHand.map((c) => c.toJson()).toList(),
      'opponentHand': engine.opponentHand.map((c) => c.toJson()).toList(),
      'isPlayerTurn': engine.isPlayerTurn,
    };
  }

  void playCard(Card card) {
    if (engine.canPlayCard(card)) {
      engine.playCard(card, true);
      bluetooth.sendMessage(GameAction(type: ActionType.playCard, card: card).toJson());
      notifyListeners();
    }
  }

  void endTurn() {
    engine.endTurn();
    bluetooth.sendMessage(GameAction(type: ActionType.endTurn).toJson());
    notifyListeners();
  }

  void takeCards() {
    engine.takeCards(true);
    bluetooth.sendMessage(GameAction(type: ActionType.takeCards).toJson());
    notifyListeners();
  }

  void startHostGame() {
    engine.startNewGame();
    isHost = true;
    bluetooth.sendMessage(GameAction(
      type: ActionType.startGame,
      payload: _getStatePayload()
    ).toJson());
    notifyListeners();
  }
}
