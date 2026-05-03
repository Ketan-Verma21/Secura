import 'package:flutter/material.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final updater = ShorebirdUpdater();
  Patch? _currentPatch;
  bool _updateAvailable = false;
  bool _isChecking = false;
  bool _isInstalling = false;

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  void _loadData() {
    // Read the current patch number (null if no patch is installed).
    updater.readCurrentPatch().then((patch) {
      setState(() => _currentPatch = patch);
    });

    // Check if an update is available to show in the UI.
    setState(() => _isChecking = true);
    updater.checkForUpdate().then((status) {
      setState(() {
        _updateAvailable = status == UpdateStatus.outdated;
        _isChecking = false;
      });
    }).catchError((_) {
      setState(() => _isChecking = false);
    });
  }

  void _applyUpdate() async {
    if (_isInstalling || !_updateAvailable) return;

    setState(() => _isInstalling = true);

    try {
      await updater.update();
      // After install, Shorebird will restart the app.
    } catch (_) {
      // Handle error (e.g. show a SnackBar)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to download update')),
      );
      setState(() => _isInstalling = false);
    }
  }

  int _currentPatchVersion() {
    final patch = _currentPatch;
    if (patch == null) return 0;
    return patch.number;
  }

  @override
  Widget build(BuildContext context) {
    final currentVersion = _currentPatchVersion();
    final updateBtnEnabled = _updateAvailable && !_isInstalling;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "App Updates",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_isChecking)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// Version Info
                  Row(
                    children: [
                      const Icon(Icons.system_update, color: Colors.blue),
                      const SizedBox(width: 10),
                      Text(
                        "Version: $currentVersion",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// Status Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _updateAvailable
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _updateAvailable
                              ? Icons.download_done
                              : Icons.check_circle,
                          color: _updateAvailable
                              ? Colors.green
                              : Colors.grey,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _updateAvailable
                                ? "New update available"
                                : "You're on the latest version",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _updateAvailable
                                  ? Colors.green
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// Update Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: updateBtnEnabled
                            ? Colors.blue
                            : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: updateBtnEnabled ? _applyUpdate : null,
                      child: _isInstalling
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        "Update Now",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}