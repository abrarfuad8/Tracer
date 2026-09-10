import 'dart:io';

import 'package:flutter/material.dart';

import '../Theme/app_theme.dart';
import '../models/lost_item.dart';
import '../models/user.dart';
import '../services/lost_item_service.dart';
import 'item_details_page.dart';
import 'lost_items_page.dart';
import 'my_reports_page.dart';
import 'profile_page.dart';
import 'report_lost_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LostItemService _lostItemService = LostItemService();

  List<LostItem> _lostItems = [];

  Map<String, int> _statistics = {
    'total': 0,
    'lost': 0,
    'found': 0,
    'returned': 0,
  };

  bool _isLoading = true;
  bool _searchOpen = false;

  final TextEditingController _searchController = TextEditingController();

  List<LostItem> get _searchResults {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return [];
    }

    return _lostItems.where((item) {
      return item.title.toLowerCase().contains(query) ||
          item.location.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query) ||
          item.category.name.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();

    _loadLostItems();

    _searchController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLostItems() async {
    try {
      final items = await _lostItemService.getLostItems();
      final statistics = _lostItemService.getStatistics(items);

      if (!mounted) return;

      setState(() {
        _lostItems = items;
        _statistics = statistics;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load reports')));
    }
  }

  Future<void> _openReportLostPage() async {
    final LostItem? newItem = await Navigator.push<LostItem>(
      context,
      MaterialPageRoute(
        builder: (context) => ReportLostPage(user: widget.user),
      ),
    );

    if (newItem != null) {
      await _loadLostItems();
    }
  }

  Future<void> _openLostItemsPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LostItemsPage(user: widget.user)),
    );

    await _loadLostItems();
  }

  Future<void> _openDetails(LostItem item) async {
    final bool? result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailsPage(item: item, user: widget.user),
      ),
    );

    if (result == true) {
      await _loadLostItems();
    }
  }

  Future<void> _openMyReports() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyReportsPage(user: widget.user)),
    );

    await _loadLostItems();
  }

  Future<void> _openProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage(user: widget.user)),
    );

    await _loadLostItems();
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage(user: widget.user)),
    );

    await _loadLostItems();
  }

  void _toggleTheme() {
    AppTheme.toggleTheme();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatCategory(ItemCategory category) {
    switch (category) {
      case ItemCategory.electronics:
        return 'Electronics';

      case ItemCategory.documents:
        return 'Documents';

      case ItemCategory.clothing:
        return 'Clothing';

      case ItemCategory.keys:
        return 'Keys';

      case ItemCategory.bags:
        return 'Bags';

      case ItemCategory.other:
        return 'Other';
    }
  }

  IconData _getCategoryIcon(ItemCategory category) {
    switch (category) {
      case ItemCategory.electronics:
        return Icons.devices_outlined;

      case ItemCategory.documents:
        return Icons.description_outlined;

      case ItemCategory.clothing:
        return Icons.checkroom_outlined;

      case ItemCategory.keys:
        return Icons.key_outlined;

      case ItemCategory.bags:
        return Icons.shopping_bag_outlined;

      case ItemCategory.other:
        return Icons.category_outlined;
    }
  }

  Color _getStatusColor(ItemStatus status) {
    switch (status) {
      case ItemStatus.lost:
        return AppTheme.lostColor;

      case ItemStatus.found:
        return AppTheme.foundColor;

      case ItemStatus.returned:
        return AppTheme.returnedColor;
    }
  }

  String _getStatusTitle(ItemStatus status) {
    switch (status) {
      case ItemStatus.lost:
        return 'Lost Items';

      case ItemStatus.found:
        return 'Found Items';

      case ItemStatus.returned:
        return 'Returned Items';
    }
  }

  String _getStatusDescription(ItemStatus status) {
    switch (status) {
      case ItemStatus.lost:
        return 'Items that are still reported as lost.';

      case ItemStatus.found:
        return 'Items that have been found.';

      case ItemStatus.returned:
        return 'Items that have been returned to their owners.';
    }
  }

  Widget _buildItemImage(LostItem item, {double size = 58}) {
    final imagePath = item.imageUrl;

    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(_getCategoryIcon(item.category), size: size * 0.45),
      );
    }

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          imagePath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImagePlaceholder(item, size);
          },
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.file(
        File(imagePath),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder(item, size);
        },
      ),
    );
  }

  Widget _buildImagePlaceholder(LostItem item, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(_getCategoryIcon(item.category), size: size * 0.45),
    );
  }

  void _showSearch() {
    setState(() {
      _searchOpen = true;
    });
  }

  void _closeSearch() {
    _searchController.clear();

    setState(() {
      _searchOpen = false;
    });
  }

  void _showSearchResults() {
    final results = _searchResults;

    if (results.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No matching reports found.')),
      );

      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${results.length} result(s)',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          leading: _buildItemImage(item),
                          title: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${item.location} • '
                            '${_formatDate(item.dateLost)}',
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 15,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _openDetails(item);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showStatusItems(ItemStatus status) {
    final items = _lostItems.where((item) => item.status == status).toList();

    final statusColor = _getStatusColor(status);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(
                          Icons.inventory_2_outlined,
                          color: statusColor,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getStatusTitle(status),
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${items.length} item(s)',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 55,
                                  color: statusColor,
                                ),

                                const SizedBox(height: 14),

                                Text(
                                  'No ${status.name} items',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 7),

                                Text(
                                  _getStatusDescription(status),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(10),
                                leading: _buildItemImage(item),
                                title: Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${item.location} • '
                                  '${_formatDate(item.dateLost)}',
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 15,
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  _openDetails(item);
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactStat({
    required String label,
    required int value,
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, size: 20, color: colorScheme.onSurface),
              ),

              const SizedBox(height: 7),

              Text(
                '$value',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),

              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurface.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, size: 23, color: colorScheme.onSurface),

              const SizedBox(height: 7),

              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentItemCard(LostItem item) {
    final statusColor = _getStatusColor(item.status);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _openDetails(item);
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              _buildItemImage(item),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),

                        const SizedBox(width: 6),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            item.status.name.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),

                        const SizedBox(width: 4),

                        Expanded(
                          child: Text(
                            item.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${_formatCategory(item.category)} • '
                      '${_formatDate(item.dateLost)}',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 5),

              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(top: 18),
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),

          const Icon(Icons.search_rounded, size: 21),

          const SizedBox(width: 8),

          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search reports...',
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (_) {
                _showSearchResults();
              },
            ),
          ),

          if (_searchController.text.isNotEmpty)
            IconButton(
              onPressed: _showSearchResults,
              icon: const Icon(Icons.arrow_forward_rounded, size: 20),
            ),

          IconButton(
            onPressed: _closeSearch,
            icon: const Icon(Icons.close_rounded, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: _showSearch,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(top: 18),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_rounded, size: 20),
            SizedBox(width: 8),
            Text(
              'Search reports',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeButton() {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeModeNotifier,
      builder: (context, themeMode, child) {
        final isDark = themeMode == ThemeMode.dark;

        return IconButton(
          onPressed: _toggleTheme,
          tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            minimumSize: const Size(38, 38),
            maximumSize: const Size(38, 38),
            padding: EdgeInsets.zero,
          ),
          icon: Icon(
            isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            size: 19,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final recentItems = _lostItems.take(3).toList();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadLostItems,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
                  children: [
                    // =====================================================
                    // HEADER
                    // =====================================================
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tracer',
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(context).colorScheme.primary,
                                  letterSpacing: -0.5,
                                ),
                              ),

                              const SizedBox(height: 2),

                              Text(
                                'Find what matters.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Theme toggle
                        _buildThemeButton(),

                        const SizedBox(width: 6),

                        // Profile
                        IconButton(
                          onPressed: _openProfile,
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            minimumSize: const Size(38, 38),
                            maximumSize: const Size(38, 38),
                            padding: EdgeInsets.zero,
                          ),
                          icon: const Icon(
                            Icons.person_outline_rounded,
                            size: 20,
                          ),
                        ),
                      ],
                    ),

                    // =====================================================
                    // SEARCH
                    // =====================================================
                    if (_searchOpen)
                      _buildSearchBox()
                    else
                      _buildSearchButton(),

                    const SizedBox(height: 24),

                    // =====================================================
                    // WELCOME
                    // =====================================================
                    Text(
                      'Welcome, ${widget.user.name}',
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Track lost items and help them find their way home.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =====================================================
                    // OVERVIEW
                    // =====================================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Overview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        TextButton(
                          onPressed: _openLostItemsPage,
                          child: const Text('View all'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            _buildCompactStat(
                              label: 'Total',
                              value: _statistics['total']!,
                              icon: Icons.inventory_2_outlined,
                              backgroundColor: AppTheme.paleLemon,
                              onTap: _openLostItemsPage,
                            ),

                            _buildCompactStat(
                              label: 'Lost',
                              value: _statistics['lost']!,
                              icon: Icons.search_off_outlined,
                              backgroundColor: AppTheme.softYellow,
                              onTap: () {
                                _showStatusItems(ItemStatus.lost);
                              },
                            ),

                            _buildCompactStat(
                              label: 'Found',
                              value: _statistics['found']!,
                              icon: Icons.check_circle_outline,
                              backgroundColor: AppTheme.softBlueGray,
                              onTap: () {
                                _showStatusItems(ItemStatus.found);
                              },
                            ),

                            _buildCompactStat(
                              label: 'Returned',
                              value: _statistics['returned']!,
                              icon: Icons.assignment_turned_in_outlined,
                              backgroundColor: AppTheme.softGreen,
                              onTap: () {
                                _showStatusItems(ItemStatus.returned);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // =====================================================
                    // QUICK ACTIONS
                    // =====================================================
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        _buildQuickAction(
                          icon: Icons.add_circle_outline_rounded,
                          label: 'Report Lost',
                          onTap: _openReportLostPage,
                        ),

                        const SizedBox(width: 9),

                        _buildQuickAction(
                          icon: Icons.assignment_outlined,
                          label: 'My Reports',
                          onTap: _openMyReports,
                        ),

                        const SizedBox(width: 9),

                        _buildQuickAction(
                          icon: Icons.settings_outlined,
                          label: 'Settings',
                          onTap: _openSettings,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // =====================================================
                    // RECENT REPORTS
                    // =====================================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Reports',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        TextButton(
                          onPressed: _openLostItemsPage,
                          child: const Text('View all'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    if (recentItems.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 48,
                                color: Theme.of(context).colorScheme.primary,
                              ),

                              const SizedBox(height: 12),

                              const Text(
                                'No reports yet',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                'Create your first lost item report.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                              ),

                              const SizedBox(height: 14),

                              ElevatedButton.icon(
                                onPressed: _openReportLostPage,
                                icon: const Icon(Icons.add),
                                label: const Text('Create Report'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...recentItems.map((item) => _buildRecentItemCard(item)),
                  ],
                ),
        ),
      ),
    );
  }
}
