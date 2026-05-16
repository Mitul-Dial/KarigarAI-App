import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_colors.dart';

/// OpenStreetMap picker — tap map to set pin, Done returns address string.
class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final _mapController = MapController();
  LatLng _pin = const LatLng(24.8607, 67.0011); // Karachi default
  String _label = 'Selected location';

  void _onTap(TapPosition _, LatLng point) {
    setState(() {
      _pin = point;
      _label =
          'Lat ${point.latitude.toStringAsFixed(4)}, Lng ${point.longitude.toStringAsFixed(4)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick location on map'),
        backgroundColor: kWhite,
        foregroundColor: kText,
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _pin,
                initialZoom: 13,
                onTap: _onTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.ustaad_ai_app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _pin,
                      width: 48,
                      height: 48,
                      child: const Icon(
                        Icons.location_pin,
                        color: kBlue,
                        size: 48,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: kWhite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _label,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: kText),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tap on the map to move the pin',
                  style: TextStyle(fontSize: 12, color: kTextMuted),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      'Map location: ${_pin.latitude.toStringAsFixed(5)}, ${_pin.longitude.toStringAsFixed(5)}',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBlue,
                    foregroundColor: kWhite,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
