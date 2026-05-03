import '../models/place_model.dart';
import '../models/event_model.dart';
import '../models/issue_model.dart';
import '../models/job_model.dart';

/// Deterministic, offline-safe fallback data.
///
/// Used when both Supabase and cache miss (e.g. first launch while offline).
/// Never throws. Returns minimal but structurally valid mock objects.
class MockDataSource {
  const MockDataSource();

  List<PlaceModel> getPlaces() => [
        PlaceModel(
          id: 'mock-place-1',
          name: 'Corfu Town Hall',
          description: 'Historic town hall in the centre of Corfu Town.',
          categoryId: null,
          latitude: 39.6243,
          longitude: 19.9217,
          active: true,
          isFeatured: true,
        ),
        PlaceModel(
          id: 'mock-place-2',
          name: 'Old Fortress',
          description: 'Venetian sea fortress with panoramic views.',
          categoryId: null,
          latitude: 39.6249,
          longitude: 19.9284,
          active: true,
          isFeatured: true,
        ),
      ];

  List<EventModel> getEvents() => [
        EventModel(
          id: 'mock-event-1',
          title: 'Corfu Carnival',
          description: 'Annual carnival celebration.',
          active: true,
          latitude: 39.6243,
          longitude: 19.9217,
        ),
      ];

  List<IssueModel> getIssues() => [
        IssueModel(
          id: 'mock-issue-1',
          title: 'Pothole on Kapodistriou St',
          reporterId: 'mock-user',
          geometryType: 'point',
          confidence: 1,
          active: true,
          latitude: 39.6240,
          longitude: 19.9200,
        ),
      ];

  List<JobModel> getJobs() => [
        JobModel(
          id: 'mock-job-1',
          title: 'Wait staff wanted',
          placeId: 'mock-place-1',
          posterId: 'mock-user',
          active: true,
        ),
      ];
}
