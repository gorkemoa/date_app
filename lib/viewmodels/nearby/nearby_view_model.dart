import '../../models/nearby/nearby_user_model.dart';
import '../../services/interfaces/i_nearby_service.dart';
import '../base/base_view_model.dart';

class NearbyViewModel extends BaseViewModel {
  final INearbyService _nearbyService;

  NearbyViewModel({required INearbyService nearbyService})
      : _nearbyService = nearbyService;

  // Benim profilim — gerçek API'de ProfileService'ten gelir
  static const String _myOccupation = 'Yazılımcı';
  static const List<String> _myWantToMeetWith = [
    'Tasarımcı', 'Grafik Tasarımcı', 'Pazarlamacı',
    'İçerik Üretici', 'Girişimci', 'Sosyal Medya Uzmanı',
    'Proje Yöneticisi', 'Startup',
  ];

  NearbyUserModel? _myLocation;
  List<NearbyUserModel> _allNearbyUsers = [];
  NearbyUserModel? _selectedUser;

  NearbyUserModel? get myLocation => _myLocation;
  NearbyUserModel? get selectedUser => _selectedUser;

  // Sadece ilgi alanı uyumlu kullanıcılar görünür
  List<NearbyUserModel> get nearbyUsers =>
      _allNearbyUsers.where(_isCompatible).toList();

  List<NearbyUserModel> get allMarkers => [
        ?_myLocation,
        ...nearbyUsers,
      ];

  bool _isCompatible(NearbyUserModel user) {
    if (user.isMe) return true;
    final myOcc = _myOccupation.toLowerCase();
    // Onlar benim türümü arıyor mu?
    final theyWantMe = user.wantToMeetWith
        .map((w) => w.toLowerCase())
        .any((w) => myOcc.contains(w) || w.contains(myOcc));
    // Ben onların türünü arıyor muyum?
    final theirOcc = user.occupation?.toLowerCase() ?? '';
    final iWantThem = _myWantToMeetWith
        .map((w) => w.toLowerCase())
        .any((w) => theirOcc.contains(w) || w.contains(theirOcc));
    return theyWantMe || iWantThem;
  }

  Future<void> loadNearby() async {
    setLoading();
    final myRes = await _nearbyService.getMyLocation();
    final usersRes = await _nearbyService.getNearbyUsers();

    if (!myRes.isSuccess || !usersRes.isSuccess) {
      setError(myRes.error?.message ?? usersRes.error?.message ?? 'Yüklenemedi');
      return;
    }

    _myLocation = myRes.data;
    _allNearbyUsers = usersRes.data ?? [];

    if (nearbyUsers.isEmpty) {
      setEmpty();
    } else {
      setIdle();
    }
  }

  void selectUser(NearbyUserModel? user) {
    _selectedUser = user;
    notifyListeners();
  }
}
