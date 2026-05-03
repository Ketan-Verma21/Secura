import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/vault_repository.dart';
import '../model/vault_item.dart';
import 'dailogs.dart';

class VaultDetail extends StatefulWidget {
  final VaultItem item;
  const VaultDetail({super.key, required this.item});

  @override
  State<VaultDetail> createState() => _VaultDetailState();
}

class _VaultDetailState extends State<VaultDetail>
    with SingleTickerProviderStateMixin {
  final repo = VaultRepository();
  bool _showPasswords = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));

    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white,
                  size: 18
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Copied to clipboard',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        elevation: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFBFC),
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          title: Text(
            widget.item.title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 22,
              letterSpacing: -0.5,
              color: Color(0xFF0F172A),
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0F172A),
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 24),
            onPressed: () => Navigator.pop(context),
            splashRadius: 28,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: _showPasswords
                      ? const Color(0xFF6366F1).withOpacity(0.08)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      _showPasswords
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      key: ValueKey(_showPasswords),
                      color: _showPasswords
                          ? const Color(0xFF6366F1)
                          : const Color(0xFF64748B),
                      size: 22,
                    ),
                  ),
                  onPressed: () {
                    setState(() => _showPasswords = !_showPasswords);
                    HapticFeedback.lightImpact();
                  },
                  splashRadius: 28,
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0.5),
            child: Container(
              color: const Color(0xFFE2E8F0).withOpacity(0.5),
              height: 0.5,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            HapticFeedback.mediumImpact();
            showUpdateDialog(context, widget.item);
          },
          backgroundColor: const Color(0xFF6366F1),
          elevation: 8,
          highlightElevation: 12,
          icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 22),
          label: const Text(
            'Edit Password',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 15,
              letterSpacing: 0.3,
            ),
          ),
        ),
        body: widget.item.versionIds.isEmpty
            ? _buildEmptyState()
            : _buildPasswordsList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF6366F1).withOpacity(0.1),
                      const Color(0xFF8B5CF6).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.lock_open_rounded,
                  size: 60,
                  color: const Color(0xFF6366F1).withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'No Password Yet',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Create your first password to secure this entry',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF64748B),
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  showUpdateDialog(context, widget.item);
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Password'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordsList() {
    return CustomScrollView(
      slivers: [
        // Username section
        if (widget.item.username.isNotEmpty)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Username',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      _copyToClipboard(widget.item.username);
                    },
                    child: SelectableText(
                      widget.item.username,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Password history header
        SliverPersistentHeader(
          pinned: true,
          delegate: _PasswordHistoryHeaderDelegate(),
        ),

        // Password versions list
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final isLatest = index == widget.item.versionIds.length - 1;
                final versionId = widget.item.versionIds[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: FutureBuilder<String?>(
                    future: repo.get(widget.item.id, versionId),
                    builder: (context, snapshot) {
                      final password = snapshot.data;

                      return _buildPasswordCard(
                        password: password,
                        isLoading: snapshot.connectionState ==
                            ConnectionState.waiting,
                        isLatest: isLatest,
                        index: index,
                      );
                    },
                  ),
                );
              },
              childCount: widget.item.versionIds.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordCard({
    required String? password,
    required bool isLoading,
    required bool isLatest,
    required int index,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isLatest
            ? Border.all(
          color: const Color(0xFF6366F1),
          width: 2,
        )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isLatest ? 0.06 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isLatest
                  ? const Color(0xFF6366F1).withOpacity(0.06)
                  : const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              border: isLatest
                  ? Border(
                bottom: BorderSide(
                  color: const Color(0xFF6366F1).withOpacity(0.2),
                  width: 0,
                ),
              )
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isLatest
                        ? const Color(0xFF6366F1).withOpacity(0.15)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isLatest ? Icons.star_rounded : Icons.history_rounded,
                    size: 16,
                    color: isLatest
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLatest ? 'Current Password' : 'Version ${index + 1}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isLatest
                              ? const Color(0xFF6366F1)
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      if (isLatest)
                        const SizedBox(height: 2),
                      if (isLatest)
                        Text(
                          'Latest version',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6366F1).withOpacity(0.7),
                          ),
                        ),
                    ],
                  ),
                ),
                if (isLatest)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Password display
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: const Color(0xFF6366F1),
                          ),
                        )
                            : SelectableText(
                          _showPasswords && password != null
                              ? password
                              : '••••••••••••••••',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: _showPasswords
                                ? const Color(0xFF0F172A)
                                : const Color(0xFF94A3B8),
                            letterSpacing: _showPasswords ? 0 : 3,
                          ),
                        ),
                      ),
                    ),
                    if (password != null) ...[
                      const SizedBox(width: 12),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _copyToClipboard(password),
                          borderRadius: BorderRadius.circular(12),
                          highlightColor:
                          const Color(0xFF6366F1).withOpacity(0.1),
                          splashColor:
                          const Color(0xFF6366F1).withOpacity(0.15),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                const Color(0xFF6366F1).withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.copy_rounded,
                              size: 20,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordHistoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return Container(
      color: const Color(0xFFFAFBFC),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Text(
        'PASSWORD HISTORY',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF94A3B8),
          letterSpacing: 1,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 56;

  @override
  double get minExtent => 56;

  @override
  bool shouldRebuild(_PasswordHistoryHeaderDelegate oldDelegate) => false;
}