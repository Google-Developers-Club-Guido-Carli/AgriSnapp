import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';  // ← ADD THIS LINE
import 'roboflow_service.dart';
import 'translation_service.dart';
import 'translated_text.dart';
import 'community_map_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'badge_system.dart';
import 'ai_insights.dart';
import 'privacy_manager.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AgriSnapApp());
}

class AgriSnapApp extends StatelessWidget {
  const AgriSnapApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriSnap',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: PrivacyWelcomeScreen(),  // ← DEMO MODE: Always show GDPR screen
    );
  }
}



class MainNavigationScreen extends StatefulWidget {
  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 1;
  
  final List<Widget> _pages = [
    CommunityScreen(),
    DiseaseDetectionScreen(),
    ProfileScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 12,
        unselectedFontSize: 12,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt, size: 30),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ============================================
// COMMUNITY SCREEN
// ============================================
class CommunityScreen extends StatefulWidget {
  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  
  static const LatLng _mediterraneanCenter = LatLng(38.0, 15.0);
  
  final List<Map<String, dynamic>> farmers = [
    {
      'name': 'Maria Rossi',
      'location': 'Palermo, Italy',
      'lat': 38.1157,
      'lon': 13.3615,
      'status': 'No active outbreaks',
      'isYou': false,
    },
    {
      'name': 'Yasemin Ates',
      'location': 'Istanbul, Turkey',
      'lat': 41.0082,
      'lon': 28.9784,
      'status': 'No active outbreaks',
      'isYou': true,
    },
    {
      'name': 'Hoca Dede',
      'location': 'Elazig, Turkey',
      'lat': 38.6810,
      'lon': 39.2264,
      'status': 'Healthy grove',
      'isYou': false,
    },
    {
      'name': 'Giulio Presaghi',
      'location': 'Bracciano, Italy',
      'lat': 42.1033,
      'lon': 12.1703,
      'status': 'Monitoring for diseases',
      'isYou': false,
    },
    {
      'name': 'Rebecca Raible',
      'location': 'Lucerne, Switzerland',
      'lat': 47.0502,
      'lon': 8.3093,
      'status': 'Organic farming',
      'isYou': false,
    },
    {
      'name': 'Alayna Shariff',
      'location': 'Granada, Spain',
      'lat': 37.1773,
      'lon': -3.5986,
      'status': 'Peacock Spot detected',
      'isYou': false,
    },
    {
      'name': 'Quynh Anh Tran',
      'location': 'Souss Valley, Morocco',
      'lat': 30.4278,
      'lon': -9.5981,
      'status': 'Treating Olive Knot',
      'isYou': false,
    },
    {
    'name': 'Johnpaul Ifeanyichukwu Egwuatu',
    'location': 'Castiglia, Italy',
    'lat': 44.4742,
    'lon': 11.4369,
    'status': 'Preparing for harvest',
    'isYou': false,
  },
  ];
  
  final List<Map<String, dynamic>> communityPosts = [
    {
      'farmer': 'Alayna Shariff',
      'location': 'Granada, Spain',
      'time': '3 hours ago',
      'content': 'Just detected peacock spot on my grove. Starting copper fungicide treatment today. Any tips?',
      'likes': 28,
      'comments': 19,
      'avatar': '👩‍🌾',
    },
    {
      'farmer': 'Giulio Presaghi',
      'location': 'Bracciano, Italy',
      'time': '5 hours ago',
      'content': 'Testing new organic pest control methods. So far looking promising!',
      'likes': 45,
      'comments': 23,
      'avatar': '👨‍🌾',
    },
    {
      'farmer': 'Quynh Anh Tran',
      'location': 'Souss Valley, Morocco',
      'time': '1 day ago',
      'content': 'Dealing with olive knot disease. Pruned infected branches and applied treatment.',
      'likes': 67,
      'comments': 31,
      'avatar': '👩‍🌾',
    },
    {
      'farmer': 'Maria Rossi',
      'location': 'Palermo, Italy',
      'time': '2 days ago',
      'content': 'A lot of rain in  the area. Any tips to deal with it?',
      'likes': 22,
      'comments': 18,
      'avatar': '👩‍🌾',
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _createMarkers();
  }
  
  void _createMarkers() {
    for (var farmer in farmers) {
      _markers.add(
        Marker(
          markerId: MarkerId(farmer['name']),
          position: LatLng(farmer['lat'], farmer['lon']),
          icon: farmer['isYou']
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
              : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(
            title: farmer['name'],
            snippet: farmer['status'],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TranslatedText('Farmer Community'),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: Icon(Icons.fullscreen),
            tooltip: 'Fullscreen Map',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CommunityMapScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: 250,
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _mediterraneanCenter,
                        zoom: 5,
                      ),
                      markers: _markers,
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      mapType: MapType.terrain,
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people, size: 16, color: Colors.green[700]),
                            SizedBox(width: 6),
                            Text(
                              '${farmers.length} farmers',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CommunityMapScreen()),
                          );
                        },
                        icon: Icon(Icons.open_in_full, size: 14),
                        label: Text('Expand'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TranslatedText(
                    'Community Feed',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: TranslatedText('Filter', style: TextStyle(color: Colors.green[700])),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final post = communityPosts[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  post['avatar'],
                                  style: TextStyle(fontSize: 28),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post['farmer'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '${post['location']} • ${post['time']}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.more_vert, color: Colors.grey),
                          ],
                        ),
                        SizedBox(height: 12),
                        TranslatedText(
                          post['content'],
                          style: TextStyle(fontSize: 14, height: 1.4),
                        ),
                        SizedBox(height: 12),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton.icon(
                              onPressed: () {},
                              icon: Icon(Icons.thumb_up_outlined, size: 18),
                              label: Text('${post['likes']}'),
                            ),
                            TextButton.icon(
                              onPressed: () {},
                              icon: Icon(Icons.comment_outlined, size: 18),
                              label: Text('${post['comments']}'),
                            ),
                            TextButton.icon(
                              onPressed: () {},
                              icon: Icon(Icons.share_outlined, size: 18),
                              label: TranslatedText('Share'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: communityPosts.length,
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.green[700],
        child: Icon(Icons.add),
      ),
    );
  }
}


// ============================================
// DISEASE DETECTION SCREEN (WITH CAMERA)
// ============================================
class DiseaseDetectionScreen extends StatefulWidget {
  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final RoboflowService _roboflowService = RoboflowService();
  bool _isAnalyzing = false;
  String _resultText = '';
  String _currentDiseaseName = '';  // ← ADD THIS LINE

  
  String getConfidenceLevel(double confidence) {
    if (confidence >= 90) return 'Highly Confident';
    if (confidence >= 75) return 'Confident';
    if (confidence >= 60) return 'Likely';
    if (confidence >= 40) return 'Suspicious';
    return 'Uncertain';
  }
  
  Map<String, Map<String, String>> diseaseDatabase = {
    '0': {
      'name': 'Olive Knot Disease',
      'local_names': 'Knot Disease, Olive Cancer, Tubercle Disease',
      'treatment': 'Cut infected branches. Spray copper solution. Disinfect tools.',
      'when': 'Late autumn or winter',
    },
    '1': {
      'name': 'Peacock Spot',
      'local_names': 'Peacock Eye, Bird\'s Eye Spot',
      'treatment': 'Remove fallen leaves. Apply copper fungicide. Improve airflow.',
      'when': 'October-November and February-March',
    },
  };
  
  String getDiseaseName(String classId) {
    String cleanId = classId.toString().replaceAll(RegExp(r'[^0-9]'), '');
    return diseaseDatabase[cleanId]?['name'] ?? 'Disease Class $classId';
  }
// CAMERA CAPTURE WITH SIMULATOR CHECK
Future<void> _takePhoto() async {
  try {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 85,
    );
    
    if (image != null) {
      _processImage(image.path);
    }
  } on PlatformException catch (e) {
    // Handle camera not available error
    if (e.code == 'camera_access_denied') {
      _showErrorDialog(
        'Camera Access Denied',
        'Please enable camera permissions in Settings to use this feature.',
      );
    } else {
      _showErrorDialog(
        'Camera Not Available',
        'Camera is not available on this device. Please use the Gallery option or test on a real device.',
      );
    }
  } catch (e) {
    _showErrorDialog(
      'Camera Error',
      'Could not access camera. If you\'re using a simulator, please use the Gallery option instead.',
    );
  }
}

// Error Dialog Helper
void _showErrorDialog(String title, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.orange, size: 28),
          SizedBox(width: 12),
          Text(title),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK', style: TextStyle(color: Colors.green[700])),
        ),
      ],
    ),
  );
}

  // GALLERY UPLOAD
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (image != null) {
        _processImage(image.path);
      }
    } catch (e) {
      setState(() {
        _resultText = 'Could not select image.';
      });
    }
  }
  
// PROCESS IMAGE (shared function)
Future<void> _processImage(String imagePath) async {
  setState(() {
    _image = File(imagePath);
    _isAnalyzing = true;
    _resultText = '';
  });
  
  try {
    final results = await _roboflowService.detectDisease(imagePath);
    
    setState(() {
      _isAnalyzing = false;
      
      if (results.containsKey('predictions')) {
        var predictions = results['predictions'];
        
        if (predictions is List && predictions.isNotEmpty) {
          var topPrediction = predictions[0];
          String classId = topPrediction['class']?.toString() ?? '0';
          double confidence = ((topPrediction['confidence'] ?? 0.0) * 100);
          
          String diseaseName = getDiseaseName(classId);
          _currentDiseaseName = diseaseName;  // ← ADD THIS LINE
          String confidenceLevel = getConfidenceLevel(confidence);
          
          var info = diseaseDatabase[classId.replaceAll(RegExp(r'[^0-9]'), '')];
          
          _resultText = 'DISEASE DETECTED\n\n';
          _resultText += '$diseaseName\n';
          _resultText += '$confidenceLevel\n\n';
          if (info != null) {
            _resultText += 'Treatment: ${info['treatment']}\n\n';
            _resultText += 'Best time: ${info['when']}';
          }
        } else {
          _currentDiseaseName = 'Healthy';  // ← ADD THIS TOO
          _resultText = 'HEALTHY LEAF\n\nNo diseases detected!';
        }
      }
    });
  } catch (e) {
    setState(() {
      _isAnalyzing = false;
      _resultText = 'Analysis failed. Try again.';
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TranslatedText('Disease Scanner'),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                
                // IMAGE PREVIEW
                if (_image != null) ...[
                  Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green[700]!, width: 3),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.file(_image!, fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(height: 24),
                ] else ...[
                  // EMPTY STATE
                  Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey[50],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.eco, size: 80, color: Colors.grey[400]),
                        SizedBox(height: 20),
                        TranslatedText(
                          'No image selected',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Take a photo or upload',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                ],
                
                // ANALYZING INDICATOR
                if (_isAnalyzing) ...[
                  CircularProgressIndicator(
                    color: Colors.green[700],
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16),
                  TranslatedText(
                    'Analyzing...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.green[700],
                    ),
                  ),
                  SizedBox(height: 24),
                ] else ...[
                  // CAMERA & UPLOAD BUTTONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // CAMERA BUTTON
                      ElevatedButton.icon(
                        onPressed: _takePhoto,
                        icon: Icon(Icons.camera_alt, size: 24),
                        label: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: TranslatedText(
                            'CAMERA',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                      ),
                      
                      SizedBox(width: 16),
                      
                      // GALLERY BUTTON
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(Icons.photo_library, size: 24),
                        label: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: TranslatedText(
                            'GALLERY',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green[700],
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(color: Colors.green[700]!, width: 2),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                ],
                
                // RESULT BOX
                if (_resultText.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(maxWidth: 400),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _resultText.contains('failed')
                          ? Colors.red[50]
                          : _resultText.contains('DISEASE')
                              ? Colors.orange[50]
                              : Colors.green[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _resultText.contains('failed')
                            ? Colors.red
                            : _resultText.contains('DISEASE')
                                ? Colors.orange
                                : Colors.green,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_resultText.contains('failed')
                                  ? Colors.red
                                  : _resultText.contains('DISEASE')
                                      ? Colors.orange
                                      : Colors.green)
                              .withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _resultText.contains('HEALTHY')
                              ? Icons.check_circle
                              : _resultText.contains('DISEASE')
                                  ? Icons.warning
                                  : Icons.error,
                          size: 48,
                          color: _resultText.contains('failed')
                              ? Colors.red
                              : _resultText.contains('DISEASE')
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                        SizedBox(height: 16),
                        TranslatedText(
                          _resultText,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // AI INSIGHTS - PERSONALIZED! 🔥
                  AIInsightsWidget(
                    insights: _resultText.contains('DISEASE')
                        ? AIInsights.generatePersonalizedInsights(
                            _currentDiseaseName,
                            'Istanbul, Turkey',
                          )
                        : AIInsights.generateHealthyInsights('Istanbul, Turkey'),
                  ),
                  
                  SizedBox(height: 24),
                ],
                
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// ============================================
// PROFILE SCREEN (WITH PRIVACY BUTTON)
// ============================================
class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, int> userStats = {
    'scan': 45,
    'post': 12,
    'help': 67,
    'streak': 15,
  };
  
  @override
  Widget build(BuildContext context) {
    List<AchievementBadge> topBadges = BadgeSystem.getTopBadges(userStats);
    int userLevel = BadgeSystem.calculateLevel(userStats);
    String levelTitle = BadgeSystem.getLevelTitle(userLevel);
    Color levelColor = BadgeSystem.getLevelColor(userLevel);
    
    return Scaffold(
      appBar: AppBar(
        title: TranslatedText('My Profile'),
        backgroundColor: Colors.green[700],
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.language),
            tooltip: 'Change Language',
            onSelected: (String langCode) {
              setState(() {
                TranslationService.setLanguage(langCode);
              });
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainNavigationScreen()),
              );
            },
            itemBuilder: (context) {
              return TranslationService.getLanguages().entries.map((entry) {
                return PopupMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: levelColor, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: levelColor.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('👨‍🌾', style: TextStyle(fontSize: 60)),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: levelColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      'LVL $userLevel',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 15),
            Text('Yasemin Ates', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: levelColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TranslatedText(
                levelTitle,
                style: TextStyle(
                  color: levelColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            SizedBox(height: 5),
            TranslatedText('Olive Farmer • Turkey', style: TextStyle(color: Colors.grey[600])),
            
            SizedBox(height: 25),
            
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn('${userStats['scan']}', 'Scans', Icons.camera_alt),
                  _buildStatColumn('${userStats['post']}', 'Posts', Icons.post_add),
                  _buildStatColumn('${userStats['streak']}', 'Streak', Icons.local_fire_department),
                ],
              ),
            ),
            
            SizedBox(height: 30),
            
            if (topBadges.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TranslatedText(
                      'Top Achievements',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${topBadges.length}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              
              Container(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: topBadges.length,
                  itemBuilder: (context, index) {
                    AchievementBadge badge = topBadges[index];
                    
                    return Container(
                      width: 110,
                      margin: EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            badge.color.withOpacity(0.3),
                            badge.color.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: badge.color, width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            badge.emoji,
                            style: TextStyle(fontSize: 48),
                          ),
                          SizedBox(height: 8),
                          TranslatedText(
                            badge.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: badge.color,
                            ),
                          ),
                          SizedBox(height: 4),
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: badge.color,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              SizedBox(height: 30),
            ],
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TranslatedText(
                    'Farm Information',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  
                  _buildInfoTile(Icons.location_on, 'Location', 'Istanbul, Turkey'),
                  _buildInfoTile(Icons.terrain, 'Farm Size', '8.5 hectares'),
                  
                  SizedBox(height: 25),
                  
                  // EDIT PROFILE BUTTON
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: TranslatedText('EDIT PROFILE'),
                  ),
                  
                  SizedBox(height: 12),
                  
                  // GDPR COMPLIANCE SECTION WITH EU FLAG
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF003399), Color(0xFF0055BB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // EU FLAG MINI
                            // EU FLAG EMOJI
                            Text('🇪🇺', style: TextStyle(fontSize: 32)),

                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'GDPR Compliant',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'EU Data Protection',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.verified_user, color: Colors.white, size: 24),
                          ],
                        ),
                        SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PrivacySettingsScreen()),
                            );
                          },
                          icon: Icon(Icons.settings, size: 18),
                          label: Text('View Privacy Settings'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white, width: 2),
                            minimumSize: Size(double.infinity, 44),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatColumn(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.green[700], size: 24),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[700]),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TranslatedText(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
