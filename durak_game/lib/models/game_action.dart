import '../models/card.dart';

enum ActionType {
  startGame,
  playCard,
  endTurn,
  takeCards,
  syncState,
}

class GameAction {
  final ActionType type;
  final Card? card;
  final Map<String, dynamic>? payload;

  GameAction({required this.type, this.card, this.payload});

  Map<String, dynamic> toJson() => {
        'type': type.name,
        if (card != null) 'card': card!.toJson(),
        if (payload != null) 'payload': payload,
      };

  factory GameAction.fromJson(Map<String, dynamic> json) => GameAction(
        type: ActionType.values.firstWhere((e) => e.name == json['type']),
        card: json['card'] != null ? Card.fromJson(json['card']) : null,
        payload: json['payload'],
      );
}
