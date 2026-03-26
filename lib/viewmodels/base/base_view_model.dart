import 'package:flutter/foundation.dart';
import '../../core/enums/app_enums.dart';

abstract class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  String? _errorMessage;
  bool _isDisposed = false;

  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ViewState.loading;
  bool get hasError => _state == ViewState.error;
  bool get isEmpty => _state == ViewState.empty;
  bool get isIdle => _state == ViewState.idle;
  bool get isInitialized => _state != ViewState.idle;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

  void setState(ViewState state) {
    _state = state;
    notifyListeners();
  }

  void setLoading() => setState(ViewState.loading);
  void setIdle() => setState(ViewState.idle);
  void setEmpty() => setState(ViewState.empty);

  void setError(String message) {
    _errorMessage = message;
    setState(ViewState.error);
  }

  void clearError() {
    _errorMessage = null;
    setIdle();
  }
}
