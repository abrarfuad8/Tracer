import 'dart:io';

import 'package:flutter/material.dart';

import '../models/lost_item.dart';
import '../models/user.dart';
import '../services/lost_item_service.dart';
import 'item_details_page.dart';

class LostItemsPage extends StatefulWidget {
  final User user;

  const LostItemsPage({super.key, required this.user});

  @override
  State<LostItemsPage> createState() => _LostItemsPageState();
}

class _LostItemsPageState extends State<LostItemsPage> {
  final LostItemService _lostItemService = LostItemService();

  final TextEditingController _searchController = TextEditingController();

  List<LostItem> _allItems = [];
  List<LostItem> _filteredItems = [];

  ItemCategory? _selectedCategory;
  ItemStatus? _selectedStatus;

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

      items.sort((a, b) => b.dateLost.compareTo(a.dateLost));

      if (!mounted) return;

      setState(() {
        _allItems = items;
        _isLoading = false;
      });

      _filterItems();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load lost items')),
      );
    }
  }

  void _filterItems() {
    final searchText = _searchController.text.trim().toLowerCase();

    final filtered = _allItems.where((item) {
      final matchesSearch =
          item.title.toLowerCase().contains(searchText) ||
          item.location.toLowerCase().contains(searchText) ||
          item.description.toLowerCase().contains(searchText) ||
          item.category.name.toLowerCase().contains(searchText);

      final matchesCategory =
          _selectedCategory == null || item.category == _selectedCategory;

      final matchesStatus =
          _selectedStatus == null || item.status == _selectedStatus;

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();

    if (!mounted) return;

    setState(() {
      _filteredItems = filtered;
    });
  }

  void _changeCategory(ItemCategory? category) {
    setState(() {
      _selectedCategory = category;
    });

    _filterItems();
  }

  void _changeStatus(ItemStatus? status) {
    setState(() {
      _selectedStatus = status;
    });

    _filterItems();
  }

  void _clearFilters() {
    _searchController.clear();

    setState(() {
      _selectedCategory = null;
      _selectedStatus = null;
    });

    _filterItems();
  }

  bool get _hasActiveFilters {
    return _searchController.text.trim().isNotEmpty ||
        _selectedCategory != null ||
        _selectedStatus != null;
  }

  Future<void> _openDetails(LostItem item) async {
    final bool? result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailsPage(item: item, user: widget.user),
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

  String _formatStatus(ItemStatus status) {
    switch (status) {
      case ItemStatus.lost:
        return 'Lost';

      case ItemStatus.found:
        return 'Found';

      case ItemStatus.returned:
        return 'Returned';
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

  IconData _getStatusIcon(ItemStatus status) {
    switch (status) {
      case ItemStatus.lost:
        return Icons.search_off_outlined;

      case ItemStatus.found:
        return Icons.check_circle_outline;

      case ItemStatus.returned:
        return Icons.assignment_turned_in_outlined;
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

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imagePath,
          width: 70,
          height: 70,
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
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(item);
        },
      ),
    );
  }

  Widget _buildPlaceholder(LostItem item) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(_getCategoryIcon(item.category), size: 30),
    );
  }

  Widget _buildStatusChip(ItemStatus status) {
    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(status), size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            _formatStatus(status),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 20),
          const SizedBox(width: 8),
          Text(
            '${_filteredItems.length} result(s)',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          if (_hasActiveFilters)
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('Clear'),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: 420,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _hasActiveFilters
                        ? Icons.search_off
                        : Icons.inventory_2_outlined,
                    size: 65,
                    color: Colors.grey,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    _hasActiveFilters
                        ? 'No matching items'
                        : 'No lost items yet',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _hasActiveFilters
                        ? 'Try changing your search or filters.'
                        : 'There are no reports available yet.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),

                  if (_hasActiveFilters) ...[
                    const SizedBox(height: 18),
                    OutlinedButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.filter_alt_off),
                      label: const Text('Clear Filters'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(LostItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _openDetails(item);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildItemImage(item),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        Icon(
                          _getCategoryIcon(item.category),
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _formatCategory(item.category),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        _buildStatusChip(item.status),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(Icons.arrow_forward_ios, size: 15, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lost Items')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search items, locations...',
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
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      ChoiceChip(
                        label: const Text('All Categories'),
                        selected: _selectedCategory == null,
                        onSelected: (_) {
                          _changeCategory(null);
                        },
                      ),

                      const SizedBox(width: 8),

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

                const SizedBox(height: 6),

                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      ChoiceChip(
                        avatar: const Icon(Icons.all_inclusive, size: 18),
                        label: const Text('All Status'),
                        selected: _selectedStatus == null,
                        onSelected: (_) {
                          _changeStatus(null);
                        },
                      ),

                      const SizedBox(width: 8),

                      ...ItemStatus.values.map((status) {
                        final color = _getStatusColor(status);

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            avatar: Icon(
                              _getStatusIcon(status),
                              size: 18,
                              color: color,
                            ),
                            label: Text(_formatStatus(status)),
                            selected: _selectedStatus == status,
                            onSelected: (_) {
                              _changeStatus(status);
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                _buildFilterHeader(),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadItems,
                    child: _filteredItems.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredItems.length,
                            itemBuilder: (context, index) {
                              return _buildItemCard(_filteredItems[index]);
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
