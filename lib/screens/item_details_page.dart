import 'package:flutter/material.dart';

import '../models/lost_item.dart';
import '../services/lost_item_service.dart';
import 'edit_item_page.dart';

class ItemDetailsPage extends StatefulWidget {
  final LostItem item;

  const ItemDetailsPage({super.key, required this.item});

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

  @override
  Widget build(BuildContext context) {
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
                  '${_item.dateLost.day}/${_item.dateLost.month}/${_item.dateLost.year}',
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
          ],
        ),
      ),
    );
  }
}
