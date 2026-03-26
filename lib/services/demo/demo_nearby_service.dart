import '../../core/constants/app_constants.dart';
import '../../models/common/base_response.dart';
import '../../models/nearby/nearby_user_model.dart';
import '../interfaces/i_nearby_service.dart';

class DemoNearbyService implements INearbyService {
  // İzmir merkez koordinatları
  static const double _baseLat = 38.4192;
  static const double _baseLng = 27.1287;

  static const _me = NearbyUserModel(
    id: 'me',
    name: 'Ahmet',
    age: 28,
    photoUrl: 'https://i.pravatar.cc/200?img=12',
    latitude: _baseLat,
    longitude: _baseLng,
    distanceKm: 0,
    isMe: true,
    occupation: 'Product Manager',
  );

  static const _demoUsers = [
    NearbyUserModel(
      id: 'n1',
      name: 'Selin',
      age: 26,
      // Alsancak - İzmir
      photoUrl: 'https://i.pravatar.cc/200?img=47',
      latitude: 38.4361,
      longitude: 27.1441,
      distanceKm: 1.9,
      occupation: 'Grafik Tasarımcı',
    ),
    NearbyUserModel(
      id: 'n2',
      name: 'Zeynep',
      age: 27,
      // Konak civarı
      photoUrl: 'https://i.pravatar.cc/200?img=44',
      latitude: 38.4127,
      longitude: 27.1384,
      distanceKm: 0.8,
      occupation: 'Öğretmen',
    ),
    NearbyUserModel(
      id: 'n3',
      name: 'Elif',
      age: 25,
      // Bornova civarı
      photoUrl: 'https://i.pravatar.cc/200?img=48',
      latitude: 38.4620,
      longitude: 27.2190,
      distanceKm: 7.2,
      occupation: 'Avukat',
    ),
    NearbyUserModel(
      id: 'n4',
      name: 'Ayşe',
      age: 29,
      // Karşıyaka civarı
      photoUrl: 'https://i.pravatar.cc/200?img=46',
      latitude: 38.4570,
      longitude: 27.1120,
      distanceKm: 4.5,
      occupation: 'Doktor',
    ),
    NearbyUserModel(
      id: 'n5',
      name: 'Melis',
      age: 24,
      // Buca civarı
      photoUrl: 'https://i.pravatar.cc/200?img=49',
      latitude: 38.3840,
      longitude: 27.1760,
      distanceKm: 5.3,
      occupation: 'Mimar',
    ),
  ];

  @override
  Future<BaseResponse<List<NearbyUserModel>>> getNearbyUsers() async {
    await Future.delayed(AppConstants.mediumDelay);
    return BaseResponse.success(data: _demoUsers);
  }

  @override
  Future<BaseResponse<NearbyUserModel>> getMyLocation() async {
    await Future.delayed(AppConstants.shortDelay);
    return BaseResponse.success(data: _me);
  }
}
