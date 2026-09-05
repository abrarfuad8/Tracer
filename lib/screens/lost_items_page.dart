import 'package:flutter/material.dart';

import '../models/lost_item.dart';
import '../services/lost_item_service.dart';
import 'item_details_page.dart';

class LostItemsPage extends StatefulWidget {
  const LostItemsPage({super.key});

  @override
  State<LostItemsPage> createState() => _LostItemsPageState();
}

class _LostItemsPageState extends State<LostItemsPage> {
  final LostItemService _lostItemService = LostItemService();

  List<LostItem> _allItems = [];
  List<LostItem> _filteredItems = [];

  final TextEditingController _searchController = TextEditingController();

  ItemCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();

    _loadItems();

    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterItems);
    _searchController.dispose();

    super.dispose();
  }

  Future<void> _loadItems() async {
    final items = await _lostItemService.getLostItems();

    if (!mounted) return;

    setState(() {
      _allItems = items;
      _filteredItems = items;
    });

    _filterItems();
  }

  void _filterItems() {
    final searchText = _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredItems = _allItems.where((item) {
        final matchesSearch =
            item.title.toLowerCase().contains(searchText) ||
            item.location.toLowerCase().contains(searchText) ||
            item.description.toLowerCase().contains(searchText);

        final matchesCategory =
            _selectedCategory == null || item.category == _selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _changeCategory(ItemCategory? category) {
    setState(() {
      _selectedCategory = category;
    });

    _filterItems();
  }

  Future<void> _openDetails(LostItem item) async {
    final bool? result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => ItemDetailsPage(item: item)),
    );

    if (result == true) {
      await _loadItems();
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lost Items')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search lost items...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),

          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _selectedCategory == null,
                    onSelected: (_) {
                      _changeCategory(null);
                    },
                  ),
                ),

                ...ItemCategory.values.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_formatCategory(category)),
                      selected: _selectedCategory == category,
                      onSelected: (_) {
                        _changeCategory(category);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: _filteredItems.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60),
                        SizedBox(height: 12),
                        Text(
                          'No lost items found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            child: Icon(_getCategoryIcon(item.category)),
                          ),
                          title: Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '${_formatCategory(item.category)} • ${item.location}',
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
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
