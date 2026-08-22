import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_annoucement/services/local_storage_service.dart';

void main() {
  test('LocalStorageService round-trips the global enabled flag', () async {
    SharedPreferences.setMockInitialValues({});
    final service = LocalStorageService();

    expect(await service.loadGlobalEnabled(), isFalse);

    await service.saveGlobalEnabled(true);
    expect(await service.loadGlobalEnabled(), isTrue);
  });
}
