import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_ai/services/storage_service.dart';

void main() {
  test('dados locais de uma conta não aparecem em outra', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final alice = StorageService(preferences, userId: 'alice');
    final bob = StorageService(preferences, userId: 'bob');

    await alice.saveDailyGoal(20);
    expect(alice.loadDailyGoal(), 20);
    expect(bob.loadDailyGoal(), 10);

    await bob.saveDailyGoal(5);
    expect(StorageService(preferences, userId: 'alice').loadDailyGoal(), 20);
    expect(StorageService(preferences, userId: 'bob').loadDailyGoal(), 5);
  });
}
