import '../../core/constants/app_constants.dart';
import '../../models/common/api_error.dart';
import '../../models/common/base_response.dart';
import '../../models/discover/discover_card_model.dart';
import '../interfaces/i_discover_service.dart';

class DemoDiscoverService implements IDiscoverService {
  // Mutable liste — swipe yapıldıkça güncellenir
  final List<DiscoverCardModel> _cards = [
    const DiscoverCardModel(
      id: '1',
      name: 'Ayşe',
      age: 26,
      bio: 'Müzik, kahve ve yeni yerler keşfetmek. Hayatı basit tutalım.',
      occupation: 'UX Designer',
      location: 'İstanbul',
      photoUrls: ['https://i.pravatar.cc/600?img=1'],
      interests: ['Müzik', 'Tasarım', 'Seyahat', 'Kahve'],
      isVerified: true,
      distance: 2.4,
      compatibilityScore: 0.87,
    ),
    const DiscoverCardModel(
      id: '2',
      name: 'Zeynep',
      age: 28,
      bio: 'Kitap kurdu, amatör fotoğrafçı. Sanat galerileri olmadan yaşayamam.',
      occupation: 'Mimar',
      location: 'İstanbul',
      photoUrls: ['https://i.pravatar.cc/600?img=2'],
      interests: ['Fotoğrafçılık', 'Mimari', 'Kitap', 'Sanat'],
      isVerified: true,
      distance: 5.1,
      compatibilityScore: 0.79,
    ),
    const DiscoverCardModel(
      id: '3',
      name: 'Elif',
      age: 24,
      bio: 'Yoga ve meditasyon. Huzurlu bir yaşam için doğru kişiyi arıyorum.',
      occupation: 'Yoga Eğitmeni',
      location: 'Kadıköy',
      photoUrls: ['https://i.pravatar.cc/600?img=3'],
      interests: ['Yoga', 'Meditasyon', 'Doğa', 'Vegan'],
      isVerified: false,
      distance: 3.7,
      compatibilityScore: 0.72,
    ),
    const DiscoverCardModel(
      id: '4',
      name: 'Selin',
      age: 27,
      bio: 'Gastronomi dünyasının içindeyim. Yeni lezzetler ve kültürler keşfetmeyi seviyorum.',
      occupation: 'Chef',
      location: 'Beşiktaş',
      photoUrls: ['https://i.pravatar.cc/600?img=4'],
      interests: ['Yemek', 'Mutfak', 'Seyahat', 'Kültür'],
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
      interests: ['Teknoloji', 'Müzik', 'Dağcılık', 'Kod'],
      isVerified: true,
      distance: 11.0,
      compatibilityScore: 0.91,
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
