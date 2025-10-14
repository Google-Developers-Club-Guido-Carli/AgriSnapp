import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'translated_text.dart';

class CommunityMapScreen extends StatefulWidget {
  @override
  State<CommunityMapScreen> createState() => _CommunityMapScreenState();
}

class _CommunityMapScreenState extends State<CommunityMapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  
  static const LatLng _mediterraneanCenter = LatLng(38.0, 15.0);
  
  final List<Map<String, dynamic>> farmers = [
    {
      'name': 'Yasemin Ates',
      'location': 'Istanbul, Turkey',
      'lat': 41.0082,
      'lon': 28.9784,
      'status': 'No active outbreaks',
      'lastScan': '2 hours ago',
      'avatar': '👩‍🌾',
      'isYou': true,
    },
    {
      'name': 'Hoca Dede',
      'location': 'Elazig, Turkey',
      'lat': 38.6810,
      'lon': 39.2264,
      'status': 'Healthy grove',
      'lastScan': '4 hours ago',
      'avatar': '👨‍🌾',
      'isYou': false,
    },
    {
      'name': 'Giulio Presaghi',
      'location': 'Bracciano, Italy',
      'lat': 42.1033,
      'lon': 12.1703,
      'status': 'Monitoring for diseases',
      'lastScan': '5 hours ago',
      'avatar': '👨‍🌾',
      'isYou': false,
    },
    {
      'name': 'Rebecca Raible',
      'location': 'Lucerne, Switzerland',
      'lat': 47.0502,
      'lon': 8.3093,
      'status': 'Organic farming',
      'lastScan': '1 day ago',
      'avatar': '👩‍🌾',
      'isYou': false,
    },
    {
      'name': 'Alayna Shariff',
      'location': 'Granada, Spain',
      'lat': 37.1773,
      'lon': -3.5986,
      'status': 'Peacock Spot detected',
      'lastScan': '3 hours ago',
      'avatar': '👩‍🌾',
      'isYou': false,
    },
    {
      'name': 'Quynh Anh Tran',
      'location': 'Souss Valley, Morocco',
      'lat': 30.4278,
      'lon': -9.5981,
      'status': 'Treating Olive Knot',
      'lastScan': '1 day ago',
      'avatar': '👩‍🌾',
      'isYou': false,
    },
    {
    'name': 'Johnpaul Ifeanyichukwu Egwuatu',
    'location': 'Castiglia, Italy',
    'lat': 44.4742,
    'lon': 11.4369,
    'status': 'Preparing for harvest',
    'lastScan': '5 hours ago',
    'avatar': '👨‍🌾',
    'isYou': false,
    },
    {
    'name': 'Maria Rossi',
    'location': 'Palermo, Italy',
    'lat': 38.1157,
    'lon': 13.3615,
    'status': 'Preparing for harvest',
    'lastScan': '11 hours ago',
    'avatar': '👨‍🌾',
    'isYou': false,
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
          onTap: () => _showFarmerDetails(farmer),
        ),
      );
    }
    setState(() {});
  }
  
  void _showFarmerDetails(Map<String, dynamic> farmer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: farmer['isYou'] ? Colors.green[100] : Colors.blue[100],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(farmer['avatar'], style: TextStyle(fontSize: 32)),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farmer['name'],
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(farmer['location'], style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 10),
            
            _buildInfoRow(Icons.healing, 'Status', farmer['status']),
            SizedBox(height: 10),
            _buildInfoRow(Icons.access_time, 'Last Scan', farmer['lastScan']),
            
            SizedBox(height: 20),
            
            if (!farmer['isYou']) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.message),
                      label: TranslatedText('Message'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.info_outline),
                      label: TranslatedText('View Profile'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green[700],
                        side: BorderSide(color: Colors.green[700]!),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.green[700], size: 20),
        SizedBox(width: 10),
        Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: TranslatedText(value, style: TextStyle(color: Colors.grey[700])),
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TranslatedText('Farmer Network Map'),
        backgroundColor: Colors.green[700],
      ),
      body: Stack(
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
          ),
          
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLegendItem(Colors.green, 'You'),
                      _buildLegendItem(Colors.blue, 'Farmers'),
                    ],
                  ),
                  SizedBox(height: 8),
                  TranslatedText(
                    'Tap markers to see details',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6),
        TranslatedText(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
