import 'package:flutter/foundation.dart';
import 'package:corfu_shared/shared.dart';

class IssuesNotifier extends ChangeNotifier {
  final AppRepository _repo;

  IssuesNotifier(this._repo);

  List<IssueEntity> _issues = [];
  IssueEntity? _selected;
  bool _loading = false;
  bool _submitting = false;
  String? _error;

  List<IssueEntity> get issues => _issues;
  IssueEntity? get selected => _selected;
  bool get loading => _loading;
  bool get submitting => _submitting;
  String? get error => _error;

  Future<void> loadIssues() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _issues = await _repo.getIssues();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadIssue(String id) async {
    try {
      _selected = await _repo.getIssue(id);
      notifyListeners();
    } catch (_) {}
  }

  Future<IssueEntity?> reportIssue({
    required String title,
    String? description,
    required double lat,
    required double lng,
  }) async {
    _submitting = true;
    _error = null;
    notifyListeners();
    try {
      final issue = await _repo.reportIssue(
        title: title,
        description: description,
        latitude: lat,
        longitude: lng,
      );
      _issues = [issue, ..._issues];
      return issue;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  Future<bool> checkIn(String issueId) async {
    try {
      await _repo.checkInIssue(issueId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
