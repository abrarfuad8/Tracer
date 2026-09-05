import 'package:flutter/material.dart';

import '../models/lost_item.dart';
import '../services/lost_item_service.dart';
import 'item_details_page.dart';
import 'lost_items_page.dart';
import 'report_lost_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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

  @override
  void initState() {
    super.initState();
    _loadLostItems();
  }

  Future<void> _loadLostItems() async {
    final items = await _lostItemService.getLostItems();
    final statistics = _lostItemService.getStatistics(items);

    if (!mounted) return;

    setState(() {
      _lostItems = items;
      _statistics = statistics;
    });
  }

  Future<void> _openReportLostPage() async {
    final LostItem? newItem = await Navigator.push<LostItem>(
      context,
      MaterialPageRoute(builder: (context) => const ReportLostPage()),
    );

    if (newItem != null) {
      await _loadLostItems();
    }
  }

  Future<void> _openLostItemsPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LostItemsPage()),
    );

    await _loadLostItems();
  }

  Future<void> _openDetails(LostItem item) async {
    final bool? result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => ItemDetailsPage(item: item)),
    );

    if (result == true) {
      await _loadLostItems();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final recentItems = _lostItems.take(3).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Tracer')),
      body: RefreshIndicator(
        onRefresh: _loadLostItems,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Welcome to Tracer',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Reports',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.search)),
                    title: Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${item.location} • ${_formatDate(item.dateLost)}',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
