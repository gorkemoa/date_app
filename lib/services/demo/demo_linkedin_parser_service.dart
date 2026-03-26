import 'dart:typed_data';

import '../../models/common/base_response.dart';
import '../../models/registration/linkedin_parse_result_model.dart';
import '../interfaces/i_linkedin_parser_service.dart';

/// Demo sürümde gerçek PDF ayrıştırması yapılmaz.
/// Gerçek API entegrasyonunda bu sınıf yerine gerçek parser takılır.
class DemoLinkedInParserService implements ILinkedInParserService {
  @override
  Future<BaseResponse<LinkedInParseResultModel>> parsePdf(
    Uint8List bytes,
    String fileName,
  ) async {
    // CV okunuyor simülasyonu
    await Future.delayed(const Duration(milliseconds: 2200));

    return BaseResponse.success(
      data: const LinkedInParseResultModel(
        fullName: 'Ahmet Yılmaz',
        headline: 'Senior Yazılım Mühendisi',
        currentCompany: 'Trendyol',
        summary:
            'Mobil ve web uygulama geliştirme alanında 5+ yıl deneyimli '
            'yazılım mühendisiyim. Flutter, React ve Node.js üzerine '
            'projeler yürütüyorum. Açık kaynak katkıcısı ve teknik '
            'blog yazarıyım.',
        skills: [
          'Flutter',
          'React Native',
          'Node.js',
          'Firebase',
          'UI/UX',
          'Agile',
          'Tasarım',
          'SaaS',
          'Girişimcilik',
        ],
      ),
    );
  }
}
