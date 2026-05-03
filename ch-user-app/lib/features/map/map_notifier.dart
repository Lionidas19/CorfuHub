import 'package:flutter/foundation.dart';
import 'package:corfu_shared/shared.dart';

class MapNotifier extends ChangeNotifier {
  final AppRepository _repo;

  MapNotifier(this._repo);

  List<PlaceEntity> _places = [];
  List<EventEntity> _events = [];
  List<JobEntity> _jobs = [];
  bool _loading = false;
  String? _error;
  String? _activeCategoryFilter;

  List<PlaceEntity> get places => _activeCategoryFilter == null
      ? _places
      : _places.where((p) => p.categoryId == _activeCategoryFilter).toList();

  List<EventEntity> get events => _events;
  List<JobEntity> get jobs => _jobs;
  bool get loading => _loading;
  String? get error => _error;
  String? get activeCategoryFilter => _activeCategoryFilter;

  Future<void> loadPlaces() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _places = await _repo.getPlaces();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadEventsForPlace(String placeId) async {
    try {
      _events = await _repo.getEvents(placeId: placeId);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadJobsForPlace(String placeId) async {
    try {
      _jobs = await _repo.getJobs(placeId: placeId);
      notifyListeners();
    } catch (_) {}
  }

  void setCategoryFilter(String? categoryId) {
    _activeCategoryFilter = categoryId;
    notifyListeners();
  }
}
