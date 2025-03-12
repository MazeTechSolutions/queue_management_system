import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:queue_management_system/src/features/queue/data/repositories/queue_repository.dart';
import 'package:queue_management_system/src/features/queue/domain/models/person_details.dart';

final personSearchQueryStateProvider = StateProvider<String>((ref) {
  return ''; // Initial search query is empty
});

final searchQueueProvider = FutureProvider.autoDispose
    .family<List<PersonDetails>, String>((ref, query) async {
  final queueRepo = ref.watch(queueRepoProvider);
  return queueRepo.searchQueue(query); // Call search method from queueRepo
});
