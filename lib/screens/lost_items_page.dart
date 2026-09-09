import 'dart:io';

import 'package:flutter/material.dart';

import '../models/lost_item.dart';
import '../models/user.dart';
import '../services/lost_item_service.dart';
import 'item_details_page.dart';

class LostItemsPage extends StatefulWidget {
  final User user;

  const LostItemsPage({
    super.key,
    required this.user,
  });

  @override
  State<LostItemsPage> createState() => _LostItemsPageState();
}

class _LostItemsPageState extends State<LostItemsPage> {
  final LostItemService _lostItemService = LostItemService();

  List<LostItem> _allItems = [];
  List<LostItem> _filteredItems = [];

  final TextEditingController _searchController =
  TextEditingController();

  ItemCategory? _selectedCategory;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_filterItems);

    _loadItems();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterItems);
    _searchController.dispose();

    super.dispose();
  }

  Future<void> _loadItems() async {
    try {
      final items = await _lostItemService.getLostItems();

      if (!mounted) return;

      setState(() {
        _allItems = items;
        _filteredItems = items;
        _isLoading = false;
      });

      _filterItems();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to load lost items',
          ),
        ),
      );
    }
  }

  void _filterItems() {
    final searchText =
    _searchController.text.trim().toLowerCase();

    if (!mounted) return;

    setState(() {
      _filteredItems = _allItems.where((item) {
        final matchesSearch =
            item.title.toLowerCase().contains(searchText) ||
                item.location.toLowerCase().contains(searchText) ||
                item.description.toLowerCase().contains(searchText);

        final matchesCategory =
            _selectedCategory == null ||
                item.category == _selectedCategory;

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
      MaterialPageRoute(
        builder: (context) => ItemDetailsPage(
          item: item,
          user: widget.user,
        ),
      ),
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

  Widget _buildItemImage(LostItem item) {
    final imagePath = item.imageUrl;

    if (imagePath == null || imagePath.isEmpty) {
      return _buildPlaceholder(item);
    }

    if (imagePath.startsWith('http://') ||
        imagePath.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imagePath,
          width: 65,
          height: 65,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder(item);
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
          return _buildPlaceholder(item);
        },
      ),
    );
  }

  Widget _buildPlaceholder(LostItem item) {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _getCategoryIcon(item.category),
        size: 28,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost Items'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadItems,
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search lost items...',
                  prefixIcon: const Icon(
                    Icons.search,
                  ),
                  suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                    },
                    icon: const Icon(
                      Icons.clear,
                    ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 8,
                    ),
                    child: ChoiceChip(
                      label: const Text('All'),
                      selected:
                      _selectedCategory == null,
                      onSelected: (_) {
                        _changeCategory(null);
                      },
                    ),
                  ),

                  ...ItemCategory.values.map(
                        (category) {
                      return Padding(
                        padding:
                        const EdgeInsets.only(
                          right: 8,
                        ),
                        child: ChoiceChip(
                          label: Text(
                            _formatCategory(category),
                          ),
                          selected:
                          _selectedCategory ==
                              category,
                          onSelected: (_) {
                            _changeCategory(category);
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: _filteredItems.isEmpty
                  ? ListView(
                children: [
                  SizedBox(
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 60,
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            'No lost items found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            _allItems.isEmpty
                                ? 'There are no reports yet.'
                                : 'Try another search or category.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
                  : ListView.builder(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                itemCount:
                _filteredItems.length,
                itemBuilder:
                    (context, index) {
                  final item =
                  _filteredItems[index];

                  final statusColor =
                  _getStatusColor(
                    item.status,
                  );

                  return Card(
                    margin:
                    const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: ListTile(
                      contentPadding:
                      const EdgeInsets.all(
                        12,
                      ),

                      leading:
                      _buildItemImage(item),

                      title: Text(
                        item.title,
                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      subtitle: Padding(
                        padding:
                        const EdgeInsets.only(
                          top: 6,
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            Text(
                              '${_formatCategory(item.category)}'
                                  ' • ${item.location}',
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Row(
                              children: [
                                Container(
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration:
                                  BoxDecoration(
                                    color:
                                    statusColor
                                        .withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      10,
                                    ),
                                  ),
                                  child: Text(
                                    item.status.name
                                        .toUpperCase(),
                                    style:
                                    TextStyle(
                                      color:
                                      statusColor,
                                      fontSize:
                                      10,
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      trailing:
                      const Icon(
                        Icons
                            .arrow_forward_ios,
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
      ),
    );
  }
}