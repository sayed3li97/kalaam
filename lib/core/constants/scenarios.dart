import 'package:kalaam/shared/models/scenario.dart';

abstract final class KalaamScenarios {
  static const all = [
    Scenario(
      id: 'ar_coffee',
      languageCode: 'ar',
      title: 'Ordering Coffee',
      description: 'A Cairo ahwa at dawn',
      emoji: '☕',
      difficulty: 'Beginner',
    ),
    Scenario(
      id: 'ar_market',
      languageCode: 'ar',
      title: 'At the Market',
      description: 'Spice souk in Muscat',
      emoji: '🛒',
      difficulty: 'Beginner',
    ),
    Scenario(
      id: 'ar_hotel',
      languageCode: 'ar',
      title: 'Hotel Check-in',
      description: 'Grand Hyatt Muscat',
      emoji: '🏨',
      difficulty: 'Intermediate',
    ),
    Scenario(
      id: 'ar_taxi',
      languageCode: 'ar',
      title: 'Taxi Ride',
      description: 'Downtown Casablanca',
      emoji: '🚕',
      difficulty: 'Beginner',
    ),
    Scenario(
      id: 'ar_meeting',
      languageCode: 'ar',
      title: 'Meeting Someone New',
      description: 'Office in Dubai',
      emoji: '🤝',
      difficulty: 'Beginner',
    ),
    Scenario(
      id: 'ar_restaurant',
      languageCode: 'ar',
      title: 'At a Restaurant',
      description: 'Levantine mezze',
      emoji: '🍽️',
      difficulty: 'Intermediate',
    ),
  ];

  static Scenario? byId(String id) => all.where((s) => s.id == id).firstOrNull;
  static List<Scenario> byLanguage(String code) =>
      all.where((s) => s.languageCode == code).toList();
}
