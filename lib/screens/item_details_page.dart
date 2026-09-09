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
  late LostItem _item;

  @override
  void initState() {
    super.initState();

    _item = widget.item;
  }

  Future<void> _editItem() async {
    final LostItem? updatedItem = await Navigator.push<LostItem>(
      context,
      MaterialPageRoute(builder: (context) => EditItemPage(item: _item)),
    );

    if (updatedItem != null) {
      setState(() {
        _item = updatedItem;
      });

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _deleteItem() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Report'),
          content: const Text('Are you sure you want to delete this report?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
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
      final service = LostItemService();

      await service.deleteLostItem(_item.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report deleted successfully')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete the report')),
      );
    }
  }

  Widget _buildItemImage() {
    final imagePath = _item.imageUrl;

    if (imagePath == null || imagePath.isEmpty) {
      return const SizedBox.shrink();
    }

    Widget image;

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      image = Image.network(
        imagePath,
        width: double.infinity,
        height: 280,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageError();
        },
      );
    } else {
      image = Image.file(
        File(imagePath),
        width: double.infinity,
        height: 280,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageError();
        },
      );
    }

    return GestureDetector(
      onTap: _openFullImage,
      child: ClipRRect(borderRadius: BorderRadius.circular(16), child: image),
    );
  }

  Widget _buildImageError() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image_outlined, size: 55),
            SizedBox(height: 8),
            Text('Image unavailable'),
          ],
        ),
      ),
    );
  }

  void _openFullImage() {
    final imagePath = _item.imageUrl;

    if (imagePath == null || imagePath.isEmpty) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        Widget image;

        if (imagePath.startsWith('http://') ||
            imagePath.startsWith('https://')) {
          image = Image.network(imagePath, fit: BoxFit.contain);
        } else {
          image = Image.file(File(imagePath), fit: BoxFit.contain);
        }

        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              InteractiveViewer(child: image),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isOwner = _item.ownerId == widget.user.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Item Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _item.title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _item.status.name.toUpperCase(),
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (_item.imageUrl != null && _item.imageUrl!.isNotEmpty) ...[
              _buildItemImage(),

              const SizedBox(height: 8),

              const Center(
                child: Text(
                  'Tap image to view full size',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),

              const SizedBox(height: 24),
            ],

            Card(
              child: ListTile(
                leading: const Icon(Icons.category_outlined),
                title: const Text('Category'),
                subtitle: Text(_item.category.name),
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: const Text('Location'),
                subtitle: Text(_item.location),
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Date Lost'),
                subtitle: Text(
                  '${_item.dateLost.day}/'
                  '${_item.dateLost.month}/'
                  '${_item.dateLost.year}',
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Description',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(_item.description, style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 24),

            Card(
              child: ListTile(
                leading: const Icon(Icons.contact_mail_outlined),
                title: const Text('Contact'),
                subtitle: Text(_item.contactInfo),
              ),
            ),

            const SizedBox(height: 30),

            if (isOwner) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _editItem,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Report'),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _deleteItem,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete Report'),
                ),
              ),
            ] else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This report belongs to another user. '
                          'You can view the report and contact the owner.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
