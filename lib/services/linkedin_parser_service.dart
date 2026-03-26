import 'dart:typed_data';

import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../models/common/api_error.dart';
import '../models/common/base_response.dart';
import '../models/registration/linkedin_parse_result_model.dart';
import 'interfaces/i_linkedin_parser_service.dart';

/// LinkedIn tarafından üretilen PDF'leri ayrıştırır.
/// Hem Türkçe hem İngilizce LinkedIn PDF formatını destekler.
///
/// LinkedIn PDF yapısı (Apache FOP ile üretilir):
///   Sol sütun → İletişim Bilgileri, En Önemli Yetenekler, Sertifikalar
///   Sağ sütun → İsim, Ünvan, Konum, Özet, Deneyim, Eğitim
///
/// Syncfusion metni satır sırasıyla (sol sütun önce, sağ sütun sonra) çıkarır.
class LinkedInParserService implements ILinkedInParserService {
  @override
  Future<BaseResponse<LinkedInParseResultModel>> parsePdf(
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      final document = PdfDocument(inputBytes: bytes);
      final extractor = PdfTextExtractor(document);
      final rawText = extractor.extractText();
      document.dispose();

      if (rawText.trim().isEmpty) {
        return BaseResponse.failure(
          error: const ApiError(
            code: 'PDF_EMPTY',
            message:
                'PDF dosyasından metin okunamadı. Metin tabanlı bir LinkedIn CV yükleyin.',
          ),
        );
      }

      return BaseResponse.success(data: _parse(rawText));
    } catch (_) {
      return BaseResponse.failure(
        error: const ApiError(
          code: 'PDF_PARSE_ERROR',
          message: 'PDF okunamadı. Lütfen geçerli bir LinkedIn CV dosyası seçin.',
        ),
      );
    }
  }

  // ──────────────────────────────────────────────────────────
  // Bölüm başlıkları — TR ve EN karşılıkları
  // ──────────────────────────────────────────────────────────
  static const _trContact = 'İletişim Bilgileri';
  static const _trSkills = 'En Önemli Yetenekler';
  static const _trSummary = 'Özet';
  static const _trExperience = 'Deneyim';
  static const _trEducation = 'Eğitim';

  static const _enContact = 'Contact';
  static const _enSkills = 'Top Skills';
  static const _enSummary = 'Summary';
  static const _enExperience = 'Experience';
  static const _enEducation = 'Education';

  static const _allHeaders = [
    _trContact, _trSkills, _trSummary, _trExperience, _trEducation,
    _enContact, _enSkills, _enSummary, _enExperience, _enEducation,
    'Certifications', 'Sertifikalar', 'Licenses & Certifications',
    'Languages', 'Diller', 'Volunteer Experience', 'Gönüllü Deneyim',
    'Publications', 'Yayınlar', 'Awards', 'Ödüller',
    'Accomplishments', 'Başarılar',
  ];

  // ──────────────────────────────────────────────────────────
  // Ana ayrıştırıcı
  // ──────────────────────────────────────────────────────────
  LinkedInParseResultModel _parse(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // Sol sütunun bittiği noktayı bul (İsim satırının başlangıcı)
    final nameIndex = _findNameLineIndex(lines);

    // Sol sütun: index 0 → nameIndex (yatenekler burada)
    final leftLines = nameIndex > 0 ? lines.sublist(0, nameIndex) : <String>[];
    // Sağ sütun: nameIndex ve sonrası
    final rightLines = nameIndex >= 0 ? lines.sublist(nameIndex) : lines;

    return LinkedInParseResultModel(
      fullName: nameIndex >= 0 ? lines[nameIndex] : null,
      headline: _extractHeadline(rightLines),
      currentCompany: _extractCurrentExperience(rightLines).$1,
      currentJobTitle: _extractCurrentExperience(rightLines).$2,
      summary: _extractSection(text, [_trSummary, _enSummary, 'About', 'Hakkımda'],
          stopAt: [_trExperience, _enExperience, _trEducation, _enEducation]),
      skills: _extractLeftColumnSkills(leftLines, text),
    );
  }

  // ──────────────────────────────────────────────────────────
  // İsim satırının index'ini bul
  // LinkedIn PDF'inde sol sütun önce gelir; isim sağ sütunun
  // ilk anlamlı satırıdır. "Certifications" / son sol-sütun
  // başlığından sonra gelen ilk uygun satır isimdir.
  // ──────────────────────────────────────────────────────────
  int _findNameLineIndex(List<String> lines) {
    // Strateji 1: Sol sütun kapandıktan sonraki ilk isim adayı.
    // Sol sütun genellikle şunlarla biter: Certifications satırı
    // veya bir sertifika ismi.
    int lastLeftHeaderIdx = -1;
    for (int i = 0; i < lines.length; i++) {
      final l = lines[i];
      if (_isLeftColumnHeader(l)) {
        lastLeftHeaderIdx = i;
      }
    }

    // Sol sütun başlığından sonra gelen ilk geçerli isim adayını ara
    final startSearch = lastLeftHeaderIdx + 1;
    for (int i = startSearch; i < lines.length && i < startSearch + 8; i++) {
      if (_isNameCandidate(lines[i])) return i;
    }

    // Strateji 2: "Özet" veya "Summary" başlığından hemen önceki satırlar
    for (int i = 0; i < lines.length; i++) {
      final l = lines[i].toLowerCase();
      if (l == _trSummary.toLowerCase() || l == _enSummary.toLowerCase()) {
        // Özet'ten önce: [isim, ünvan, konum] sırasıyla gelir
        // İsim Özet'ten 1-3 satır önce olmalı
        for (int j = i - 1; j >= 0 && j >= i - 4; j--) {
          if (_isNameCandidate(lines[j])) return j;
        }
        break;
      }
    }

    // Strateji 3: İlk birkaç satırdaki ilk isim adayı
    for (int i = 0; i < lines.length && i < 15; i++) {
      if (_isNameCandidate(lines[i])) return i;
    }

    return -1;
  }

  bool _isLeftColumnHeader(String line) {
    const leftHeaders = [
      'İletişim Bilgileri', 'En Önemli Yetenekler', 'Certifications',
      'Sertifikalar', 'Contact', 'Top Skills', 'Languages', 'Diller',
      'Licenses & Certifications',
    ];
    return leftHeaders.any((h) => h.toLowerCase() == line.toLowerCase());
  }

  bool _isNameCandidate(String line) {
    if (line.length < 3 || line.length > 60) return false;
    if (line.contains('@')) return false;
    if (line.contains('http') || line.contains('www.')) return false;
    if (line.contains('linkedin.com')) return false;
    if (RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(line)) return false;
    if (_isLeftColumnHeader(line)) return false;
    if (_allHeaders.any((h) => h.toLowerCase() == line.toLowerCase())) return false;
    // Tarih dizisi değil
    if (RegExp(r'\d{4}').hasMatch(line) && line.contains(' - ')) return false;
    // Konum formatı değil (Şehir, Ülke — virgüllü kısa metin)
    if (RegExp(r'^[A-ZÇĞİÖŞÜa-zçğışöşü ]+, [A-ZÇĞİÖŞÜa-zçğışöşü ]+$').hasMatch(line) &&
        line.split(',').length == 2 &&
        line.length < 40) {
      return false;
    }
    // En az 2 kelime (Ad Soyad)
    final words = line.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    if (words.length < 2) return false;
    // İlk harf büyük harf olmalı
    if (!RegExp(r'^[A-ZÇĞİÖŞÜ]').hasMatch(line)) return false;
    return true;
  }

  // ──────────────────────────────────────────────────────────
  // Ünvan / Headline: isim satırından sonraki ilk anlamlı satır
  // ──────────────────────────────────────────────────────────
  String? _extractHeadline(List<String> rightLines) {
    // rightLines[0] = isim, [1] = ünvan veya konum
    for (int i = 1; i < rightLines.length && i < 5; i++) {
      final line = rightLines[i];
      if (line.length < 4) continue;
      if (line.contains('@') || line.contains('http')) continue;
      if (_allHeaders.any((h) => h.toLowerCase() == line.toLowerCase())) break;
      // Konum mu?
      if (RegExp(r'^[A-ZÇĞİÖŞÜa-zçğışöşü ]+, [A-ZÇĞİÖŞÜa-zçğışöşü ]+$')
              .hasMatch(line) &&
          line.length < 40) {
        continue;
      }
      return line;
    }
    return null;
  }

  // ──────────────────────────────────────────────────────────
  // Güncel iş deneyimi: şirket + ünvan, YALNIZCA "Present/Halen" varsa döner.
  // LinkedIn formatı: [Şirket] → [Ünvan] → [Tarih (... - Present/Halen)] → [Konum]
  // ──────────────────────────────────────────────────────────
  (String?, String?) _extractCurrentExperience(List<String> lines) {
    bool inExperience = false;
    String? companyCandidate;
    String? jobTitleCandidate;

    for (int i = 0; i < lines.length; i++) {
      final l = lines[i].toLowerCase();

      if (l == _trExperience.toLowerCase() || l == _enExperience.toLowerCase()) {
        inExperience = true;
        continue;
      }

      if (!inExperience) continue;

      // Başka bir ana bölüme geçildiyse dur
      if (l == _trEducation.toLowerCase() || l == _enEducation.toLowerCase()) break;

      final line = lines[i];
      if (line.toLowerCase().startsWith('page ')) continue;

      if (_isDateLine(line)) {
        // "Present" veya "Halen" içeriyorsa şu anki iş
        final isPresent = RegExp(r'present|halen|devam',
                caseSensitive: false)
            .hasMatch(line);
        if (isPresent) {
          return (companyCandidate, jobTitleCandidate);
        } else {
          // İlk deneyim bloku Present içermiyorsa → şu anda çalışmıyor
          return (null, null);
        }
      }

      if (_isLocationLine(line)) continue;

      if (line.length > 1 && line.length < 80 && !line.contains('@')) {
        companyCandidate ??= line;
        if (companyCandidate != line) jobTitleCandidate ??= line;
      }
    }
    return (null, null);
  }

  bool _isDateLine(String line) {
    return RegExp(r'\d{4}').hasMatch(line) ||
        RegExp(r'(Ocak|Şubat|Mart|Nisan|Mayıs|Haziran|Temmuz|Ağustos|'
                r'Eylül|Ekim|Kasım|Aralık|January|February|March|April|'
                r'May|June|July|August|September|October|November|December)',
                caseSensitive: false)
            .hasMatch(line);
  }

  bool _isLocationLine(String line) {
    // "İzmir, Türkiye" veya "Istanbul, Turkey" formatı
    return RegExp(r'^[A-ZÇĞİÖŞÜa-zçğışöşü\s]+, [A-ZÇĞİÖŞÜa-zçğışöşü\s]+$')
            .hasMatch(line) &&
        line.length < 50;
  }

  // ──────────────────────────────────────────────────────────
  // Özet/Summary bölümü metnini çıkar
  // ──────────────────────────────────────────────────────────
  String? _extractSection(
    String text,
    List<String> headerNames, {
    required List<String> stopAt,
  }) {
    final headerPattern = headerNames.map(RegExp.escape).join('|');
    final stopPattern = stopAt.map(RegExp.escape).join('|');

    final re = RegExp(
      r'(?:' + headerPattern + r')\s*\n+([\s\S]*?)(?=\n(?:' + stopPattern + r')|\Z)',
      caseSensitive: false,
    );

    final m = re.firstMatch(text);
    if (m?.group(1) == null) return null;

    final s = m!
        .group(1)!
        .replaceAll(RegExp(r'\n+'), ' ')
        .replaceAll(RegExp(r'  +'), ' ')
        .trim();

    if (s.length < 20) return null;
    return s.length > 600 ? '${s.substring(0, 600)}…' : s;
  }

  // ──────────────────────────────────────────────────────────
  // Sol sütundaki "En Önemli Yetenekler" bölümünden yetenekleri topla.
  // Her satır ayrı bir yetenek olarak gelir.
  // ──────────────────────────────────────────────────────────
  List<String> _extractLeftColumnSkills(List<String> leftLines, String fullText) {
    List<String> skills = [];
    bool inSkills = false;

    for (final line in leftLines) {
      final lower = line.toLowerCase();

      // Beceriler bölümü başladı mı?
      if (lower == _trSkills.toLowerCase() || lower == _enSkills.toLowerCase()) {
        inSkills = true;
        continue;
      }

      // Başka bir sol sütun bölümüne geçildi mi?
      if (inSkills && _isLeftColumnHeader(line)) break;

      if (inSkills) {
        final trimmed = line.trim();
        if (trimmed.isNotEmpty && trimmed.length < 60 && !trimmed.contains('@')) {
          skills.add(trimmed);
        }
      }
    }

    // Sol sütunda bulunamadıysa tam metinde Skills bölümünü tara
    if (skills.isEmpty) {
      skills = _extractSkillsFromFullText(fullText);
    }

    return skills.take(15).toList();
  }

  List<String> _extractSkillsFromFullText(String text) {
    final re = RegExp(
      r'(?:Skills|Yetenekler|Beceriler|Top\s+Skills|En\s+Önemli\s+Yetenekler)'
      r'\s*\n+(.*?)(?=\n{2,}|\n(?:Languages|Diller|Certif|Sertif|Education|'
      r'Eğitim|Experience|Deneyim|$))',
      dotAll: true,
      caseSensitive: false,
    );

    final m = re.firstMatch(text);
    if (m?.group(1) != null) {
      return m!
          .group(1)!
          .split(RegExp(r'[\n,•·]+'))
          .map((s) => s.trim())
          .where((s) => s.length > 1 && s.length < 60)
          .take(15)
          .toList();
    }

    // Son çare: metindeki yaygın teknoloji adları
    return _techKeywordsFromText(text);
  }

  List<String> _techKeywordsFromText(String text) {
    const keywords = [
      'Flutter', 'React', 'Angular', 'Vue', 'Node.js', 'Python', 'Kotlin',
      'Swift', 'Java', 'TypeScript', 'JavaScript', 'Dart', 'Go', 'Rust',
      'Docker', 'Kubernetes', 'AWS', 'Firebase', 'PostgreSQL', 'MongoDB',
      'GraphQL', 'REST', 'CI/CD', 'Agile', 'Scrum', 'Git', 'Linux',
      'iOS', 'Android', 'Machine Learning', 'AI', 'UX', 'Figma', 'UI/UX',
    ];
    return keywords
        .where((k) => RegExp(r'\b' + RegExp.escape(k) + r'\b',
                caseSensitive: false)
            .hasMatch(text))
        .take(12)
        .toList();
  }
}
