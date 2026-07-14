import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'driver_location_service.dart';

class DriverTrackingService {

  Timer? _timer;

  final String driverId;

  final String ambulanceType;

  DriverTrackingService({

    required this.driverId,

    required this.ambulanceType,

  });

  void startTracking() {

    _timer?.cancel();

    _timer = Timer.periodic(

      const Duration(seconds: 2),

      (_) async {

        try {

          Position position =
              await Geolocator.getCurrentPosition(

            desiredAccuracy: LocationAccuracy.high,

          );

          bool success =
              await DriverLocationService.updateLocation(

            driverId: driverId,

            latitude: position.latitude,

            longitude: position.longitude,

            ambulanceType: ambulanceType,

            online: true,

          );

          if (success) {

            print(
              "Location Updated : "
              "${position.latitude}, ${position.longitude}",
            );

          } else {

            print("Location Update Failed");

          }

        } catch (e) {

          print("Tracking Error : $e");

        }

      },

    );

  }

  void stopTracking() {

    _timer?.cancel();

  }

}