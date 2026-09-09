import 'dart:io';

import 'package:flutter/material.dart';

import '../models/lost_item.dart';
import '../models/user.dart';
import '../services/lost_item_service.dart';
import 'item_details_page.dart' as details;
import 'lost_items_page.dart' as lost;
import 'my_reports_page.dart';
import 'profile_page.dart';
import 'report_lost_page.dart';
import 'security_center_page.dart';

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

  @override
  void initState() {
    super.initState();

    _loadLostItems();
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
      MaterialPageRoute(
        builder: (context) => lost.LostItemsPage(user: widget.user),
      ),
    );

    await _loadLostItems();
  }

  Future<void> _openDetails(LostItem item) async {
    final bool? result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            details.ItemDetailsPage(item: item, user: widget.user),
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

  Future<void> _openSecurityCenter() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SecurityCenterPage()),
    );
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
        return Colors.orange;

      case ItemStatus.found:
        return Colors.blue;

      case ItemStatus.returned:
        return Colors.green;
    }
  }

  Widget _buildRecentItemImage(LostItem item) {
    final imagePath = item.imageUrl;

    if (imagePath == null || imagePath.isEmpty) {
      return _buildImagePlaceholder(item);
    }

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imagePath,
          width: 65,
          height: 65,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImagePlaceholder(item);
          },
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        File(imagePath),
        width: 65,
        height: 65,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder(item);
        },
      ),
    );
  }

  Widget _buildImagePlaceholder(LostItem item) {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(_getCategoryIcon(item.category), size: 28),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recentItems = _lostItems.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracer'),
        actions: [
          IconButton(
            onPressed: _openProfile,
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadLostItems,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Welcome, ${widget.user.name}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Track lost items and help them find their way home.',
                    style: TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Overview',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total',
                          value: _statistics['total']!,
                          icon: Icons.inventory_2_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Lost',
                          value: _statistics['lost']!,
                          icon: Icons.search_off_outlined,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Found',
                          value: _statistics['found']!,
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Returned',
                          value: _statistics['returned']!,
                          icon: Icons.assignment_turned_in_outlined,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.security)),
                      title: const Text(
                        'Security Center',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Security tips and safe usage'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _openSecurityCenter,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _openReportLostPage,
                          icon: const Icon(Icons.add),
                          label: const Text('Report Lost'),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openLostItemsPage,
                          icon: const Icon(Icons.list_alt),
                          label: const Text('View Items'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _openMyReports,
                      icon: const Icon(Icons.assignment_outlined),
                      label: const Text('My Reports'),
                    ),
                  ),

                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Reports',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      TextButton(
                        onPressed: _openLostItemsPage,
                        child: const Text('View All'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  if (recentItems.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 50),

                            const SizedBox(height: 12),

                            const Text(
                              'No reports yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            const Text(
                              'Create your first lost item report.',
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 16),

                            ElevatedButton(
                              onPressed: _openReportLostPage,
                              child: const Text('Create Report'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...recentItems.map((item) {
                      final statusColor = _getStatusColor(item.status);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),

                          leading: _buildRecentItemImage(item),

                          title: Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.location} • '
                                  '${_formatDate(item.dateLost)}',
                                ),

                                const SizedBox(height: 5),

                                Row(
                                  children: [
                                    Icon(
                                      _getCategoryIcon(item.category),
                                      size: 14,
                                    ),

                                    const SizedBox(width: 4),

                                    Text(
                                      _formatCategory(item.category),
                                      style: const TextStyle(fontSize: 12),
                                    ),

                                    const SizedBox(width: 10),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        item.status.name.toUpperCase(),
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),

                          onTap: () {
                            _openDetails(item);
                          },
                        ),
                      );
                    }),
                ],
              ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30),

            const SizedBox(height: 12),

            Text(
              '$value',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(title),
          ],
        ),
      ),
    );
  }
}
