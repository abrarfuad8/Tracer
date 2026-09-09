import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/lost_item.dart';
import '../services/lost_item_service.dart';

class EditItemPage extends StatefulWidget {
  final LostItem item;

  const EditItemPage({super.key, required this.item});

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();

  final _descriptionController = TextEditingController();

  final _locationController = TextEditingController();

  final _imageUrlController = TextEditingController();

  final LostItemService _lostItemService = LostItemService();

  late ItemCategory _selectedCategory;
  late ItemStatus _selectedStatus;
  late DateTime _selectedDate;

  File? _selectedImage;
  String? _currentImagePath;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _titleController.text = widget.item.title;

    _descriptionController.text = widget.item.description;

    _locationController.text = widget.item.location;

    _selectedCategory = widget.item.category;

    _selectedStatus = widget.item.status;

    _selectedDate = widget.item.dateLost;

    _currentImagePath = widget.item.imageUrl;

    if (widget.item.imageUrl != null &&
        (widget.item.imageUrl!.startsWith('http://') ||
            widget.item.imageUrl!.startsWith('https://'))) {
      _imageUrlController.text = widget.item.imageUrl!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _imageUrlController.dispose();

    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedImage == null) {
      return;
    }

    try {
      final appDirectory = await getApplicationDocumentsDirectory();

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      final savedImage = await File(
        pickedImage.path,
      ).copy('${appDirectory.path}/$fileName');

      if (!mounted) return;

      setState(() {
        _selectedImage = savedImage;
        _currentImagePath = savedImage.path;

        // Local image takes priority.
        _imageUrlController.clear();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to select the image')),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _currentImagePath = null;
      _imageUrlController.clear();
    });
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final imageUrl = _imageUrlController.text.trim();

    final updatedItem = LostItem(
      id: widget.item.id,
      title: _titleController.text.trim(),
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
      dateLost: _selectedDate,

      imageUrl:
          _selectedImage?.path ??
          (imageUrl.isEmpty ? _currentImagePath : imageUrl),

      status: _selectedStatus,
      contactInfo: widget.item.contactInfo,
      ownerId: widget.item.ownerId,
    );

    try {
      await _lostItemService.updateLostItem(updatedItem);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report updated successfully')),
      );

      Navigator.pop(context, updatedItem);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update the report')),
      );
    }
  }

  Widget _buildCurrentImage() {
    final imagePath = _currentImagePath;

    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 55),
            SizedBox(height: 8),
            Text('No image'),
          ],
        ),
      );
    }

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imagePath,
          width: double.infinity,
          height: 220,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImageError();
          },
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        File(imagePath),
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageError();
        },
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image_outlined, size: 50),
            SizedBox(height: 8),
            Text('Image unavailable'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Item')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the item name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<ItemCategory>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                initialValue: _selectedCategory,
                items: ItemCategory.values.map((category) {
                  return DropdownMenuItem<ItemCategory>(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the lost location';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date Lost',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    '${_selectedDate.day}/'
                    '${_selectedDate.month}/'
                    '${_selectedDate.year}',
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Image
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.image_outlined),
                          SizedBox(width: 10),
                          Text(
                            'Item Image',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      _buildCurrentImage(),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.photo_library_outlined),
                              label: const Text('Change Image'),
                            ),
                          ),

                          if (_currentImagePath != null) ...[
                            const SizedBox(width: 10),
                            IconButton(
                              tooltip: 'Remove Image',
                              onPressed: _removeImage,
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _imageUrlController,
                        keyboardType: TextInputType.url,
                        enabled: _selectedImage == null,
                        decoration: const InputDecoration(
                          labelText: 'Image URL (Optional)',
                          hintText: 'https://example.com/image.jpg',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.link),
                        ),
                        validator: (value) {
                          final url = value?.trim() ?? '';

                          if (url.isEmpty) {
                            return null;
                          }

                          if (!url.startsWith('http://') &&
                              !url.startsWith('https://')) {
                            return 'Please enter a valid image URL';
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveChanges,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
