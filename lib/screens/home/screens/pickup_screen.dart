import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Custom class to manage map position
class MapPosition {
  final LatLng center;
  final double zoom;

  MapPosition({required this.center, required this.zoom});
}

class PickupScreen extends StatefulWidget {
  const PickupScreen({super.key});

  @override
  PickupScreenState createState() => PickupScreenState();
}

class PickupScreenState extends State<PickupScreen> {
  // Default location: Cairo, Egypt
  LatLng _location = LatLng(30.0444, 31.2357);
  double _zoom = 13.0;
  final MapController _mapController = MapController();

  void _onMapMoved(MapPosition position) {
    setState(() {
      _location = position.center;
      _zoom = position.zoom;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent, // Transparent Scaffold
        appBar: AppBar(
          title: const Text("Request Pickup"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        body: Stack(
          children: [
            // Map behind everything
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _location,
                initialZoom: _zoom,
                onTap: (tapPosition, point) {
                  setState(() {
                    _location = point;
                  });
                },
                onPositionChanged: (position, hasGesture) {
                  _onMapMoved(MapPosition(
                    center: position.center,
                    zoom: position.zoom,
                  ));
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _location,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Floating button
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Location Confirmed"),
                      content: Text(
                          "You have confirmed the pickup at: $_location"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  // ignore: deprecated_member_use
                  backgroundColor: Colors.white.withOpacity(0.9),
                  foregroundColor: Colors.black,
                  elevation: 8,
                  shadowColor: Colors.black38,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text("Confirm Pickup Location"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
