import 'dart:typed_data';

import '../../models/common/base_response.dart';
import '../../models/registration/linkedin_parse_result_model.dart';

abstract class ILinkedInParserService {
  Future<BaseResponse<LinkedInParseResultModel>> parsePdf(
    Uint8List bytes,
    String fileName,
  );
}
