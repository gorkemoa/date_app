import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../models/common/api_error.dart';
import '../models/common/base_response.dart';
import '../models/registration/linkedin_parse_result_model.dart';
import 'interfaces/i_linkedin_parser_service.dart';

/// Herhangi bir CV PDF'ini xAI Grok ile ayrıştırır.
/// Syncfusion ile ham metin çıkarılır, Grok yapay zekası ile alanlar doldurulur.
class LinkedInParserService implements ILinkedInParserService {
  static const _model = 'grok-4-1-fast-reasoning';
  static const _apiUrl = 'https://api.x.ai/v1/chat/completions';
  static const _maxChars = 50000;

  @override
  Future<BaseResponse<LinkedInParseResultModel>> parsePdf(
    Uint8List bytes,
    String fileName,
  ) async {
    // 1. PDF'den ham metin çıkar
    String rawText;
    try {
      final document = PdfDocument(inputBytes: bytes);
      final extractor = PdfTextExtractor(document);
      rawText = extractor.extractText();
      document.dispose();
      dev.log('[CVParser] PDF metni çıkarıldı — ${rawText.length} karakter', name: 'LinkedInParser');
    } catch (e) {
      dev.log('[CVParser] PDF okuma hatası: $e', name: 'LinkedInParser');
      return BaseResponse.failure(
        error: const ApiError(
          code: 'PDF_READ_ERROR',
          message: 'PDF okunamadı. Lütfen geçerli bir CV dosyası seçin.',
        ),
      );
    }

    if (rawText.trim().isEmpty) {
      return BaseResponse.failure(
        error: const ApiError(
          code: 'PDF_EMPTY',
          message: 'PDF dosyasından metin okunamadı. Metin tabanlı bir CV yükleyin.',
        ),
      );
    }

    // 2. Grok API anahtarını al
    final apiKey = dotenv.env['GROK_API_KEY'] ?? '';
    if (apiKey.isEmpty || apiKey == 'your_grok_api_key_here') {
      return BaseResponse.failure(
        error: const ApiError(
          code: 'NO_API_KEY',
          message: '.env dosyasına GROK_API_KEY ekleyin.',
        ),
      );
    }

    // 3. Grok'a gönder
    try {
      final truncated = rawText.length > _maxChars
          ? rawText.substring(0, _maxChars)
          : rawText;

      dev.log('[CVParser] Grok isteği gönderiliyor — model: $_model, metin: ${truncated.length} karakter', name: 'LinkedInParser');

      final httpResponse = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'user', 'content': _buildPrompt(truncated)},
          ],
        }),
      );

      dev.log('[CVParser] Grok yanıtı — HTTP ${httpResponse.statusCode}', name: 'LinkedInParser');
      dev.log('[CVParser] Response body: ${httpResponse.body}', name: 'LinkedInParser');

      if (httpResponse.statusCode == 429) {
        return BaseResponse.failure(
          error: const ApiError(
            code: 'RATE_LIMIT',
            message: 'İstek limiti aşıldı (429). Birkaç saniye bekleyip tekrar deneyin.',
          ),
        );
      }

      if (httpResponse.statusCode != 200) {
        return BaseResponse.failure(
          error: ApiError(
            code: 'AI_HTTP_ERROR',
            message: 'Grok API hatası: HTTP ${httpResponse.statusCode} — ${httpResponse.body}',
          ),
        );
      }

      final body = jsonDecode(httpResponse.body) as Map<String, dynamic>;
      final responseText =
          (body['choices'] as List?)?.firstOrNull?['message']?['content']
              as String? ??
          '';

      dev.log('[CVParser] Grok içerik yanıtı:\n$responseText', name: 'LinkedInParser');

      if (responseText.isEmpty) {
        return BaseResponse.failure(
          error: const ApiError(
            code: 'AI_EMPTY_RESPONSE',
            message: "Yapay zeka CV'yi işleyemedi. Lütfen tekrar deneyin.",
          ),
        );
      }

      return BaseResponse.success(data: _parseGrokResponse(responseText));
    } catch (e) {
      dev.log('[CVParser] İstisna: $e', name: 'LinkedInParser');
      return BaseResponse.failure(
        error: ApiError(
          code: 'AI_ERROR',
          message: 'Yapay zeka hatası: ${e.toString()}',
        ),
      );
    }
  }

  String _buildPrompt(String cvText) {
    return '''
Sen bir CV/ozgecmis ayristiricisin. Asagidaki CV metninden bilgileri cikar ve SADECE gecerli bir JSON nesnesi dondur. Markdown, aciklama veya ek metin yazma.

JSON semasi:
{
  "fullName": "kisinin tam adi",
  "headline": "profesyonel unvan veya LinkedIn headline (veya null)",
  "currentCompany": "su an calistigi sirket - SADECE tarihte Present/Halen/devam varsa, yoksa null",
  "currentJobTitle": "su anki is unvani - SADECE hala o sirkette calisiyorsa, yoksa null",
  "summary": "profesyonel ozet / hakkimda bolumu max 500 karakter (veya null)",
  "skills": ["beceri1", "beceri2"]
}

Kurallar:
- currentCompany ve currentJobTitle: YALNIZCA Present veya Halen ifadesi varsa doldur, yoksa null
- skills: max 15 adet, bulamazsan bos array ver
- SADECE JSON cikar, baska hicbir sey yazma

CV:
$cvText
''';
  }

  LinkedInParseResultModel _parseGrokResponse(String responseText) {
    try {
      var cleaned = responseText.trim();
      if (cleaned.startsWith('```')) {
        cleaned = cleaned
            .replaceAll(RegExp(r'```json\s*'), '')
            .replaceAll(RegExp(r'```\s*'), '')
            .trim();
      }

      final json = jsonDecode(cleaned) as Map<String, dynamic>;

      final rawSkills = json['skills'];
      final skills = rawSkills is List
          ? rawSkills.whereType<String>().take(15).toList()
          : <String>[];

      return LinkedInParseResultModel(
        fullName: json['fullName'] as String?,
        headline: json['headline'] as String?,
        currentCompany: json['currentCompany'] as String?,
        currentJobTitle: json['currentJobTitle'] as String?,
        summary: json['summary'] as String?,
        skills: skills,
      );
    } catch (_) {
      return const LinkedInParseResultModel();
    }
  }
}
