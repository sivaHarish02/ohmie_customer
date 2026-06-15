import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:ohmie_customer/feature/location/controllers/location_controller.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  // ── Colours ──────────────────────────────────────────────────────────────
  static const Color _primary = Color(0xFFFF6B35);
  static const Color _bg = Color(0xFF1A1A2E);
  static const Color _card = Color(0xFF0F3460);

  // ── Map state ────────────────────────────────────────────────────────────
  GoogleMapController? _mapController;
  LatLng _pickedLatLng = const LatLng(20.5937, 78.9629); // India center

  String _pickedAddress = 'Move the map to pin your location';
  bool _isGeocoding = false;

  Timer? _debounce;

  late final LocationController _lc;

  // ── Dark map style ────────────────────────────────────────────────────────
  static const String _darkMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#1a1a2e"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#8ec3b9"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#1a3646"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#16213e"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#255763"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0f3460"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]}
]
''';

  @override
  void initState() {
    super.initState();
    _lc = Get.find<LocationController>();

    // Start at existing location if already set
    if (_lc.hasLocation) {
      _pickedLatLng = LatLng(_lc.latitude.value!, _lc.longitude.value!);
      _pickedAddress = _lc.address.value;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // ── Camera move handling ──────────────────────────────────────────────────
  void _onCameraMove(CameraPosition position) {
    setState(() {
      _pickedLatLng = position.target;
    });
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _reverseGeocode);
  }

  Future<void> _reverseGeocode() async {
    if (!mounted) return;
    setState(() => _isGeocoding = true);
    try {
      final placemarks = await placemarkFromCoordinates(
        _pickedLatLng.latitude,
        _pickedLatLng.longitude,
      );
      if (!mounted) return;
      setState(() {
        _pickedAddress =
            _formatAddress(placemarks.isNotEmpty ? placemarks.first : null);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pickedAddress = '${_pickedLatLng.latitude.toStringAsFixed(5)}, '
            '${_pickedLatLng.longitude.toStringAsFixed(5)}';
      });
    } finally {
      if (mounted) setState(() => _isGeocoding = false);
    }
  }

  // ── Confirm ───────────────────────────────────────────────────────────────
  Future<void> _confirmLocation() async {
    await _lc.setFromMap(_pickedLatLng.latitude, _pickedLatLng.longitude);
    Get.back();
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
        title: Text(
          'Pin Your Location',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ── Map ───────────────────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _pickedLatLng,
              zoom: _lc.hasLocation ? 15 : 5,
            ),
            style: _darkMapStyle,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onCameraMove: _onCameraMove,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
          ),

          // ── Crosshair pin (always center) ─────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 8.r,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  padding: EdgeInsets.all(6.r),
                  child: Icon(Icons.location_pin, color: _primary, size: 28.r),
                ),
                Container(
                  width: 2.w,
                  height: 10.h,
                  color: _primary.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),

          // ── My location FAB ───────────────────────────────────────────────
          Positioned(
            top: 16.h,
            right: 16.w,
            child: FloatingActionButton.small(
              heroTag: 'my_location_fab',
              backgroundColor: const Color(0xFF16213E),
              onPressed: _goToCurrentLocation,
              child:
                  Icon(Icons.my_location_rounded, color: _primary, size: 20.r),
            ),
          ),

          // ── Bottom address card + confirm button ──────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black38, blurRadius: 12)
                ],
              ),
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 36.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 14.h),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.place_rounded, color: _primary, size: 20.r),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected Location',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 11.sp,
                                letterSpacing: 0.6,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            _isGeocoding
                                ? Row(
                                    children: [
                                      SizedBox(
                                        width: 14.r,
                                        height: 14.r,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          color: Color(0xFFFF6B35),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'Finding address…',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    _pickedAddress,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.sp,
                                      height: 1.4,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton.icon(
                      onPressed: _isGeocoding ? null : _confirmLocation,
                      icon:
                          Icon(Icons.check_circle_outline_rounded, size: 20.r),
                      label: Text(
                        'Confirm Location',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        disabledBackgroundColor:
                            _primary.withValues(alpha: 0.5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 4,
                        shadowColor: _primary.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Future<void> _goToCurrentLocation() async {
    try {
      final pos = await _lc.getCurrentLocation().then((_) async {
        if (_lc.hasLocation) {
          return LatLng(_lc.latitude.value!, _lc.longitude.value!);
        }
        return null;
      });
      if (pos != null && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(CameraPosition(target: pos, zoom: 16)),
        );
      }
    } catch (_) {}
  }

  String _formatAddress(Placemark? p) {
    if (p == null) return 'Unknown location';
    final parts = <String>[];
    if (p.name != null && p.name!.isNotEmpty) parts.add(p.name!);
    if (p.subLocality != null && p.subLocality!.isNotEmpty) {
      parts.add(p.subLocality!);
    }
    if (p.locality != null && p.locality!.isNotEmpty) parts.add(p.locality!);
    if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty) {
      parts.add(p.administrativeArea!);
    }
    if (p.postalCode != null && p.postalCode!.isNotEmpty) {
      parts.add(p.postalCode!);
    }
    if (p.country != null && p.country!.isNotEmpty) parts.add(p.country!);
    return parts.isNotEmpty ? parts.join(', ') : 'Unknown location';
  }
}
