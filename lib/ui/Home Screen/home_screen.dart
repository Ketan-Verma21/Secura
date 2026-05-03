import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';
import '../../model/vault_item.dart';
import '../dailogs.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:secura/data/vault_repository.dart';
import '../../auth/local_auth_service.dart';
import '../details_screen.dart';
import '../Settings Screen/settings_screen.dart';
class VaultHome extends StatefulWidget {
  const VaultHome({super.key});

  @override
  State<VaultHome> createState() => _VaultHomeState();
}

class _VaultHomeState extends State<VaultHome> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<VaultItem>('vault');

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus!.unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text(
            'My Vault',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
          ),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1A1A2E),
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: Colors.grey.shade200, height: 1),
          ),
        ),
        drawer: Drawer(
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Logo Container
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/1.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.bug_report_rounded,
                  title: 'R E P O R T',
                  subtitle: 'Report a bug to the developer',
                  color: const Color(0xFF7C3AED),
                  onTap: () {
                    BetterFeedback.of(
                      context,
                    ).show((UserFeedback feedback) async {
                    });
                  },
                ),
                _buildDrawerItem(context: context, icon: Icons.settings_outlined, title: "S E T T I N G S", subtitle: "Access the settings here", color: const Color(0xFF7C3AED), onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SettingsScreen()),
                  );
                })
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showCreateDialog(context),
          backgroundColor: const Color(0xFF4F46E5),
          elevation: 4,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            'Add Item',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
        body: ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (_, Box<VaultItem> b, __) {
            // Alphabetical sort
            final allItems = b.values.toList()
              ..sort(
                (a, c) =>
                    a.title.toLowerCase().compareTo(c.title.toLowerCase()),
              );

            final filteredItems = _searchQuery.isEmpty
                ? allItems
                : allItems
                      .where(
                        (item) =>
                            item.title.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ) ||
                            item.username.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ),
                      )
                      .toList();

            return Column(
              children: [
                // Search + Stats header
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    children: [
                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search by title or username…',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: Colors.grey.shade600,
                              size: 22,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear_rounded,
                                      color: Colors.grey.shade600,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onChanged: (v) => setState(() => _searchQuery = v),
                        ),
                      ),
                    ],
                  ),
                ),

                // List
                Expanded(
                  child: filteredItems.isEmpty
                      ? _emptyState()
                      : RefreshIndicator(
                          onRefresh: () async => setState(() {}),
                          color: const Color(0xFF4F46E5),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                            itemCount: filteredItems.length,
                            itemBuilder: (_, index) {
                              // Section header for alphabetical grouping
                              final item = filteredItems[index];
                              final showHeader =
                                  index == 0 ||
                                  filteredItems[index - 1].title[0]
                                          .toUpperCase() !=
                                      item.title[0].toUpperCase();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (showHeader && _searchQuery.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 8,
                                        top: 4,
                                        left: 4,
                                      ),
                                      child: Text(
                                        item.title[0].toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.grey.shade500,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  _VaultCard(item: item),
                                  const SizedBox(height: 10),
                                ],
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _statChip({
    required IconData icon,
    required String label,
    required Color color,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    ),
  );

  Widget _emptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _searchQuery.isEmpty
              ? Icons.lock_outline_rounded
              : Icons.search_off_rounded,
          size: 80,
          color: Colors.grey.shade300,
        ),
        const SizedBox(height: 16),
        Text(
          _searchQuery.isEmpty ? 'No passwords yet' : 'No results found',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _searchQuery.isEmpty
              ? 'Tap the + button to add your first password'
              : 'Try searching by title or username',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        ),
      ],
    ),
  );
  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Vault Card Widget
// ─────────────────────────────────────────────
class _VaultCard extends StatelessWidget {
  final VaultItem item;
  const _VaultCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      // ────── SWIPE LEFT: DELETE ──────
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => _confirmDelete(context, item),
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            icon: Icons.delete_rounded,
            label: 'Delete',
          ),
        ],
      ),

      // ────── SWIPE RIGHT: COPY USERNAME ──────
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.3,
        children: [
          SlidableAction(
            onPressed: (_) async {
              if (item.username.isEmpty) {
                _showSnack(context, 'No username saved', isError: true);
              } else {
                await Clipboard.setData(ClipboardData(text: item.username));
                _showSnack(context, 'Username copied to clipboard');
              }
            },
            backgroundColor: const Color(0xFF4F46E5),
            foregroundColor: Colors.white,
            icon: Icons.person_rounded,
            label: 'Username',
          ),
        ],
      ),

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            // ────── TAP: OPEN DETAIL ──────
            onTap: () async {
              if (await LocalAuthService().authenticate()) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => VaultDetail(item: item)),
                );
              }
            },

            // ────── LONG PRESS: COPY PASSWORD ──────
            onLongPress: () => _copyPasswordOnLongPress(context, item),

            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        item.title[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Subtitle with hint for quick actions
                        Row(
                          children: [
                            // if (item.username.isNotEmpty)
                            //   Expanded(
                            //     child: Text(
                            //       item.username,
                            //       style: TextStyle(
                            //         fontSize: 12,
                            //         color: Colors.grey.shade600,
                            //       ),
                            //       maxLines: 1,
                            //       overflow: TextOverflow.ellipsis,
                            //     ),
                            //   )
                            // else
                            Expanded(
                              child: Text(
                                '${item.versionIds.length} password version${item.versionIds.length != 1 ? 's' : ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Quick action hint
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Hold to copy',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade400,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Long press: Fetch latest password and copy it
  Future<void> _copyPasswordOnLongPress(
    BuildContext context,
    VaultItem item,
  ) async {
    // Get latest password (last in versionIds)
    if (item.versionIds.isEmpty) {
      _showSnack(context, 'No password saved', isError: true);
      return;
    }

    // Require biometric auth before copying
    if (!await LocalAuthService().authenticate()) {
      return;
    }

    // Fetch the latest password
    final latestVersionId = item.versionIds.last;
    final password = await VaultRepository().get(item.id, latestVersionId);

    if (password == null) {
      _showSnack(context, 'Failed to load password', isError: true);
      return;
    }

    // Copy to clipboard
    await Clipboard.setData(ClipboardData(text: password));

    // Show feedback
    _showSnack(context, 'Password copied to clipboard');

    // Auto-clear clipboard after 30 seconds for security
    await Future.delayed(const Duration(seconds: 30));
    await Clipboard.setData(const ClipboardData(text: ''));
  }

  /// Delete with confirmation
  Future<void> _confirmDelete(BuildContext context, VaultItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Entry',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete "${item.title}"? This cannot be undone.',
          style: TextStyle(color: Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade600),
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await VaultRepository().delete(item.id);
    }
  }

  /// Show snackbar feedback
  void _showSnack(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.warning_rounded : Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError
            ? Colors.orange.shade600
            : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
