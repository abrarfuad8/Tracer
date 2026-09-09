import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/lost_item.dart';
import '../models/user.dart';
import '../services/lost_item_service.dart';

class ReportLostPage extends StatefulWidget {
  final User user;

  const ReportLostPage({super.key, required this.user});

  @override
  State<ReportLostPage> createState() => _ReportLostPageState();
}

class _ReportLostPageState extends State<ReportLostPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _imageUrlController = TextEditingController();

  final LostItemService _lostItemService = LostItemService();

  File? _selectedImage;

  ItemCategory? _selectedCategory;
  DateTime? _selectedDate;

  bool _isSubmitting = false;

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

        // إذا اختار المستخدم صورة محلية،
        // نمسح رابط الصورة الخارجية.
        _imageUrlController.clear();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to select the image')),
      );
    }
  }

  void _removeSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select the lost date')),
      );

      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final imageUrl = _imageUrlController.text.trim();

    final lostItem = LostItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      category: _selectedCategory!,
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
      dateLost: _selectedDate!,

      // Local image has priority over URL.
      imageUrl: _selectedImage?.path ?? (imageUrl.isEmpty ? null : imageUrl),

      status: ItemStatus.lost,
      contactInfo: widget.user.email,
      ownerId: widget.user.id,
    );

    try {
      await _lostItemService.addLostItem(lostItem);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lost item reported successfully')),
      );

      Navigator.pop(context, lostItem);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit the report')),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Lost Item')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Item Name
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

              // Category
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
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Description
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

              // Location
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

              // Date
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date Lost',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? 'Select date'
                        : '${_selectedDate!.day}/'
                              '${_selectedDate!.month}/'
                              '${_selectedDate!.year}',
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

                      // Image preview
                      if (_selectedImage != null)
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _selectedImage!,
                                width: double.infinity,
                                height: 220,
                                fit: BoxFit.cover,
                              ),
                            ),

                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                child: IconButton(
                                  onPressed: _removeSelectedImage,
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Container(
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
                              Text('No image selected'),
                            ],
                          ),
                        ),

                      const SizedBox(height: 12),

                      // Choose local image
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Choose Image from Device'),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Image URL
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

              // Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitReport,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_outlined),
                  label: Text(
                    _isSubmitting ? 'Submitting...' : 'Submit Report',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
