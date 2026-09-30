import 'package:flutter_test/flutter_test.dart';
import 'package:moist_me_up/data/lip_store.dart';
import 'package:moist_me_up/models/lip_style.dart';
import 'package:moist_me_up/models/product.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late SqliteLipStore store;

  setUp(() async {
    store = await SqliteLipStore.open(factory: databaseFactoryFfi, path: inMemoryDatabasePath);
  });

  tearDown(() => store.close());

  test('sign up starts a session that survives a restart', () async {
    final user = await store.signUp(name: 'Ari', email: 'Ari@Example.com', password: 'glossy123');
    expect(user.email, 'ari@example.com');
    expect(user.onboarded, isFalse);

    final restored = await store.restoreSession();
    expect(restored?.id, user.id);

    final stats = await store.loadStats(user.id);
    expect(stats.applications, 0);
    expect(stats.unlocked, {Product.vaseline.id});
  });

  test('log in checks the password and log out clears the session', () async {
    await store.signUp(name: 'Ari', email: 'ari@example.com', password: 'glossy123');
    await store.logOut();
    expect(await store.restoreSession(), isNull);

    await expectLater(
      store.logIn(email: 'ari@example.com', password: 'wrong pass'),
      throwsA(isA<AuthException>()),
    );
    final user = await store.logIn(email: 'ARI@example.com', password: 'glossy123');
    expect(user.name, 'Ari');
    expect((await store.restoreSession())?.id, user.id);
  });

  test('duplicate emails are refused', () async {
    await store.signUp(name: 'Ari', email: 'ari@example.com', password: 'glossy123');
    await expectLater(
      store.signUp(name: 'Bo', email: 'ari@example.com', password: 'glossy456'),
      throwsA(isA<AuthException>()),
    );
  });

  test('applications unlock products at their milestones', () async {
    final user = await store.signUp(name: 'Ari', email: 'ari@example.com', password: 'glossy123');
    for (var i = 1; i < 5; i++) {
      expect(await store.recordApplication(user.id, 'vaseline'), isEmpty);
    }
    final unlocked = await store.recordApplication(user.id, 'vaseline');
    expect(unlocked.map((p) => p.id), [Product.roseBalm.id]);

    final stats = await store.loadStats(user.id);
    expect(stats.applications, 5);
    expect(stats.unlocked, containsAll([Product.vaseline.id, Product.roseBalm.id]));
    expect(stats.streakDays, 1);
    expect(stats.levelLabel, '01');
  });

  test('lips stay moist for as long as the last product lasts', () async {
    final user = await store.signUp(name: 'Ari', email: 'ari@example.com', password: 'glossy123');
    expect((await store.loadStats(user.id)).moistUntil, isNull);

    await store.recordApplication(user.id, 'vaseline');
    final stats = await store.loadStats(user.id);
    expect(stats.moistUntil, stats.lastAppliedAt!.add(const Duration(hours: 1)));
    expect(stats.moistUntil!.isAfter(DateTime.now()), isTrue);
  });

  test('profile updates persist lips, product and password', () async {
    final user = await store.signUp(name: 'Ari', email: 'ari@example.com', password: 'glossy123');
    final saved = await store.updateProfile(
      user.copyWith(lipShape: LipShape.cupid, lipShade: LipShade.plum, onboarded: true),
      newPassword: 'newgloss99',
    );
    expect(saved.lipShape, LipShape.cupid);
    expect(saved.lipShade.id, 'plum');
    expect(saved.onboarded, isTrue);

    await store.logOut();
    final back = await store.logIn(email: 'ari@example.com', password: 'newgloss99');
    expect(back.lipShape, LipShape.cupid);
  });

  test('forgotten passwords reset when name and email match', () async {
    await store.signUp(name: 'Ari', email: 'ari@example.com', password: 'glossy123');
    await expectLater(
      store.resetPassword(email: 'ari@example.com', name: 'Someone', newPassword: 'whatever1'),
      throwsA(isA<AuthException>()),
    );
    await store.resetPassword(email: 'ari@example.com', name: 'ari', newPassword: 'freshgloss');
    final user = await store.logIn(email: 'ari@example.com', password: 'freshgloss');
    expect(user.name, 'Ari');
  });
}
