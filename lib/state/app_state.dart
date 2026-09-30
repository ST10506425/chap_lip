import 'package:flutter/foundation.dart';

import '../data/lip_store.dart';
import '../models/lip_style.dart';
import '../models/product.dart';
import '../models/user_profile.dart';

/// The result of finishing one swipe of lip love.
class ApplicationResult {
  const ApplicationResult({required this.stats, required this.unlocked});
  final LipStats stats;
  final List<Product> unlocked;
}

/// App wide state: the signed in person, their lips and their progress.
class AppState extends ChangeNotifier {
  AppState(this._store);

  final LipStore _store;

  bool _ready = false;
  UserProfile? _user;
  LipStats _stats = LipStats.empty;

  bool get ready => _ready;
  UserProfile? get user => _user;
  bool get signedIn => _user != null;
  LipStats get stats => _stats;

  Product get activeProduct {
    final id = _user?.activeProductId;
    if (id != null && _stats.unlocked.contains(id)) return Product.byId(id);
    return Product.vaseline;
  }

  /// The next product still waiting to be unlocked, or null once the shelf
  /// is complete.
  Product? get nextUnlock {
    for (final product in Product.catalog) {
      if (!_stats.unlocked.contains(product.id)) return product;
    }
    return null;
  }

  Future<void> bootstrap() async {
    _user = await _store.restoreSession();
    if (_user != null) _stats = await _store.loadStats(_user!.id);
    _ready = true;
    notifyListeners();
  }

  Future<void> signUp({required String name, required String email, required String password}) async {
    _user = await _store.signUp(name: name, email: email, password: password);
    _stats = await _store.loadStats(_user!.id);
    notifyListeners();
  }

  Future<void> logIn({required String email, required String password}) async {
    _user = await _store.logIn(email: email, password: password);
    _stats = await _store.loadStats(_user!.id);
    notifyListeners();
  }

  Future<void> logOut() async {
    await _store.logOut();
    _user = null;
    _stats = LipStats.empty;
    notifyListeners();
  }

  Future<void> resetPassword({required String email, required String name, required String newPassword}) =>
      _store.resetPassword(email: email, name: name, newPassword: newPassword);

  Future<void> _save(UserProfile profile, {String? newPassword}) async {
    _user = await _store.updateProfile(profile, newPassword: newPassword);
    notifyListeners();
  }

  Future<void> saveGender(String? gender) => _save(_user!.copyWith(gender: gender));

  Future<void> saveLips(LipShape shape, LipShade shade) =>
      _save(_user!.copyWith(lipShape: shape, lipShade: shade, onboarded: true));

  Future<void> saveDetails({
    required String name,
    required String email,
    String? gender,
    String? newPassword,
  }) =>
      _save(_user!.copyWith(name: name, email: email, gender: gender), newPassword: newPassword);

  Future<void> useProduct(Product product) async {
    if (!_stats.unlocked.contains(product.id)) return;
    await _save(_user!.copyWith(activeProductId: product.id));
  }

  Future<ApplicationResult> recordApplication() async {
    final unlocked = await _store.recordApplication(_user!.id, activeProduct.id);
    _stats = await _store.loadStats(_user!.id);
    notifyListeners();
    return ApplicationResult(stats: _stats, unlocked: unlocked);
  }
}
