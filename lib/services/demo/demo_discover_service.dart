import '../../core/constants/app_constants.dart';
import '../../models/common/api_error.dart';
import '../../models/common/base_response.dart';
import '../../models/discover/discover_card_model.dart';
import '../interfaces/i_discover_service.dart';

class DemoDiscoverService implements IDiscoverService {
  // Mutable liste — connect/pass yapıldıkça güncellenir
  final List<DiscoverCardModel> _cards = [
    const DiscoverCardModel(
      id: '1',
      name: 'Ayşe',
      age: 26,
      bio: 'Müzik, kahve ve yeni yerler keşfetmek. Hayatı basit tutalım.',
      occupation: 'UX Designer',
      location: 'İstanbul',
      photoUrls: ['https://i.pravatar.cc/600?img=1'],
      interests: ['Müzik', 'Tasarım', 'Seyahat', 'Kafe Kültürü'],
      isVerified: true,
      distance: 2.4,
      compatibilityScore: 0.87,
    ),
    const DiscoverCardModel(
      id: '2',
      name: 'Zeynep',
      age: 28,
      bio: 'Kitap kurdu, amatör fotoğrafçı. Yeni projeler için doğru ekibi arıyorum.',
      occupation: 'Mimar',
      location: 'İstanbul',
      photoUrls: ['https://i.pravatar.cc/600?img=2'],
      interests: ['Fotoğrafçılık', 'Kitap', 'Tasarım', 'Girişimcilik'],
      isVerified: true,
      distance: 5.1,
      compatibilityScore: 0.79,
    ),
    const DiscoverCardModel(
      id: '3',
      name: 'Elif',
      age: 24,
      bio: 'Spor ve seyahat tutkunu. Yeni insanlarla yeni başlangıçlar yapmaya hazırım.',
      occupation: 'Pazarlama Uzmanı',
      location: 'Kadıköy',
      photoUrls: ['https://i.pravatar.cc/600?img=3'],
      interests: ['Spor', 'Seyahat', 'Pazarlama', 'Sosyal Medya'],
      isVerified: false,
      distance: 3.7,
      compatibilityScore: 0.72,
    ),
    const DiscoverCardModel(
      id: '4',
      name: 'Selin',
      age: 27,
      bio: 'Gastronomi dünyasının içindeyim. İçerik üretiyorum, hikayeler anlatıyorum.',
      occupation: 'İçerik Üreticisi',
      location: 'Beşiktaş',
      photoUrls: ['https://i.pravatar.cc/600?img=4'],
      interests: ['Yemek', 'Seyahat', 'İçerik Üretimi', 'Video'],
      isVerified: true,
      distance: 8.2,
      compatibilityScore: 0.65,
    ),
    const DiscoverCardModel(
      id: '5',
      name: 'Deniz',
      age: 29,
      bio: 'Yazılım geliştirici, müzisyen ve fırsat buldukça dağcı.',
      occupation: 'Software Engineer',
      location: 'Üsküdar',
      photoUrls: ['https://i.pravatar.cc/600?img=5'],
      interests: ['Yazılım', 'Müzik', 'AI / ML', 'Podcast'],
      isVerified: true,
      distance: 11.0,
      compatibilityScore: 0.91,
    ),
    const DiscoverCardModel(
      id: '6',
      name: 'Kaan',
      age: 30,
      bio: 'Makine öğrenmesi meraklısı. Veriden anlam çıkarmak benim işim.',
      occupation: 'ML Engineer',
      location: 'Maslak',
      photoUrls: ['https://i.pravatar.cc/600?img=12'],
      interests: ['AI / ML', 'Veri Bilimi', 'Yazılım', 'Podcast'],
      isVerified: true,
      distance: 6.3,
      compatibilityScore: 0.88,
    ),
    const DiscoverCardModel(
      id: '7',
      name: 'Cem',
      age: 27,
      bio: 'Startup kurmak isteyenlerle aynı masada oturmak için varım. SaaS odaklı.',
      occupation: 'Product Manager',
      location: 'Levent',
      photoUrls: ['https://i.pravatar.cc/600?img=15'],
      interests: ['Girişimcilik', 'SaaS', 'Fintech', 'Pazarlama'],
      isVerified: true,
      distance: 4.1,
      compatibilityScore: 0.83,
    ),
    const DiscoverCardModel(
      id: '8',
      name: 'Berk',
      age: 31,
      bio: 'Altyapıyı sevenler için: k8s, terraform ve iyi kahve.',
      occupation: 'DevOps Engineer',
      location: 'Şişli',
      photoUrls: ['https://i.pravatar.cc/600?img=18'],
      interests: ['DevOps', 'Yazılım', 'Podcast', 'Kafe Kültürü'],
      isVerified: false,
      distance: 9.7,
      compatibilityScore: 0.76,
    ),
    const DiscoverCardModel(
      id: '9',
      name: 'İrem',
      age: 25,
      bio: 'İçerik üreticisi, podcast yayıncısı. Dijital dünyada söz üretiyorum.',
      occupation: 'Content Creator',
      location: 'Beşiktaş',
      photoUrls: ['https://i.pravatar.cc/600?img=9'],
      interests: ['İçerik Üretimi', 'Sosyal Medya', 'Video', 'Podcast'],
      isVerified: true,
      distance: 3.2,
      compatibilityScore: 0.74,
    ),
    const DiscoverCardModel(
      id: '10',
      name: 'Mert',
      age: 28,
      bio: 'Flutter ile güzel ürünler çıkarmak istiyorum. Open source sevdalısı.',
      occupation: 'Mobile Developer',
      location: 'Kadıköy',
      photoUrls: ['https://i.pravatar.cc/600?img=20'],
      interests: ['Mobil Geliştirme', 'Yazılım', 'AI / ML', 'Girişimcilik'],
      isVerified: true,
      distance: 7.5,
      compatibilityScore: 0.85,
    ),
    const DiscoverCardModel(
      id: '11',
      name: 'Ceren',
      age: 26,
      bio: 'Renk ve form dili konuşurum. Marka kimliği ve UI tasarımı benim alanım.',
      occupation: 'UI/Brand Designer',
      location: 'Karaköy',
      photoUrls: ['https://i.pravatar.cc/600?img=21'],
      interests: ['Grafik Tasarım', 'Tasarım', 'Fotoğrafçılık', 'Sosyal Medya'],
      isVerified: false,
      distance: 5.8,
      compatibilityScore: 0.78,
    ),
    const DiscoverCardModel(
      id: '12',
      name: 'Ali',
      age: 32,
      bio: 'Fintech ile teknolojinin kesiştiği yerde çalışıyorum. Kitap ve podcast bağımlısı.',
      occupation: 'Fintech Lead',
      location: 'Maslak',
      photoUrls: ['https://i.pravatar.cc/600?img=33'],
      interests: ['Fintech', 'Girişimcilik', 'Kitap', 'Podcast'],
      isVerified: true,
      distance: 13.1,
      compatibilityScore: 0.80,
    ),
  ];

  @override
  Future<BaseResponse<List<DiscoverCardModel>>> getDiscoverCards({int page = 1}) async {
    await Future.delayed(AppConstants.mediumDelay);
    if (_cards.isEmpty) {
      return BaseResponse.empty(message: 'Yeni kişi kalmadı');
    }
    return BaseResponse.success(data: List.unmodifiable(_cards));
  }

  @override
  Future<BaseResponse<DiscoverCardModel>> getCardDetail(String userId) async {
    await Future.delayed(AppConstants.shortDelay);
    final card = _cards.where((c) => c.id == userId).firstOrNull;
    if (card == null) {
      return BaseResponse.failure(error: ApiError.notFoundError);
    }
    return BaseResponse.success(data: card);
  }

  @override
  Future<BaseResponse<void>> swipeRight(String userId) async {
    await Future.delayed(AppConstants.shortDelay);
    _cards.removeWhere((c) => c.id == userId);
    return BaseResponse.success(data: null, message: 'Beğenildi');
  }

  @override
  Future<BaseResponse<void>> swipeLeft(String userId) async {
    await Future.delayed(AppConstants.shortDelay);
    _cards.removeWhere((c) => c.id == userId);
    return BaseResponse.success(data: null, message: 'Geçildi');
  }

  @override
  Future<BaseResponse<void>> superLike(String userId) async {
    await Future.delayed(AppConstants.shortDelay);
    _cards.removeWhere((c) => c.id == userId);
    return BaseResponse.success(data: null, message: 'Süper beğeni gönderildi!');
  }
}
