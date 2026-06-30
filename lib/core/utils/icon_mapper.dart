import 'package:flutter/material.dart';

class IconMapper {
  static const List<String> availableIcons = [
    'fastfood',
    'directions_car',
    'receipt',
    'sports_esports',
    'account_balance_wallet',
    'card_giftcard',
    'trending_up',
    'shopping_cart',
    'home',
    'local_hospital',
    'school',
    'flight',
    'pets',
    'fitness_center',
    'movie',
    'category'
  ];

  static IconData getIcon(String iconName) {
    switch (iconName) {
      case 'fastfood':
        return Icons.fastfood;
      case 'directions_car':
        return Icons.directions_car;
      case 'receipt':
        return Icons.receipt;
      case 'sports_esports':
        return Icons.sports_esports;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'trending_up':
        return Icons.trending_up;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'home':
        return Icons.home;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'flight':
        return Icons.flight;
      case 'pets':
        return Icons.pets;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'movie':
        return Icons.movie;
      default:
        return Icons.category;
    }
  }
}
