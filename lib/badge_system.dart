import 'package:flutter/material.dart';

class AchievementBadge {
  final String id;
  final String name;
  final String emoji;
  final Color color;
  final int requiredCount;
  final String type;
  
  AchievementBadge({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.requiredCount,
    required this.type,
  });
}

class BadgeSystem {
  static List<AchievementBadge> getAllBadges() {
    return [
      // Only 6 meaningful badges
      AchievementBadge(
        id: 'beginner',
        name: 'Beginner',
        emoji: '🌱',
        color: Colors.green,
        requiredCount: 1,
        type: 'scan',
      ),
      AchievementBadge(
        id: 'expert',
        name: 'Expert',
        emoji: '🌿',
        color: Colors.teal,
        requiredCount: 25,
        type: 'scan',
      ),
      AchievementBadge(
        id: 'master',
        name: 'Master',
        emoji: '🏆',
        color: Colors.amber,
        requiredCount: 100,
        type: 'scan',
      ),
      AchievementBadge(
        id: 'helper',
        name: 'Helper',
        emoji: '❤️',
        color: Colors.red,
        requiredCount: 5,
        type: 'post',
      ),
      AchievementBadge(
        id: 'champion',
        name: 'Champion',
        emoji: '👑',
        color: Colors.purple,
        requiredCount: 20,
        type: 'post',
      ),
      AchievementBadge(
        id: 'streak',
        name: 'On Fire',
        emoji: '🏅',
        color: Colors.deepOrange,
        requiredCount: 7,
        type: 'streak',
      ),
    ];
  }
  
  static List<AchievementBadge> getEarnedBadges(Map<String, int> userStats) {
    List<AchievementBadge> earnedBadges = [];
    
    for (var badge in getAllBadges()) {
      int userCount = userStats[badge.type] ?? 0;
      
      if (userCount >= badge.requiredCount) {
        earnedBadges.add(badge);
      }
    }
    
    return earnedBadges;
  }
  
  // Get top 3 badges to display
  static List<AchievementBadge> getTopBadges(Map<String, int> userStats) {
    List<AchievementBadge> earned = getEarnedBadges(userStats);
    
    // Sort by required count (higher = more impressive)
    earned.sort((a, b) => b.requiredCount.compareTo(a.requiredCount));
    
    // Return top 3
    return earned.take(3).toList();
  }
  
  static int calculateLevel(Map<String, int> userStats) {
    int totalPoints = 0;
    
    totalPoints += (userStats['scan'] ?? 0) * 5;
    totalPoints += (userStats['post'] ?? 0) * 10;
    totalPoints += (userStats['help'] ?? 0) * 2;
    totalPoints += (userStats['streak'] ?? 0) * 3;
    
    return (totalPoints / 100).floor() + 1;
  }
  
  static String getLevelTitle(int level) {
    if (level >= 20) return 'Legend';
    if (level >= 15) return 'Expert';
    if (level >= 10) return 'Advanced';
    if (level >= 5) return 'Skilled';
    return 'Farmer';
  }
  
  static Color getLevelColor(int level) {
    if (level >= 20) return Colors.amber;
    if (level >= 15) return Colors.orange;
    if (level >= 10) return Colors.blue;
    if (level >= 5) return Colors.green;
    return Colors.grey;
  }
}
