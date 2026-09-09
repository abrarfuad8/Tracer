import 'package:flutter/material.dart';

import '../models/lost_item.dart';
import '../models/user.dart';
import '../services/lost_item_service.dart';
import 'item_details_page.dart';
import 'report_lost_page.dart';

class MyReportsPage extends StatefulWidget {
  final User user;

  const MyReportsPage({super.key, required this.user});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  final LostItemService _lostItemService = LostItemService();

  List<LostItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyReports();
  }

  Future<void> _loadMyReports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await _lostItemService.getLostItemsByOwner(widget.user.id);

      if (!mounted) return;

      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load your reports')),
      );
    }
  }

  Future<void> _openDetails(LostItem item) async {
    final bool? result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailsPage(item: item, user: widget.user),
      ),
    );

    if (result == true) {
      await _loadMyReports();
    }
  }

  Future<void> _createReport() async {
    final LostItem? newItem = await Navigator.push<LostItem>(
      context,
      MaterialPageRoute(
        builder: (context) => ReportLostPage(user: widget.user),
      ),
    );

    if (newItem != null) {
      await _loadMyReports();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getStatusText(ItemStatus status) {
    switch (status) {
      case ItemStatus.lost:
        return 'Lost';
      case ItemStatus.found:
        return 'Found';
      case ItemStatus.returned:
        return 'Returned';
    }
  }

  IconData _getStatusIcon(ItemStatus status) {
    switch (status) {
      case ItemStatus.lost:
        return Icons.search_off;
      case ItemStatus.found:
        return Icons.check_circle_outline;
      case ItemStatus.returned:
        return Icons.assignment_turned_in_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: RefreshIndicator(onRefresh: _loadMyReports, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 70),

          const Icon(Icons.inventory_2_outlined, size: 80),

          const SizedBox(height: 20),

          const Text(
            'No Reports Yet',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          const Text(
            'You have not created any lost item reports yet.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),

          const SizedBox(height: 30),

          ElevatedButton.icon(
            onPressed: _createReport,
            icon: const Icon(Icons.add),
            label: const Text('Create First Report'),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  child: Icon(Icons.person_outline),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${_items.length} report(s)'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Your Reports',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        ..._items.map(
          (item) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),

              leading: CircleAvatar(child: Icon(_getStatusIcon(item.status))),

              title: Text(
                item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),

              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${item.location}\n'
                  '${_formatDate(item.dateLost)} • '
                  '${_getStatusText(item.status)}',
                ),
              ),

              isThreeLine: true,

              trailing: const Icon(Icons.arrow_forward_ios, size: 16),

              onTap: () {
                _openDetails(item);
              },
            ),
          ),
        ),
      ],
    );
  }
}
