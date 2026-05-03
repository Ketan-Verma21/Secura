import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../model/vault_item.dart';

class VaultRepository {
  final _storage = const FlutterSecureStorage();
  final _uuid = const Uuid();

  Box<VaultItem> get _box => Hive.box<VaultItem>('vault');

  /// Creates a new vault entry with a title, optional username, and initial password.
  Future<void> create(String title, String password, {String username = ''}) async {
    final id = _uuid.v4();
    final versionId = _uuid.v4();

    await _storage.write(key: _key(id, versionId), value: password);

    final item = VaultItem(
      id: id,
      title: title,
      username: username,
      versionIds: [versionId],
    );
    await _box.put(id, item);
  }

  /// Reads a specific password version for an item.
  Future<String?> get(String itemId, String versionId) async {
    return _storage.read(key: _key(itemId, versionId));
  }

  /// Appends a new password version to an existing item.
  Future<void> update(String id, String newPassword) async {
    final item = _box.get(id);
    if (item == null) return;

    final versionId = _uuid.v4();
    await _storage.write(key: _key(id, versionId), value: newPassword);

    item.versionIds = [...item.versionIds, versionId];
    await item.save();
  }

  /// Updates the username of an existing item in-place (no versioning for username).
  Future<void> updateUsername(String id, String username) async {
    final item = _box.get(id);
    if (item == null) return;
    item.username = username;
    await item.save();
  }

  /// Updates title of an existing item.
  Future<void> updateTitle(String id, String title) async {
    final item = _box.get(id);
    if (item == null) return;
    item.title = title;
    await item.save();
  }

  /// Deletes an item and all its stored password versions.
  Future<void> delete(String id) async {
    final item = _box.get(id);
    if (item == null) return;

    for (final versionId in item.versionIds) {
      await _storage.delete(key: _key(id, versionId));
    }
    await _box.delete(id);
  }

  String _key(String itemId, String versionId) => '${itemId}_$versionId';
}