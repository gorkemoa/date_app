import 'dart:typed_data';

import 'expertise_item_model.dart';

class RegistrationDraftModel {
  final String phoneNumber;
  final String otpCode;
  final String referralCode;
  final String displayName;
  final Uint8List? photoBytes;
  final String? photoFileName;
  final String occupation;
  final String bio;
  final Uint8List? cvBytes;
  final String? cvFileName;
  final List<String> selectedInterests;
  final List<ExpertiseItem> selectedExpertise;
  final bool linkedInConnected;

  const RegistrationDraftModel({
    required this.phoneNumber,
    required this.otpCode,
    required this.referralCode,
    required this.displayName,
    this.photoBytes,
    this.photoFileName,
    required this.occupation,
    required this.bio,
    this.cvBytes,
    this.cvFileName,
    required this.selectedInterests,
    required this.selectedExpertise,
    required this.linkedInConnected,
  });

  static const RegistrationDraftModel empty = RegistrationDraftModel(
    phoneNumber: '',
    otpCode: '',
    referralCode: '',
    displayName: '',
    photoBytes: null,
    photoFileName: null,
    occupation: '',
    bio: '',
    cvBytes: null,
    cvFileName: null,
    selectedInterests: [],
    selectedExpertise: [],
    linkedInConnected: false,
  );

  RegistrationDraftModel copyWith({
    String? phoneNumber,
    String? otpCode,
    String? referralCode,
    String? displayName,
    Uint8List? photoBytes,
    String? photoFileName,
    String? occupation,
    String? bio,
    Uint8List? cvBytes,
    String? cvFileName,
    List<String>? selectedInterests,
    List<ExpertiseItem>? selectedExpertise,
    bool? linkedInConnected,
  }) {
    return RegistrationDraftModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otpCode: otpCode ?? this.otpCode,
      referralCode: referralCode ?? this.referralCode,
      displayName: displayName ?? this.displayName,
      photoBytes: photoBytes ?? this.photoBytes,
      photoFileName: photoFileName ?? this.photoFileName,
      occupation: occupation ?? this.occupation,
      bio: bio ?? this.bio,
      cvBytes: cvBytes ?? this.cvBytes,
      cvFileName: cvFileName ?? this.cvFileName,
      selectedInterests: selectedInterests ?? this.selectedInterests,
      selectedExpertise: selectedExpertise ?? this.selectedExpertise,
      linkedInConnected: linkedInConnected ?? this.linkedInConnected,
    );
  }
}
