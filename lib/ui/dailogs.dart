import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../auth/local_auth_service.dart';
import '../data/vault_repository.dart';
import '../model/vault_item.dart';

// ─────────────────────────────────────────────
// Create Dialog
// ─────────────────────────────────────────────

void showCreateDialog(BuildContext c) {
  final titleCtrl = TextEditingController();
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool obscure = true;

  showDialog(
    context: c,
    barrierDismissible: false,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
        titlePadding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 16),
        contentPadding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
        title: _dialogTitle(Icons.add_rounded, 'New Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create a new password entry',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 24),
              _inputField(
                controller: titleCtrl,
                label: 'Title',
                hint: 'e.g., Gmail, IRCTC, SBI',
                icon: Icons.label_outline_rounded,
              ),
              const SizedBox(height: 14),
              _inputField(
                controller: userCtrl,
                label: 'Username / Email / ID',
                hint: 'e.g., [user@email.com](mailto:user@email.com) or 9876543210',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 14),
              _passwordField(
                controller: passCtrl,
                label: 'Password',
                hint: 'Enter password',
                obscure: obscure,
                onToggle: () => setState(() => obscure = !obscure),
              ),
              const SizedBox(height: 12),
              _infoBox(
                'Title and password are required fields. Username is optional but recommended.',
              ),
            ],
          ),
        ),
        actions: [
          _cancelButton(c),
          _primaryButton(
            label: 'Save',
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) {
                if (c.mounted) {
                  _showSnack(c, 'Title is required', isError: true);
                }
                return;
              }
              if (passCtrl.text.isEmpty) {
                if (c.mounted) {
                  _showSnack(c, 'Password is required', isError: true);
                }
                return;
              }

              final success = await LocalAuthService().authenticate();
              if (!success) {
                if (!c.mounted) return;
                Navigator.pop(c);
                return;
              }

              if (c.mounted) {
                await VaultRepository().create(
                  titleCtrl.text.trim(),
                  passCtrl.text,
                  username: userCtrl.text.trim(),
                );
                Navigator.pop(c);
                _showSnack(c, 'Password saved successfully');
              }
            },
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────
// Update Dialog
// ─────────────────────────────────────────────

void showUpdateDialog(BuildContext c, VaultItem item) {
  final userCtrl = TextEditingController(text: item.username);
  final passCtrl = TextEditingController();
  bool obscure = true;

  showDialog(
    context: c,
    barrierDismissible: false,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
        titlePadding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 16),
        contentPadding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
        title: _dialogTitle(Icons.edit_rounded, 'Edit Entry'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update credentials for ${item.title}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Username (always editable, not versioned)
              _inputField(
                controller: userCtrl,
                label: 'Username / Email / ID',
                hint: 'Enter username or ID',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 14),

              // New password (optional — leave blank to keep current)
              _passwordField(
                controller: passCtrl,
                label: 'New Password (optional)',
                hint: 'Leave blank to keep current',
                obscure: obscure,
                onToggle: () => setState(() => obscure = !obscure),
              ),
              const SizedBox(height: 16),
              _infoBox(
                'A new password version will be created if you enter a new password. Username changes apply immediately.',
              ),
            ],
          ),
        ),
        actions: [
          _cancelButton(c),
          _primaryButton(
            label: 'Update',
            onPressed: () async {
              final success = await LocalAuthService().authenticate();
              if (!success) {
                if (!c.mounted) return;
                Navigator.pop(c);
                return;
              }

              if (c.mounted) {
                final repo = VaultRepository();
                // Always update username
                await repo.updateUsername(item.id, userCtrl.text.trim());
                // Only add a password version if a new one was entered
                if (passCtrl.text.isNotEmpty) {
                  await repo.update(item.id, passCtrl.text);
                }
                Navigator.pop(c);
                _showSnack(c, 'Updated successfully');
              }
            },
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────

Widget _dialogTitle(IconData icon, String label) => Row(
  children: [
    Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF4F46E5).withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: const Color(0xFF4F46E5), size: 20),
    ),
    const SizedBox(width: 16),
    Expanded(
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          letterSpacing: 0.2,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ],
);

Widget _inputField({
  required TextEditingController controller,
  required String label,
  required String hint,
  required IconData icon,
}) =>
    TextField(
      controller: controller,
      style: const TextStyle(fontSize: 16),
      decoration: _decoration(
        label: label,
        hint: hint,
        icon: icon,
      ),
    );

Widget _passwordField({
  required TextEditingController controller,
  required String label,
  required String hint,
  required bool obscure,
  required VoidCallback onToggle,
}) =>
    TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontSize: 16),
      decoration: _decoration(
        label: label,
        hint: hint,
        icon: Icons.lock_outline_rounded,
        suffix: Container(
          width: 60,
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(
              obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: Colors.grey.shade600,
              size: 20,
            ),
            onPressed: onToggle,
          ),
        ),
      ),
    );

InputDecoration _decoration({
  required String label,
  required String hint,
  required IconData icon,
  Widget? suffix,
}) =>
    InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      labelStyle: TextStyle(
        color: Colors.grey.shade700,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: Colors.grey.shade600),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
      ),
      hoverColor: Colors.grey.shade200,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      isDense: true,
    );

Widget _infoBox(String text) => Container(
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: Colors.blue.shade50,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.blue.shade200),
  ),
  child: Row(
    children: [
      Icon(Icons.info_outline_rounded, size: 16, color: Colors.blue.shade700),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
        ),
      ),
    ],
  ),
);

Widget _cancelButton(BuildContext c) => TextButton(
  onPressed: () => Navigator.pop(c),
  style: TextButton.styleFrom(
    foregroundColor: Colors.grey.shade700,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  child: const Text(
    'Cancel',
    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
  ),
);

Widget _primaryButton({required String label, required VoidCallback onPressed}) =>
    ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      child: Text(label),
    );

void _showSnack(BuildContext c, String message, {bool isError = false}) {
  ScaffoldMessenger.of(c).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: isError ? Colors.orange.shade600 : const Color(0xFF10B981),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // margin: EdgeInsets.only(
      //   bottom: MediaQuery.of(c).size.height - 100,
      //   left: 20,
      //   right: 20,
      // ),
      content: Row(
        children: [
          Icon(
            isError ? Icons.warning_rounded : Icons.check_circle_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}