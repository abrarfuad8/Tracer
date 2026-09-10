import 'dart:io';

import 'package:flutter/material.dart';

import '../models/lost_item.dart';
import '../models/user.dart';
import '../services/lost_item_service.dart';
import 'edit_item_page.dart';

class ItemDetailsPage extends StatefulWidget {
  final LostItem item;
  final User user;

  const ItemDetailsPage({super.key, required this.item, required this.user});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  final LostItemService _lostItemService = LostItemService();

  late LostItem _item;

  bool _isUpdatingStatus = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  bool get _isOwner {
    return _item.ownerId == widget.user.id;
  }

  String _categoryLabel(ItemCategory category) {
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

  IconData _categoryIcon(ItemCategory category) {
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

  String _statusLabel(ItemStatus status) {
    switch (status) {
      case ItemStatus.lost:
        return 'Lost';
      case ItemStatus.found:
        return 'Found';
      case ItemStatus.returned:
        return 'Returned';
    }
  }

  IconData _statusIcon(ItemStatus status) {
    switch (status) {
      case ItemStatus.lost:
        return Icons.search_off_rounded;
      case ItemStatus.found:
        return Icons.check_circle_outline_rounded;
      case ItemStatus.returned:
        return Icons.assignment_turned_in_outlined;
    }
  }

  Color _statusColor(ItemStatus status) {
    switch (status) {
      case ItemStatus.lost:
        return Colors.orange;
      case ItemStatus.found:
        return Colors.blue;
      case ItemStatus.returned:
        return Colors.green;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Center(child: Icon(Icons.image_outlined, size: 70)),
    );
  }

  Widget _buildImageError() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Center(child: Icon(Icons.broken_image_outlined, size: 60)),
    );
  }

  Widget _buildItemImage() {
    final imagePath = _item.imageUrl;

    if (imagePath == null || imagePath.trim().isEmpty) {
      return _buildImagePlaceholder();
    }

    final isNetworkImage =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');

    return GestureDetector(
      onTap: () {
        _showFullImage(imagePath, isNetworkImage);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          height: 250,
          width: double.infinity,
          child: isNetworkImage
              ? Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImageError();
                  },
                )
              : Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImageError();
                  },
                ),
        ),
      ),
    );
  }

  void _showFullImage(String imagePath, bool isNetworkImage) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: InteractiveViewer(
            child: isNetworkImage
                ? Image.network(imagePath, fit: BoxFit.contain)
                : Image.file(File(imagePath), fit: BoxFit.contain),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: colorScheme.onPrimaryContainer,
                size: 21,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    final color = _statusColor(_item.status);

    String? buttonText;
    IconData? buttonIcon;

    if (_item.status == ItemStatus.lost) {
      buttonText = 'Mark as Found';
      buttonIcon = Icons.check_circle_outline;
    } else if (_item.status == ItemStatus.found) {
      buttonText = 'Mark as Returned';
      buttonIcon = Icons.assignment_turned_in_outlined;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Current Status',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(_item.status), size: 16, color: color),
                      const SizedBox(width: 5),
                      Text(
                        _statusLabel(_item.status),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (_isOwner && buttonText != null) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isUpdatingStatus ? null : _changeStatus,
                  icon: _isUpdatingStatus
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(buttonIcon),
                  label: Text(_isUpdatingStatus ? 'Updating...' : buttonText),
                ),
              ),
            ],

            if (_isOwner && _item.status == ItemStatus.returned) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.check_circle, size: 18, color: color),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('This item has been successfully returned.'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _changeStatus() async {
    ItemStatus newStatus;

    if (_item.status == ItemStatus.lost) {
      newStatus = ItemStatus.found;
    } else if (_item.status == ItemStatus.found) {
      newStatus = ItemStatus.returned;
    } else {
      return;
    }

    final newStatusLabel = _statusLabel(newStatus);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Status?'),
          content: Text(
            'Are you sure you want to mark this item as $newStatusLabel?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      final updatedItem = LostItem(
        id: _item.id,
        title: _item.title,
        category: _item.category,
        description: _item.description,
        location: _item.location,
        dateLost: _item.dateLost,
        imageUrl: _item.imageUrl,
        status: newStatus,
        contactInfo: _item.contactInfo,
        ownerId: _item.ownerId,
      );

      await _lostItemService.updateLostItem(updatedItem);

      if (!mounted) {
        return;
      }

      setState(() {
        _item = updatedItem;
        _hasChanges = true;
        _isUpdatingStatus = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item marked as $newStatusLabel successfully.')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isUpdatingStatus = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update the item status.')),
      );
    }
  }

  Future<void> _editItem() async {
    final updatedItem = await Navigator.push<LostItem>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return EditItemPage(item: _item);
        },
      ),
    );

    if (updatedItem == null || !mounted) {
      return;
    }

    setState(() {
      _item = updatedItem;
      _hasChanges = true;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Item updated successfully.')));
  }

  Future<void> _deleteItem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Report?'),
          content: const Text(
            'Are you sure you want to delete this report? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _lostItemService.deleteLostItem(_item.id);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report deleted successfully.')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete the report.')),
      );
    }
  }

  void _goBack() {
    Navigator.pop(context, _hasChanges);
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = _isOwner;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Item Details'),
        actions: [
          if (isOwner)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _editItem();
                } else if (value == 'delete') {
                  _deleteItem();
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined),
                        SizedBox(width: 10),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline),
                        SizedBox(width: 10),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ];
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          try {
            final items = await _lostItemService.getLostItems();

            final refreshedItem = items.firstWhere(
              (item) => item.id == _item.id,
            );

            if (!mounted) {
              return;
            }

            setState(() {
              _item = refreshedItem;
            });
          } catch (e) {
            if (!mounted) {
              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not refresh item details.')),
            );
          }
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
          children: [
            _buildItemImage(),

            const SizedBox(height: 20),

            Text(
              _item.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              _item.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 20),

            _buildStatusSection(),

            _buildInfoCard(
              icon: _categoryIcon(_item.category),
              title: 'Category',
              value: _categoryLabel(_item.category),
            ),

            _buildInfoCard(
              icon: Icons.location_on_outlined,
              title: 'Location',
              value: _item.location,
            ),

            _buildInfoCard(
              icon: Icons.calendar_today_outlined,
              title: 'Date Lost',
              value: _formatDate(_item.dateLost),
            ),

            _buildInfoCard(
              icon: Icons.contact_phone_outlined,
              title: 'Contact',
              value: _item.contactInfo,
            ),

            if (!isOwner) ...[
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Only the owner of this report can '
                          'edit, delete, or change its status.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
