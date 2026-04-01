import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../models/registration/expertise_item_model.dart';
import '../../models/registration/registration_draft_model.dart';
import '../../services/interfaces/i_linkedin_parser_service.dart';
import '../base/base_view_model.dart';

enum RegStep { phone, otp, referral, profile, rules }

abstract class IExpertiseService {
  Future<List<String>> fetchCategories();
  Future<List<ExpertiseItem>> searchExpertise({
    required String query,
    String? category,
  });
}

class RegistrationViewModel extends BaseViewModel {
  final ILinkedInParserService _linkedInParser;
  Timer? _expertiseDebounce;

  RegistrationViewModel({required ILinkedInParserService linkedInParser})
      : _linkedInParser = linkedInParser;

  static const List<String> availableInterests = [
    'Yazılım', 'Tasarım', 'Girişimcilik', 'Pazarlama', 'Fintech',
    'SaaS', 'AI / ML', 'Mobil Geliştirme', 'Veri Bilimi', 'DevOps',
    'Grafik Tasarım', 'İçerik Üretimi', 'Fotoğrafçılık', 'Video',
    'Sosyal Medya', 'SEO', 'PR & İletişim', 'Spor', 'Seyahat',
    'Müzik', 'Kitap', 'Kafe Kültürü', 'Yemek', 'Podcast',
  ];

  static const List<String> expertiseCategories = [
    'Software', 'Design', 'Language + Framework', 'İş Geliştirme', 'Pazarlama',
    'Finans', 'Hukuk', 'Sağlık', 'Eğitim', 'Medya',
  ];

  static const Map<String, String> _svgCategoryMap = {
    'Software': 'Software',
    'Design': 'Design',
    'Language + Framework': 'Framework',
    'Finans': 'Finance',
    'Sağlık': 'Health',
    'Eğitim': 'Education',
    'Medya': 'Media',
    'İş Geliştirme': 'Business',
    'Pazarlama': 'Social',
  };

  RegStep _step = RegStep.phone;
  RegistrationDraftModel _draft = RegistrationDraftModel.empty;
  bool _linkedInLoading = false;
  String _expertiseSearchQuery = '';
  String? _selectedExpertiseCategory = 'Teknoloji';
  bool _readyToNavigateHome = false;
  List<ExpertiseItem> _expertiseResults = [];
  bool _expertiseSearchLoading = false;
  int _expertiseOffset = 0;
  bool _hasMoreExpertise = true;

  RegStep get step => _step;
  RegistrationDraftModel get draft => _draft;
  bool get linkedInLoading => _linkedInLoading;
  String get expertiseSearchQuery => _expertiseSearchQuery;
  String? get selectedExpertiseCategory => _selectedExpertiseCategory;
  int get stepIndex => RegStep.values.indexOf(_step);
  int get totalSteps => RegStep.values.length;
  bool get readyToNavigateHome => _readyToNavigateHome;
  List<ExpertiseItem> get expertiseResults => List.unmodifiable(_expertiseResults);
  bool get expertiseSearchLoading => _expertiseSearchLoading;
  bool get hasMoreExpertise => _hasMoreExpertise;

  bool get canGoNext {
    switch (_step) {
      case RegStep.phone:
        return _draft.phoneNumber.isNotEmpty;
      case RegStep.otp:
        return _draft.otpCode.isNotEmpty;
      case RegStep.referral:
        return _draft.referralCode.isNotEmpty;
      case RegStep.profile:
        return _draft.displayName.isNotEmpty;
      case RegStep.rules:
        return true;
    }
  }

  void updatePhone(String phone) {
    _draft = _draft.copyWith(phoneNumber: phone);
    notifyListeners();
  }

  void updateOtp(String otp) {
    _draft = _draft.copyWith(otpCode: otp);
    notifyListeners();
  }

  void updateReferralCode(String code) {
    _draft = _draft.copyWith(referralCode: code);
    notifyListeners();
  }

  void updateProfile({String? displayName, String? bio}) {
    _draft = _draft.copyWith(
      displayName: displayName ?? _draft.displayName,
      bio: bio ?? _draft.bio,
    );
    notifyListeners();
  }

  void setPhoto({required Uint8List bytes, required String fileName}) {
    _draft = _draft.copyWith(photoBytes: bytes, photoFileName: fileName);
    notifyListeners();
  }

  void setCv({required Uint8List bytes, required String fileName}) {
    _draft = _draft.copyWith(cvBytes: bytes, cvFileName: fileName);
    notifyListeners();
  }

  void toggleInterest(String interest) {
    final current = List<String>.from(_draft.selectedInterests);
    if (current.contains(interest)) {
      current.remove(interest);
    } else {
      current.add(interest);
    }
    _draft = _draft.copyWith(selectedInterests: current);
    notifyListeners();
  }

  void toggleExpertise(ExpertiseItem item) {
    final current = List<ExpertiseItem>.from(_draft.selectedExpertise);
    if (current.contains(item)) {
      current.remove(item);
    } else {
      current.add(item);
    }
    _draft = _draft.copyWith(selectedExpertise: current);
    notifyListeners();
  }

  void addManualExpertise(String name) {
    if (name.trim().isEmpty) return;
    final slug = name.trim().toLowerCase().replaceAll(' ', '-');
    final item = ExpertiseItem(slug: 'manual-$slug', title: name.trim());
    toggleExpertise(item);
  }

  void setExpertiseSearch(String query) {
    _expertiseSearchQuery = query;
    _expertiseDebounce?.cancel();
    _expertiseOffset = 0;
    _hasMoreExpertise = true;
    _expertiseResults = [];
    
    // Query boş olsa bile sonuçlar kalsın (kategori bazlı görünüm için)
    if (query.trim().isEmpty) {
      searchExpertiseIcons('');
      notifyListeners();
      return;
    }

    _expertiseDebounce = Timer(const Duration(milliseconds: 400), () {
      searchExpertiseIcons(query);
    });
    notifyListeners();
  }

  void setExpertiseCategory(String? category) {
    if (_selectedExpertiseCategory == category) return;
    _selectedExpertiseCategory = category;
    _expertiseOffset = 0;
    _hasMoreExpertise = true;
    _expertiseResults = [];
    searchExpertiseIcons(_expertiseSearchQuery);
    notifyListeners();
  }

  Future<void> searchExpertiseIcons(String query, {bool isLoadMore = false}) async {
    if (_expertiseSearchLoading) return;
    if (isLoadMore && !_hasMoreExpertise) return;

    if (!isLoadMore) {
      _expertiseOffset = 0;
      _expertiseResults = [];
      _hasMoreExpertise = true;
    }

    _expertiseSearchLoading = true;
    notifyListeners();

    try {
      final queryParams = <String, String>{
        'limit': '50',
        'offset': _expertiseOffset.toString(),
      };
      
      final formattedQuery = query.trim().toLowerCase().replaceAll(' ', '-');
      if (formattedQuery.isNotEmpty) {
        queryParams['q'] = formattedQuery;
      }

      if (_selectedExpertiseCategory != null) {
        final mappedCat = _svgCategoryMap[_selectedExpertiseCategory!];
        if (mappedCat != null) queryParams['category'] = mappedCat;
      }
      
      if (queryParams['q'] == null && queryParams['category'] == null) {
        queryParams['category'] = 'Software';
      }

      final uri = Uri.https('www.thesvg.org', '/api/registry', queryParams);
      
      dev.log('SVG API Request (isLoadMore: $isLoadMore): $uri', name: 'RegistrationViewModel');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final icons = data['icons'] as List<dynamic>? ?? [];
        final total = data['total'] as int? ?? 0;
        
        final newItems = icons
            .map((i) => ExpertiseItem.fromJson(i as Map<String, dynamic>))
            .toList();

        if (isLoadMore) {
          _expertiseResults.addAll(newItems);
        } else {
          _expertiseResults = newItems;
        }

        _expertiseOffset += newItems.length;
        _hasMoreExpertise = _expertiseResults.length < total && newItems.isNotEmpty;
        
        dev.log('SVG API Results: ${_expertiseResults.length}/$total (hasMore: $_hasMoreExpertise)', name: 'RegistrationViewModel');
      } else {
        if (!isLoadMore) _expertiseResults = [];
        _hasMoreExpertise = false;
        dev.log('SVG API Error: ${response.statusCode} - ${response.body}', name: 'RegistrationViewModel');
      }
    } catch (e) {
      dev.log('SVG API Exception: $e', name: 'RegistrationViewModel');
      if (!isLoadMore) _expertiseResults = [];
    } finally {
      _expertiseSearchLoading = false;
      notifyListeners();
    }
  }

  void nextStep() {
    if (_step == RegStep.rules) {
      _readyToNavigateHome = true;
      notifyListeners();
      return;
    }
    final steps = RegStep.values;
    final idx = steps.indexOf(_step);
    if (idx < steps.length - 1) {
      _step = steps[idx + 1];
      notifyListeners();
    }
  }

  void previousStep() {
    final steps = RegStep.values;
    final idx = steps.indexOf(_step);
    if (idx > 0) {
      _step = steps[idx - 1];
      notifyListeners();
    }
  }

  void clearNavigationFlag() {
    _readyToNavigateHome = false;
  }

  Future<void> connectLinkedIn(Uint8List bytes, String fileName) async {
    _linkedInLoading = true;
    clearError();
    notifyListeners();

    final res = await _linkedInParser.parsePdf(bytes, fileName);
    _linkedInLoading = false;

    if (res.isSuccess && res.data != null) {
      _draft = _draft.copyWith(linkedInConnected: true);
      notifyListeners();
    } else {
      setError(res.error?.message ?? 'LinkedIn bağlanamadı. Tekrar deneyin.');
    }
  }

  @override
  void dispose() {
    _expertiseDebounce?.cancel();
    super.dispose();
  }
}
