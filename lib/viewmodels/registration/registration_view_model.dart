import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../models/registration/expertise_item_model.dart';
import '../../models/registration/registration_draft_model.dart';
import '../base/base_view_model.dart';

enum RegStep { phone, otp, referral, identity, expertise, interests, rules }

abstract class IExpertiseService {
  Future<List<String>> fetchCategories();
  Future<List<ExpertiseItem>> searchExpertise({
    required String query,
    String? category,
  });
}

class RegistrationViewModel extends BaseViewModel {
  Timer? _expertiseDebounce;

  RegistrationViewModel()
      : super();

  // availableInterests removed

  RegStep _step = RegStep.phone;
  RegistrationDraftModel _draft = RegistrationDraftModel.empty;
  String _expertiseSearchQuery = '';
  bool _readyToNavigateHome = false;
  List<ExpertiseItem> _expertiseResults = [];
  bool _expertiseSearchLoading = false;
  bool _hasMoreExpertise = true;

  int _expertiseOffset = 0;

  // Job / Occupation State
  List<String> _allOccupations = [];
  List<String> _occupationResults = [];
  bool _occupationLoading = false;
  Timer? _occupationDebounce;

  // Skills State
  Map<String, List<String>> _skillsMap = {};

  RegStep get step => _step;
  RegistrationDraftModel get draft => _draft;
  String get expertiseSearchQuery => _expertiseSearchQuery;
  int get stepIndex => RegStep.values.indexOf(_step);
  int get totalSteps => RegStep.values.length;
  bool get readyToNavigateHome => _readyToNavigateHome;
  List<ExpertiseItem> get expertiseResults => List.unmodifiable(_expertiseResults);
  bool get expertiseSearchLoading => _expertiseSearchLoading;
  bool get hasMoreExpertise => _hasMoreExpertise;
  List<String> get occupationResults => _occupationResults;
  bool get occupationLoading => _occupationLoading;
  Map<String, List<String>> get skillsMap => _skillsMap;

  String formatSkillCategory(String key) {
    if (key == 'yazilim_ve_teknoloji') return 'Yazılım ve Teknoloji';
    if (key == 'tasarim_ve_yartici_isler') return 'Tasarım ve Yaratıcı İşler';
    if (key == 'pazarlama_ve_sosyal_medya') return 'Pazarlama ve Sosyal Medya';
    if (key == 'urun_ve_proje_yonetimi') return 'Ürün ve Proje Yönetimi';
    if (key == 'is_gelistirme_ve_satis') return 'İş Geliştirme ve Satış';
    if (key == 'insan_kaynaklari_ve_idari') return 'İnsan Kaynakları ve İdari';
    if (key == 'finans_ve_danismanlik') return 'Finans ve Danışmanlık';
    if (key == 'egitim_ve_diger_beyaz_yaka') return 'Eğitim ve Diğer';
    return key.split('_').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
  }

  bool get canGoNext {
    switch (_step) {
      case RegStep.phone:
        return _draft.phoneNumber.isNotEmpty;
      case RegStep.otp:
        return _draft.otpCode.isNotEmpty;
      case RegStep.referral:
        return _draft.referralCode.isNotEmpty;
      case RegStep.identity:
        return _draft.photoBytes != null;
      case RegStep.expertise:
        return _draft.occupation.isNotEmpty && 
               (_draft.selectedExpertise.isNotEmpty || _draft.cvFileName != null);
      case RegStep.interests:
        return _draft.selectedInterests.length >= 3;
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

  Future<void> loadOccupations() async {
    if (_allOccupations.isNotEmpty) return;
    try {
      final jsonStr = await rootBundle.loadString('assets/meslekler.json');
      _allOccupations = List<String>.from(jsonDecode(jsonStr));
    } catch (e) {
      dev.log('Error loading occupations: $e');
    }
  }

  Future<void> loadSkills() async {
    if (_skillsMap.isNotEmpty) return;
    try {
      final jsonStr = await rootBundle.loadString('assets/skills.json');
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      final roles = data['professional_roles'] as Map<String, dynamic>;
      _skillsMap = roles.map((k, v) => MapEntry(k, List<String>.from(v)));
      notifyListeners();
    } catch (e) {
      dev.log('Error loading skills: $e');
    }
  }

  void searchOccupations(String query) {
    _occupationDebounce?.cancel();
    if (query.trim().length < 2) {
      _occupationResults = [];
      _occupationLoading = false;
      notifyListeners();
      return;
    }

    _occupationLoading = true;
    notifyListeners();

    _occupationDebounce = Timer(const Duration(seconds: 1), () {
      _occupationResults = _allOccupations
          .where((o) => o.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _occupationLoading = false;
      notifyListeners();
    });
  }

  void selectOccupation(String occupation) {
    _draft = _draft.copyWith(occupation: occupation);
    _occupationResults = [];
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
    
    if (query.trim().isEmpty) {
      notifyListeners();
      return;
    }

    _expertiseDebounce = Timer(const Duration(milliseconds: 400), () {
      searchExpertiseIcons(query);
    });
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
      } else {
        // Eğer query boşsa default bir şeyler çekelim ki boş kalmasın veya boş dönsün
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

  @override
  void dispose() {
    _expertiseDebounce?.cancel();
    super.dispose();
  }
}
