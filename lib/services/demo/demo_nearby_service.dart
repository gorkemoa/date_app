import '../../core/constants/app_constants.dart';
import '../../models/common/base_response.dart';
import '../../models/nearby/nearby_user_model.dart';
import '../interfaces/i_nearby_service.dart';

class DemoNearbyService implements INearbyService {
  // Ben — İzmir Alsancak, Kahvecioğlu
  static const _me = NearbyUserModel(
    id: 'me',
    name: 'Ahmet',
    age: 28,
    photoUrl: 'https://randomuser.me/api/portraits/men/12.jpg',
    latitude: 38.4265,
    longitude: 27.1422,
    distanceKm: 0,
    isMe: true,
    occupation: 'Yazılımcı',
    venueName: 'Kahvecioğlu',
    wantToMeetWith: [
      'Tasarımcı', 'Grafik Tasarımcı', 'Pazarlamacı',
      'İçerik Üretici', 'Girişimci', 'Sosyal Medya Uzmanı',
    ],
  );

  static const _demoUsers = [
    // Selin — Grafik Tasarımcı, PUBLIC, Vapor Cafe (Alsancak ~150m)
    NearbyUserModel(
      id: 'n1',
      name: 'Selin',
      age: 26,
      photoUrl: 'https://randomuser.me/api/portraits/women/47.jpg',
      latitude: 38.4272,
      longitude: 27.1438,
      distanceKm: 0.15,
      isPrivate: false,
      occupation: 'Grafik Tasarımcı',
      bio: 'UI/UX tasarımcısıyım, SaaS ürünleri üzerinde çalışıyorum. '
          'Teknik kurucularla proje geliştirmeye hazırım.',
      meetGoal: 'Freelance proje ortağı arıyorum',
      venueName: 'Vapor Cafe',
      interests: ['UI/UX', 'Figma', 'Branding', 'Freelance'],
      wantToMeetWith: ['Yazılımcı', 'Girişimci', 'Proje Yöneticisi'],
    ),
    // Ayşe — Sosyal Medya Uzmanı, PRIVATE, Kordon Cafe (~220m)
    NearbyUserModel(
      id: 'n2',
      name: 'Ayşe',
      age: 28,
      photoUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
      latitude: 38.4253,
      longitude: 27.1448,
      distanceKm: 0.22,
      isPrivate: true,
      occupation: 'Sosyal Medya Uzmanı',
      venueName: 'Kordon Cafe',
      wantToMeetWith: ['Yazılımcı', 'Girişimci'],
    ),
    // Melis — İçerik Üretici, PUBLIC, Loca Cafe (~310m)
    NearbyUserModel(
      id: 'n3',
      name: 'Melis',
      age: 25,
      photoUrl: 'https://randomuser.me/api/portraits/women/49.jpg',
      latitude: 38.4280,
      longitude: 27.1452,
      distanceKm: 0.31,
      isPrivate: false,
      occupation: 'İçerik Üretici',
      bio: 'Tech içerikleri üretiyorum, kendi SaaS ürünü kurmak '
          'isteyen biriyle ortaklık arıyorum.',
      meetGoal: 'Network ve potansiyel proje ortağı',
      venueName: 'Loca Cafe',
      interests: ['İçerik Pazarlama', 'SEO', 'Teknoloji', 'Podcast'],
      wantToMeetWith: ['Yazılımcı', 'Girişimci', 'Startup'],
    ),
  ];

  @override
  Future<BaseResponse<List<NearbyUserModel>>> getNearbyUsers() async {
    await Future.delayed(AppConstants.mediumDelay);
    return BaseResponse.success(data: List.unmodifiable(_demoUsers));
  }

  @override
  Future<BaseResponse<NearbyUserModel>> getMyLocation() async {
    await Future.delayed(AppConstants.shortDelay);
    return BaseResponse.success(data: _me);
  }
}
