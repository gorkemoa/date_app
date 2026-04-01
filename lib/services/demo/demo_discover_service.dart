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
      bio: 'Sade tasarımlar ve yenilikçi kullanıcı arayüzleri oluşturmayı seviyorum.',
      occupation: 'UX Designer',
      location: 'İstanbul',
      photoUrls: ['https://i.pravatar.cc/600?img=1'],
      interests: ['UX Designer', 'UI Designer', 'Product Designer'],
      isVerified: true,
      distance: 2.4,
      compatibilityScore: 0.87,
    ),
    const DiscoverCardModel(
      id: '2',
      name: 'Zeynep',
      age: 28,
      bio: 'Planlama, strateji ve operasyonlar benim işim. Agile prensiplerini benimsiyorum.',
      occupation: 'Product Manager',
      location: 'İstanbul',
      photoUrls: ['https://i.pravatar.cc/600?img=2'],
      interests: ['Product Manager', 'Project Manager', 'Agile Coach'],
      isVerified: true,
      distance: 5.1,
      compatibilityScore: 0.79,
    ),
    const DiscoverCardModel(
      id: '3',
      name: 'Elif',
      age: 24,
      bio: 'Marka stratejisi ve dijital büyüme odaklı çalışıyorum. Sosyal medya uzmanıyım.',
      occupation: 'Digital Marketing Specialist',
      location: 'Kadıköy',
      photoUrls: ['https://i.pravatar.cc/600?img=3'],
      interests: ['Digital Marketing Specialist', 'Social Media Manager', 'SEO Specialist'],
      isVerified: false,
      distance: 3.7,
      compatibilityScore: 0.72,
    ),
    const DiscoverCardModel(
      id: '4',
      name: 'Selin',
      age: 27,
      bio: 'İçerik benim işim. Video düzenleme ve kreatif içerikler üretiyorum.',
      occupation: 'Content Creator',
      location: 'Beşiktaş',
      photoUrls: ['https://i.pravatar.cc/600?img=4'],
      interests: ['Content Creator', 'Video Editor', 'Copywriter'],
      isVerified: true,
      distance: 8.2,
      compatibilityScore: 0.65,
    ),
    const DiscoverCardModel(
      id: '5',
      name: 'Deniz',
      age: 29,
      bio: 'Yazılım dünyasında ölçeklenebilir backend sistemleri geliştiriyorum.',
      occupation: 'Software Engineer',
      location: 'Üsküdar',
      photoUrls: ['https://i.pravatar.cc/600?img=5'],
      interests: ['Software Engineer', 'Backend Developer', 'System Architect'],
      isVerified: true,
      distance: 11.0,
      compatibilityScore: 0.91,
    ),
    const DiscoverCardModel(
      id: '6',
      name: 'Kaan',
      age: 30,
      bio: 'Makine öğrenmesi meraklısı. Veriden anlam çıkarmak benim işim.',
      occupation: 'Machine Learning Engineer',
      location: 'Maslak',
      photoUrls: ['https://i.pravatar.cc/600?img=12'],
      interests: ['Machine Learning Engineer', 'Data Scientist', 'AI Researcher'],
      isVerified: true,
      distance: 6.3,
      compatibilityScore: 0.88,
    ),
    const DiscoverCardModel(
      id: '7',
      name: 'Cem',
      age: 27,
      bio: 'Yeni nesil yatırımlar ve girişimcilik ekosistemi üzerinde odaklanmış durumdayım.',
      occupation: 'Founder',
      location: 'Levent',
      photoUrls: ['https://i.pravatar.cc/600?img=15'],
      interests: ['Founder', 'Entrepreneur', 'Business Development Manager'],
      isVerified: true,
      distance: 4.1,
      compatibilityScore: 0.83,
    ),
    const DiscoverCardModel(
      id: '8',
      name: 'Berk',
      age: 31,
      bio: 'Altyapıyı sevenler için: k8s, terraform ve cloud.',
      occupation: 'DevOps Engineer',
      location: 'Şişli',
      photoUrls: ['https://i.pravatar.cc/600?img=18'],
      interests: ['DevOps Engineer', 'Cloud Engineer', 'System Architect'],
      isVerified: false,
      distance: 9.7,
      compatibilityScore: 0.76,
    ),
    const DiscoverCardModel(
      id: '9',
      name: 'İrem',
      age: 25,
      bio: 'Şirket kültürü inşası ve yetenek kazanımı benim favori alanım.',
      occupation: 'HR Manager',
      location: 'Beşiktaş',
      photoUrls: ['https://i.pravatar.cc/600?img=9'],
      interests: ['HR Manager', 'Talent Acquisition Specialist', 'HR Business Partner (HRBP)'],
      isVerified: true,
      distance: 3.2,
      compatibilityScore: 0.74,
    ),
    const DiscoverCardModel(
      id: '10',
      name: 'Mert',
      age: 28,
      bio: 'Mobil dünyada cross-platform deneyimler tasarlıyorum. Flutter aşığı.',
      occupation: 'Flutter Developer',
      location: 'Kadıköy',
      photoUrls: ['https://i.pravatar.cc/600?img=20'],
      interests: ['Flutter Developer', 'Mobile Developer', 'iOS Developer'],
      isVerified: true,
      distance: 7.5,
      compatibilityScore: 0.85,
    ),
    const DiscoverCardModel(
      id: '11',
      name: 'Ceren',
      age: 26,
      bio: 'Renk ve form dili konuşurum. Marka kimliği tasarımı benim alanım.',
      occupation: 'Brand Designer',
      location: 'Karaköy',
      photoUrls: ['https://i.pravatar.cc/600?img=21'],
      interests: ['Brand Designer', 'Graphic Designer', 'Art Director'],
      isVerified: false,
      distance: 5.8,
      compatibilityScore: 0.78,
    ),
    const DiscoverCardModel(
      id: '12',
      name: 'Ali',
      age: 32,
      bio: 'Finansal stratejiler ve analiz üzerine uzmanlaştım.',
      occupation: 'Financial Analyst',
      location: 'Maslak',
      photoUrls: ['https://i.pravatar.cc/600?img=33'],
      interests: ['Financial Analyst', 'Investment Analyst', 'CFO'],
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
