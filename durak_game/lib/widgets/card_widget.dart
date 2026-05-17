import 'package:flutter/material.dart';
import '../models/card.dart' as models;

class CardWidget extends StatelessWidget {
  final models.Card card;
  final bool isFaceUp;
  final VoidCallback? onTap;

  const CardWidget({
    super.key,
    required this.card,
    this.isFaceUp = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 90,
        decoration: BoxDecoration(
          color: isFaceUp ? Colors.white : Colors.blue,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black),
        ),
        child: isFaceUp
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_getSuitIcon(card.suit), style: const TextStyle(fontSize: 20)),
                  Text(_getRankLabel(card.rank), style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              )
            : const Icon(Icons.help_outline, color: Colors.white),
      ),
    );
  }

  String _getSuitIcon(models.Suit suit) {
    switch (suit) {
      case models.Suit.spades:
        return '♠';
      case models.Suit.hearts:
        return '♥';
      case models.Suit.diamonds:
        return '♦';
      case models.Suit.clubs:
        return '♣';
    }
  }

  String _getRankLabel(models.Rank rank) {
    switch (rank) {
      case models.Rank.six:
        return '6';
      case models.Rank.seven:
        return '7';
      case models.Rank.eight:
        return '8';
      case models.Rank.nine:
        return '9';
      case models.Rank.ten:
        return '10';
      case models.Rank.jack:
        return 'J';
      case models.Rank.queen:
        return 'Q';
      case models.Rank.king:
        return 'K';
      case models.Rank.ace:
        return 'A';
    }
  }
}
