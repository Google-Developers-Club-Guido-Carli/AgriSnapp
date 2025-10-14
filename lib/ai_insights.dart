import 'package:flutter/material.dart';

class AIInsights {
  // User profile data (would come from database in real app)
  static Map<String, dynamic> userProfile = {
    'name': 'Yasemin',
    'location': 'Istanbul, Turkey',
    'farmSize': '8.5 hectares',
    'experience': 'intermediate',
    'scanHistory': [
      {'disease': 'Peacock Spot', 'date': '2 weeks ago', 'severity': 'moderate'},
      {'disease': 'Healthy', 'date': '1 month ago', 'severity': 'none'},
      {'disease': 'Olive Knot', 'date': '3 months ago', 'severity': 'severe'},
    ],
    'lastTreatment': 'Copper fungicide spray (2 weeks ago)',
    'season': 'October',
  };
  
  // Regional disease data
  static Map<String, Map<String, dynamic>> regionalData = {
    'Istanbul, Turkey': {
      'common_diseases': ['Peacock Spot', 'Olive Knot'],
      'season_risk': 'HIGH',
      'rainfall': 'Moderate',
      'temperature': '18-24°C',
      'nearby_outbreaks': 2,
    },
    'Izmir, Turkey': {
      'common_diseases': ['Peacock Spot', 'Verticillium Wilt'],
      'season_risk': 'MEDIUM',
      'rainfall': 'Low',
      'temperature': '20-26°C',
      'nearby_outbreaks': 1,
    },
  };
  
  static String generatePersonalizedInsights(String diseaseName, String location) {
    var region = regionalData[location] ?? regionalData['Istanbul, Turkey']!;
    var history = userProfile['scanHistory'] as List;
    
    String insights = '';
    
    // HEADER
    insights += '🤖 AI INSIGHTS FOR ${userProfile['name'].toUpperCase()}\n\n';
    
    // REGIONAL ANALYSIS
    bool isCommon = region['common_diseases'].contains(diseaseName);
    insights += '📍 Location Analysis: $location\n';
    insights += 'This disease is ${isCommon ? "COMMON" : "RARE"} in your region.\n';
    if (isCommon) {
      insights += '⚠️ ${region['nearby_outbreaks']} nearby farmers reported this recently.\n';
    }
    insights += '\n';
    
    // SEASONAL CONTEXT
    insights += '📅 Seasonal Risk: ${region['season_risk']}\n';
    insights += 'Current conditions favor disease spread (${region['rainfall']} rainfall, ${region['temperature']}).\n';
    insights += '\n';
    
    // PERSONAL HISTORY
    bool hadBefore = history.any((h) => h['disease'] == diseaseName);
    if (hadBefore) {
      var lastOccurrence = history.firstWhere((h) => h['disease'] == diseaseName);
      insights += '📊 Your History: You detected this ${lastOccurrence['date']}.\n';
      insights += 'Severity was ${lastOccurrence['severity']}. This is a RECURRING issue.\n';
      insights += '💡 Recommendation: Consider preventive measures even when healthy.\n';
    } else {
      insights += '📊 Your History: First time detecting this disease.\n';
      insights += '💡 Act quickly to prevent spread to your entire ${userProfile['farmSize']} grove.\n';
    }
    insights += '\n';
    
    // FARM-SPECIFIC ADVICE
    if (diseaseName == 'Peacock Spot') {
      insights += '🌿 For Your Farm:\n';
      insights += '• Your last treatment (${userProfile['lastTreatment']}) may need renewal.\n';
      insights += '• With ${userProfile['farmSize']}, expect to need ~15L of copper solution.\n';
      insights += '• Priority: Remove fallen leaves ASAP to stop spore spread.\n';
      insights += '• Timeline: Start treatment within 48 hours for best results.\n';
    } else if (diseaseName == 'Olive Knot') {
      insights += '🌿 For Your Farm:\n';
      insights += '• Immediate action needed - this spreads through rain/irrigation.\n';
      insights += '• Prune infected branches at least 30cm below visible knots.\n';
      insights += '• Disinfect all tools with 10% bleach solution between cuts.\n';
      insights += '• Monitor entire ${userProfile['farmSize']} grove weekly for new infections.\n';
    }
    insights += '\n';
    
    // EXPERT TIPS
    insights += '💎 Expert Tips:\n';
    if (userProfile['experience'] == 'intermediate') {
      insights += '• You have experience with this - trust your instincts!\n';
    }
    insights += '• Share your findings with nearby farmers (Community tab).\n';
    insights += '• Document progress - take photos weekly to track recovery.\n';
    insights += '• Weather forecast: Check for rain in next 7 days before spraying.\n';
    
    return insights;
  }
  
  static String generateHealthyInsights(String location) {
    var region = regionalData[location] ?? regionalData['Istanbul, Turkey']!;
    var history = userProfile['scanHistory'] as List;
    
    String insights = '';
    
    insights += '🤖 AI INSIGHTS FOR ${userProfile['name'].toUpperCase()}\n\n';
    insights += '✅ HEALTHY LEAF DETECTED\n\n';
    
    insights += '📍 Location: $location\n';
    insights += 'Current risk level: ${region['season_risk']}\n';
    insights += 'Active outbreaks nearby: ${region['nearby_outbreaks']}\n\n';
    
    insights += '📊 Your Prevention Score: EXCELLENT\n';
    var healthyScans = history.where((h) => h['severity'] == 'none').length;
    insights += 'You have $healthyScans healthy scans in your history.\n\n';
    
    insights += '💡 Preventive Actions:\n';
    insights += '• Keep monitoring - scan 2-3 leaves per tree weekly.\n';
    insights += '• Maintain good airflow between trees.\n';
    insights += '• Current weather (${region['temperature']}) is optimal.\n';
    insights += '• Watch for ${region['common_diseases'].join(", ")} (common in your area).\n\n';
    
    insights += '🌟 Great job maintaining your ${userProfile['farmSize']} grove!\n';
    
    return insights;
  }
}

class AIInsightsWidget extends StatelessWidget {
  final String insights;
  
  AIInsightsWidget({required this.insights});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A237E),
            Color(0xFF283593),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.psychology, color: Colors.white, size: 28),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'AI-Powered Insights',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'BETA',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              insights,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
