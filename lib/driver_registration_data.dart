import 'dart:io';

/// Carries everything collected across the registration screens
/// (personal details -> own/agency vehicle details) so that nothing is
/// written to Supabase until the driver has verified their phone number
/// via OTP. Only after verifyOTP() succeeds do we have a real
/// auth.currentUser.id to use as driver_profiles.id, so this object is
/// what gets passed forward instead of a driverId string.
class DriverRegistrationData {
  String firstName = '';
  String lastName = '';
  String phone = '';
  String emergencyContact = '';
  String address1 = '';
  String city = '';
  String pin = '';
  String? ambulanceType;

  File? profilePhoto;
  File? licensePhoto;
  File? aadharPhoto;

  /// "own" or "agency"
  String? registrationType;

  // Own vehicle fields
  String? vehicleNo;

  // Agency fields
  String? agencyName;
  String? agencyNumber;
  String? agencyAddress;
  String? agencyCity;
  String? agencyPincode;
  String? agencyVehicleCount;
  String? agencyDriverCount;
}
