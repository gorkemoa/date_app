import '../../models/nearby/nearby_user_model.dart';
import '../../services/interfaces/i_nearby_service.dart';
import '../base/base_view_model.dart';

class NearbyViewModel extends BaseViewModel {
  final INearbyService _nearbyService;

  NearbyViewModel({required INearbyService nearbyService})
      : _nearbyService = nearbyService;

  NearbyUserModel? _myLocation;
  List<NearbyUserModel> _nearbyUsers = [];
  NearbyUserModel? _selectedUser;

  NearbyUserModel? get myLocation => _myLocation;
  List<NearbyUserModel> get nearbyUsers => _nearbyUsers;
  NearbyUserModel? get selectedUser => _selectedUser;

  // Haritada gösterilecek tüm noktalar (ben dahil)
  List<NearbyUserModel> get allMarkers => [
        ?_myLocation,
        ..._nearbyUsers,
      ];

  Future<void> loadNearby() async {
    setLoading();
    final myRes = await _nearbyService.getMyLocation();
    final usersRes = await _nearbyService.getNearbyUsers();

    if (!myRes.isSuccess || !usersRes.isSuccess) {
      setError(myRes.error?.message ?? usersRes.error?.message ?? 'Yüklenemedi');
      return;
    }

    _myLocation = myRes.data;
    _nearbyUsers = usersRes.data ?? [];

    if (_nearbyUsers.isEmpty) {
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
