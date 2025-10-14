import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';  // ← ADD THIS for cos/sin
import 'main.dart';

class PrivacyManager {
  static const String _keyPrivacyAccepted = 'privacy_accepted';
  static const String _keyLocationConsent = 'location_consent';
  static const String _keyCameraConsent = 'camera_consent';
  static const String _keyDataProcessingConsent = 'data_processing_consent';
  static const String _keyCommunityConsent = 'community_consent';
  
  static Future<bool> hasAcceptedPrivacy() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPrivacyAccepted) ?? false;
  }
  
  static Future<void> acceptPrivacy() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPrivacyAccepted, true);
  }
  
  static Future<bool> hasConsent(String type) async {
    final prefs = await SharedPreferences.getInstance();
    switch (type) {
      case 'location':
        return prefs.getBool(_keyLocationConsent) ?? false;
      case 'camera':
        return prefs.getBool(_keyCameraConsent) ?? false;
      case 'data':
        return prefs.getBool(_keyDataProcessingConsent) ?? false;
      case 'community':
        return prefs.getBool(_keyCommunityConsent) ?? false;
      default:
        return false;
    }
  }
  
  static Future<void> saveConsent(String type, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    switch (type) {
      case 'location':
        await prefs.setBool(_keyLocationConsent, value);
        break;
      case 'camera':
        await prefs.setBool(_keyCameraConsent, value);
        break;
      case 'data':
        await prefs.setBool(_keyDataProcessingConsent, value);
        break;
      case 'community':
        await prefs.setBool(_keyCommunityConsent, value);
        break;
    }
  }
  
  static Future<void> resetConsents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

// GDPR Welcome Screen with EU FLAG
class PrivacyWelcomeScreen extends StatefulWidget {
  @override
  State<PrivacyWelcomeScreen> createState() => _PrivacyWelcomeScreenState();
}

class _PrivacyWelcomeScreenState extends State<PrivacyWelcomeScreen> {
  bool _locationConsent = false;
  bool _cameraConsent = false;
  bool _dataConsent = false;
  bool _communityConsent = false;
  
  bool get _allRequired => _dataConsent && _cameraConsent;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              
              // EU FLAG + SHIELD
              // EU FLAG
              Center(
                child: Text('🇪🇺', style: TextStyle(fontSize: 100)),
              ),

              
              SizedBox(height: 24),
              
              Text(
                'Welcome to AgriSnap',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 12),
              
              Text(
                'Your Privacy Matters',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 32),
              
              Text(
                'We need your consent to provide the best experience while respecting your privacy and complying with GDPR.',
                style: TextStyle(fontSize: 14, height: 1.5),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 32),
              
              _buildConsentSection(
                'Required',
                [
                  _buildConsentTile(
                    'Camera & Photo Access',
                    'Required to scan plant leaves for disease detection',
                    Icons.camera_alt,
                    _cameraConsent,
                    (value) => setState(() => _cameraConsent = value),
                    required: true,
                  ),
                  _buildConsentTile(
                    'Data Processing',
                    'Process images using AI for disease detection',
                    Icons.analytics,
                    _dataConsent,
                    (value) => setState(() => _dataConsent = value),
                    required: true,
                  ),
                ],
              ),
              
              SizedBox(height: 24),
              
              _buildConsentSection(
                'Optional (Enhance Your Experience)',
                [
                  _buildConsentTile(
                    'Location Services',
                    'Get region-specific disease insights and weather data',
                    Icons.location_on,
                    _locationConsent,
                    (value) => setState(() => _locationConsent = value),
                    required: false,
                  ),
                  _buildConsentTile(
                    'Community Features',
                    'Share and view posts from nearby farmers',
                    Icons.people,
                    _communityConsent,
                    (value) => setState(() => _communityConsent = value),
                    required: false,
                  ),
                ],
              ),
              
              SizedBox(height: 32),
              
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Your Rights (GDPR)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    _buildRightItem('Access your data anytime'),
                    _buildRightItem('Request data deletion'),
                    _buildRightItem('Withdraw consent anytime'),
                    _buildRightItem('Data portability'),
                    _buildRightItem('No data sold to third parties'),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _allRequired ? _handleAccept : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  minimumSize: Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  _allRequired ? 'Accept & Continue' : 'Accept Required Items First',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              Center(
                child: TextButton(
                  onPressed: _showPrivacyPolicy,
                  child: Text(
                    'Read Full Privacy Policy',
                    style: TextStyle(
                      color: Colors.green[700],
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildConsentSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 12),
        ...children,
      ],
    );
  }
  
  Widget _buildConsentTile(
    String title,
    String description,
    IconData icon,
    bool value,
    Function(bool) onChanged, {
    required bool required,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: value ? Colors.green[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? Colors.green[300]! : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: (val) => onChanged(val ?? false),
        title: Row(
          children: [
            Icon(icon, color: Colors.green[700], size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            if (required)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'REQUIRED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            description,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
        activeColor: Colors.green[700],
      ),
    );
  }
  
  Widget _buildRightItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.blue[700]),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.blue[900]),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _handleAccept() async {
    await PrivacyManager.acceptPrivacy();
    await PrivacyManager.saveConsent('camera', _cameraConsent);
    await PrivacyManager.saveConsent('data', _dataConsent);
    await PrivacyManager.saveConsent('location', _locationConsent);
    await PrivacyManager.saveConsent('community', _communityConsent);
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MainNavigationScreen()),
    );
  }
  
  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Text(
            'AgriSnap Privacy Policy\n\n'
            '1. Data Collection: We collect photos of plant leaves and location data (with consent) to provide disease detection services.\n\n'
            '2. Data Usage: Images are processed using AI models. Location data enhances regional insights.\n\n'
            '3. Data Storage: All data is stored securely and encrypted.\n\n'
            '4. Data Sharing: We never sell your data. Images may be anonymized for model improvement.\n\n'
            '5. Your Rights: You can access, delete, or export your data anytime.\n\n'
            '6. Contact: support@agrisnap.com\n\n'
            'Last updated: October 2025',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

// PRIVACY SETTINGS SCREEN
class PrivacySettingsScreen extends StatefulWidget {
  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _locationConsent = false;
  bool _cameraConsent = false;
  bool _dataConsent = false;
  bool _communityConsent = false;
  
  @override
  void initState() {
    super.initState();
    _loadConsents();
  }
  
  Future<void> _loadConsents() async {
    final location = await PrivacyManager.hasConsent('location');
    final camera = await PrivacyManager.hasConsent('camera');
    final data = await PrivacyManager.hasConsent('data');
    final community = await PrivacyManager.hasConsent('community');
    
    setState(() {
      _locationConsent = location;
      _cameraConsent = camera;
      _dataConsent = data;
      _communityConsent = community;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Settings'),
        backgroundColor: Colors.green[700],
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Text(
            'Manage Your Data',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Control what data AgriSnap can use. Changes take effect immediately.',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 24),
          
          SwitchListTile(
            value: _locationConsent,
            onChanged: (val) async {
              await PrivacyManager.saveConsent('location', val);
              setState(() => _locationConsent = val);
            },
            title: Text('Location Services'),
            subtitle: Text('Regional disease insights'),
            activeColor: Colors.green[700],
          ),
          
          SwitchListTile(
            value: _communityConsent,
            onChanged: (val) async {
              await PrivacyManager.saveConsent('community', val);
              setState(() => _communityConsent = val);
            },
            title: Text('Community Features'),
            subtitle: Text('Share with nearby farmers'),
            activeColor: Colors.green[700],
          ),
          
          Divider(height: 32),
          
          ListTile(
            leading: Icon(Icons.download, color: Colors.blue),
            title: Text('Download My Data'),
            subtitle: Text('Export all your data (GDPR)'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Data export will be emailed to you')),
              );
            },
          ),
          
          ListTile(
            leading: Icon(Icons.delete_forever, color: Colors.red),
            title: Text('Delete My Account'),
            subtitle: Text('Permanently delete all data'),
            onTap: _showDeleteConfirmation,
          ),
        ],
      ),
    );
  }
  
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account?'),
        content: Text('This will permanently delete all your data. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await PrivacyManager.resetConsents();
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Account deleted successfully')),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
