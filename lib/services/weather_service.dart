import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherService {
  Future<Map<String, dynamic>> getWeather() async {
    try {
      final Position? position = await _getUserLocation();

      if (position == null) {
        return _error(
          "Could not get device location. Check app location permission and try again.",
        );
      }

      final double lat = position.latitude;
      final double lon = position.longitude;

      final String url =
          "https://api.open-meteo.com/v1/forecast"
          "?latitude=$lat"
          "&longitude=$lon"
          "&current=temperature_2m,relative_humidity_2m";

      print("Calling Open-Meteo API:");
      print(url);

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      print("Open-Meteo status: ${response.statusCode}");
      print("Open-Meteo body: ${response.body}");

      if (response.statusCode != 200) {
        return _error("Open-Meteo failed with status ${response.statusCode}");
      }

      final data = jsonDecode(response.body);

      if (data["current"] == null) {
        return _error("Current weather data not found.");
      }

      final double temperature =
      data["current"]["temperature_2m"].toDouble();

      final double humidity =
      data["current"]["relative_humidity_2m"].toDouble();

      return {
        "success": true,
        "temperature": temperature,
        "humidity": humidity,
        "message": "Weather updated using device location",
        "latitude": lat,
        "longitude": lon,
      };
    } catch (e) {
      print("Weather service error: $e");

      return _error("Weather error: $e");
    }
  }

  Future<Position?> _getUserLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        print("Location service is OFF");
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      print("Current location permission: $permission");

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        print("Permission after request: $permission");
      }

      if (permission == LocationPermission.denied) {
        print("Location permission denied");
        return null;
      }

      if (permission == LocationPermission.deniedForever) {
        print("Location permission permanently denied");
        return null;
      }

      final Position? lastKnown = await Geolocator.getLastKnownPosition();

      if (lastKnown != null) {
        print(
          "Using last known location: "
              "${lastKnown.latitude}, ${lastKnown.longitude}",
        );

        return lastKnown;
      }

      print("No last known location. Trying position stream...");

      try {
        final Position streamPosition = await Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            distanceFilter: 0,
          ),
        ).first.timeout(const Duration(seconds: 15));

        print(
          "Using stream location: "
              "${streamPosition.latitude}, ${streamPosition.longitude}",
        );

        return streamPosition;
      } on TimeoutException {
        print("Position stream timed out.");
      }

      print("Trying getCurrentPosition...");

      final Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 20),
      );

      print(
        "Using current location: "
            "${currentPosition.latitude}, ${currentPosition.longitude}",
      );

      return currentPosition;
    } catch (e) {
      print("Location error: $e");
      return null;
    }
  }

  Map<String, dynamic> _error(String message) {
    return {
      "success": false,
      "temperature": null,
      "humidity": null,
      "message": message,
      "latitude": null,
      "longitude": null,
    };
  }
}