import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationController extends GetxController {
  // ── Reactive state ─────────────────────────────────────────────────────────
  final Rxn<double> latitude = Rxn<double>();
  final Rxn<double> longitude = Rxn<double>();
  final RxString address = ''.obs;
  final RxBool isLocating = false.obs;

  /// 'current' | 'map'
  final RxString locationMode = 'current'.obs;

  // ── Derived ────────────────────────────────────────────────────────────────
  bool get hasLocation =>
      latitude.value != null &&
      longitude.value != null &&
      address.value.isNotEmpty;

  // ── Public actions ─────────────────────────────────────────────────────────

  /// Requests permission, fetches GPS position, reverse-geocodes to an address.
  Future<void> getCurrentLocation() async {
    isLocating.value = true;
    try {
      // 1. Permission
      final status = await Permission.location.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        if (status.isPermanentlyDenied) {
          Get.snackbar(
            'Permission Denied',
            'Location permission is permanently denied. '
                'Please enable it in app settings.',
            snackPosition: SnackPosition.BOTTOM,
            mainButton: TextButton(
              onPressed: openAppSettings,
              child: const Text('Settings',
                  style: TextStyle(color: Color(0xFFFF6B35))),
            ),
            duration: const Duration(seconds: 5),
          );
        } else {
          Get.snackbar(
            'Permission Required',
            'Location permission is needed to fetch your address.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        return;
      }

      // 2. Check service enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'Location Disabled',
          'Please enable location services on your device.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // 3. Get position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      // 4. Reverse geocode
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      latitude.value = position.latitude;
      longitude.value = position.longitude;
      address.value =
          _formatAddress(placemarks.isNotEmpty ? placemarks.first : null);
    } on PermissionDeniedException catch (_) {
      Get.snackbar(
        'Permission Denied',
        'Location access was denied.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Location Error',
        'Could not fetch your location. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLocating.value = false;
    }
  }

  /// Called from MapPickerScreen after the user pins a location.
  Future<void> setFromMap(double lat, double lng) async {
    isLocating.value = true;
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      latitude.value = lat;
      longitude.value = lng;
      address.value =
          _formatAddress(placemarks.isNotEmpty ? placemarks.first : null);
    } catch (e) {
      // Coordinates still saved even if reverse-geocoding fails
      latitude.value = lat;
      longitude.value = lng;
      address.value = '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
    } finally {
      isLocating.value = false;
    }
  }

  /// Resets all location data.
  void clearLocation() {
    latitude.value = null;
    longitude.value = null;
    address.value = '';
  }

  // ── Private ────────────────────────────────────────────────────────────────
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

    return parts.isNotEmpty
        ? parts.join(', ')
        : '${latitude.value?.toStringAsFixed(6)}, ${longitude.value?.toStringAsFixed(6)}';
  }
}
